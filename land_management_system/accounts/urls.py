from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path("", include("dj_rest_auth.urls")),
]