import datetime
from django.shortcuts import render, redirect
from django.http import HttpResponse, JsonResponse
from django.contrib.auth import authenticate, get_user_model
from django.views.decorators.csrf import csrf_exempt
from django.core.exceptions import ValidationError
from django.contrib.auth.password_validation import validate_password
from allauth.account.models import EmailAddress
from allauth.account.utils import send_email_confirmation
from django.db import IntegrityError, transaction
from .models import *
import json
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from flask import Flask, request
from dotenv import load_dotenv
from moralis import evm_api
import os
from django.contrib.auth.decorators import login_required
from rest_framework_simplejwt.authentication import JWTAuthentication


# Load environment variables
load_dotenv()
api_key = os.getenv("MORALIS_API_KEY")


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_wallet_address(request):
    user = request.user
    print(f"User {user.username} is requesting wallet address.")
    wallet_address = getattr(user, "wallet_address", None)
    if wallet_address:
        return JsonResponse({"wallet_address": wallet_address})
    else:
        return JsonResponse({"error": "Wallet address not found."}, status=404)


@api_view(["GET"])
@permission_classes([IsAuthenticated])  # Ensure only authenticated users can access
def get_cnic_from_email(request, email):
    try:
        user = User.objects.get(email=email)
        return Response(
            {"cnic": user.cnic}
        )  # Assuming CNIC is stored in a related profile model
    except User.DoesNotExist:
        return Response({"error": "User not found"}, status=404)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def create_land_transfer(request):
    data = json.loads(request.body.decode("utf-8"))
    khasra_number = data.get("khasraNumber")
    transferee_cnic = data.get("transfereeCNIC")
    transfer_type = data.get("transferType")

    try:
        land = Land.objects.get(khasra_number=khasra_number)
        transferor_user = request.user
        transferee_user = User.objects.get(cnic=transferee_cnic)

        land_transfer = LandTransfer.objects.create(
            land=land,
            transferor_user=transferor_user,
            transferee_user=transferee_user,
            transfer_type=transfer_type,
            status="pending",
        )
        return JsonResponse(
            {"success": True, "message": "Land transfer initiated successfully."}
        )

    except Land.DoesNotExist:
        return JsonResponse({"success": False, "error": "Land not found."}, status=404)
    except User.DoesNotExist:
        return JsonResponse(
            {"success": False, "error": "Transferee user not found."}, status=404
        )


@api_view(["POST"])
@permission_classes([IsAuthenticated])  # Assuming you want to protect this endpoint
def verify_cnic(request):
    data = request.data
    cnic = data.get("cnic")

    if not cnic:
        return JsonResponse({"error": "CNIC is required"}, status=400)

    try:
        user = User.objects.get(cnic=cnic)
        # If you need to perform additional checks or return specific data, adjust here.
        return JsonResponse({"message": "CNIC found", "user_id": user.id}, status=200)
    except User.DoesNotExist:
        return JsonResponse({"error": "CNIC not found"}, status=404)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_user_nfts(request):
    try:
        wallet_address = request.user.wallet_address
        if not wallet_address:
            return Response(
                {"error": "Wallet address not found for the user"}, status=404
            )

        chain = "sepolia"  # Use Mumbai testnet
        # Assuming your evm_api call is correct and returns a data structure compatible with JSON serialization
        result = evm_api.nft.get_wallet_nfts(
            api_key=api_key,
            params={
                "address": wallet_address,
                "chain": chain,
                "format": "decimal",
                "limit": 100,
                "token_addresses": [],
                "normalizeMetadata": True,
            },
        )
        # Directly return the result as a Response object
        # Ensure the result is a dict or similar structure that can be serialized to JSON
        return Response(result)  # This automatically handles serialization

    except User.DoesNotExist:
        return Response({"error": "User not found."}, status=404)


class LinkWalletView(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get("username")  # Use email instead of username
        wallet_address = request.data.get("wallet_address")
        print(f"Attempting to link wallet: {wallet_address} to email: {email}")
        try:
            user = get_user_model().objects.get(email=email)  # Lookup user by email
            user.wallet_address = wallet_address
            user.save()
            print(f"Successfully linked {wallet_address} to {email}")  # Debug print
            return Response({"success": True, "message": "Wallet linked successfully."})
        except get_user_model().DoesNotExist:
            print("User not found with the provided email.")
            return Response({"success": False, "message": "User not found."})


@csrf_exempt
def aPage(request):
    if request.method == "POST":
        # Extract data from POST request
        username = request.POST.get("username")
        email = request.POST.get("email")
        password = request.POST.get("password")
        name = request.POST.get("name")
        mobile_number = request.POST.get("mobile_number")
        cnic = request.POST.get("cnic")

        # Validate password
        try:
            validate_password(password)
        except ValidationError as e:
            return JsonResponse({"errors": list(e.messages)}, status=400)

        # Check for existing mobile_number and cnic
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
            # Create user with the default role set to 'user'
            user = User.objects.create_user(
                username=username,
                email=email,
                password=password,
                name=name,
                mobile_number=mobile_number,
                cnic=cnic,
                role="user",  # Set the role to 'user' by default
            )

            # Attempt to send a confirmation email
            try:
                EmailAddress.objects.create(
                    user=user, email=user.email, primary=True, verified=False
                )
                send_email_confirmation(request, user)
                response_data = {
                    "data": {
                        "username": user.username,
                        "email": user.email,
                        "name": user.name,
                        "mobile_number": user.mobile_number,
                        "cnic": user.cnic,
                        "role": user.role,
                    }
                }
                return JsonResponse(response_data, status=201)
            except Exception:
                user.delete()  # Rollback user creation in case of failure to send email
                return JsonResponse(
                    {"errors": "Failed to send confirmation email."}, status=500
                )

        except IntegrityError as e:
            # Handle unique constraint violations for email and username
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
            # Handle other exceptions
            return JsonResponse({"errors": str(e)}, status=400)

    else:
        # Render the registration form template on a GET request
        return render(request, "registration_form.html")


@csrf_exempt
@api_view(["POST"])
def logout_view(request):
    try:
        refresh_token = request.data.get("refresh")
        token = RefreshToken(refresh_token)
        token.blacklist()
        return Response({"message": "Logout successful."}, status=200)
    except Exception as e:
        return Response({"error": str(e)}, status=400)


@csrf_exempt
def login_view(request):
    if request.method == "POST":
        username = request.POST.get("username")
        password = request.POST.get("password")
        user = None

        # Determine if username is an email or CNIC
        if "@" in username:
            try:
                user = get_user_model().objects.get(email=username)
            except get_user_model().DoesNotExist:
                pass
        else:
            try:
                user = get_user_model().objects.get(cnic=username)
            except get_user_model().DoesNotExist:
                pass

        if user is not None:
            # Authenticate user
            authentication_result = authenticate(
                request, username=user.username, password=password
            )
            if authentication_result is not None:
                # Use TokenObtainPairSerializer to validate and create a token
                serializer = TokenObtainPairSerializer(
                    data={"username": user.username, "password": password}
                )
                # Validate serializer with user's credentials
                if serializer.is_valid():
                    # Generate token
                    token = serializer.validated_data
                    return JsonResponse(
                        {
                            "message": "Login successful",
                            "access": token["access"],
                            "refresh": token["refresh"],
                            "user": {
                                "username": user.username,
                                "email": user.email,
                                "wallet_address": user.wallet_address,  # Include wallet address in response
                            },
                        },
                        status=200,
                    )

                else:
                    return JsonResponse({"error": "Invalid credentials"}, status=400)
            else:
                return JsonResponse({"error": "Invalid login or password."}, status=400)
        else:
            return JsonResponse({"error": "Invalid login or password."}, status=400)
    else:
        return render(request, "login.html")
