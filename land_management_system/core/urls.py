from .views import *
from django.urls import path

urlpatterns = [
    path("registration/", aPage, name="aPage"),
    path("login/", login_view, name="login"),
    path("logout/", logout_view, name="logout"),
    path("link_wallet/", LinkWalletView.as_view(), name="link_wallet"),
]