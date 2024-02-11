from django.shortcuts import render, redirect
from django.http import HttpResponse, JsonResponse
from django.contrib.auth import *
from django.views.decorators.csrf import csrf_exempt
from django.core.exceptions import ValidationError
from django.contrib.auth.password_validation import validate_password
from allauth.account.models import EmailAddress
from allauth.account.utils import send_email_confirmation
from django.db import IntegrityError
from django.db.models import Q
from .models import *
import json


@csrf_exempt
def aPage(request):
    if request.method == "POST":
        # Get data from POST request
        username = request.POST.get("username")
        email = request.POST.get("email")
        password = request.POST.get("password")
        first_name = request.POST.get("first_name")
        last_name = request.POST.get("last_name")
        mobile_number = request.POST.get("mobile_number")
        cnic = request.POST.get("cnic")

        # Validate password
        try:
            validate_password(password)
        except ValidationError as e:
            return JsonResponse({"errors": list(e.messages)}, status=400)

        # Create user if data is valid
        User = get_user_model()
        if User.objects.filter(mobile_number=mobile_number).exists():
            return JsonResponse(
                {
                    "errors": "This mobile number is already in use. Please use a different mobile number."
                },
                status=400,
            )
        if User.objects.filter(cnic=cnic).exists():
            return JsonResponse(
                {"errors": "This CNIC is already in use. Please use a different CNIC."},
                status=400,
            )
        try:
            user = User.objects.create_user(
                username=username,
                email=email,
                password=password,
                first_name=first_name,
                last_name=last_name,
            )
            user.mobile_number = mobile_number
            user.cnic = cnic
            user.save()

            try:
                EmailAddress.objects.create(
                    user=user, email=user.email, primary=True, verified=False
                )
                send_email_confirmation(request, user)
                response_data = {
                    "data": {
                        "username": user.username,
                        "email": user.email,
                        "first_name": user.first_name,
                        "last_name": user.last_name,
                        "mobile_number": user.mobile_number,
                        "cnic": user.cnic,
                    }
                }
                return JsonResponse(response_data, status=201)
            except Exception:
                user.delete()  # Rollback user creation in case of failure
                return JsonResponse(
                    {"errors": "Failed to send confirmation email."}, status=500
                )

        except IntegrityError as e:
            if "email" in str(e):
                error_message = (
                    "This email is already in use. Please use a different email."
                )
            elif "username" in str(e):
                error_message = "This username is already taken. Please choose a different username."
            else:
                error_message = (
                    "There was an error with your submission. Please try again."
                )
            return JsonResponse({"errors": error_message}, status=400)

        except Exception as e:
            return JsonResponse({"errors": str(e)}, status=400)

    else:
        # Render the registration form template on a GET request
        return render(request, "registration_form.html")


@csrf_exempt
def login_view(request):
    if request.method == "POST":
        login_id = request.POST.get(
            "login_id"
        )  # Use 'login_id' to cover both email and CNIC
        password = request.POST.get("password")

        user = None
        if "@" in login_id:  # Assuming it's an email
            try:
                user = User.objects.get(email=login_id)
            except User.DoesNotExist:
                pass
        else:  # Assuming it's a CNIC
            try:
                user = User.objects.get(cnic=login_id)
            except User.DoesNotExist:
                pass

        if user is not None:
            user = authenticate(request, username=user.username, password=password)
            if user is not None:
                login(request, user)
                # Modify here for JsonResponse
                return JsonResponse(
                    {
                        "message": "Login successful",
                        "user": {"username": user.username, "email": user.email},
                    },
                    status=200,
                )
            else:
                return JsonResponse({"error": "Invalid login or password."}, status=400)
        else:
            return JsonResponse({"error": "Invalid login or password."}, status=400)
    else:
        return render(request, "login.html")
