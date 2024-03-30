from .views import *
from django.urls import path

urlpatterns = [
    path("get_user_nfts", get_user_nfts, name="get_user_nfts"),
    path("registration/", aPage, name="aPage"),
    path("login/", login_view, name="login"),
    path("logout/", logout_view, name="logout"),
    path("link_wallet/", LinkWalletView.as_view(), name="link_wallet"),
    path("get_wallet_address/", get_wallet_address, name="get_wallet_address"),
    path("verify_cnic/", verify_cnic, name="verify_cnic"),
    path("create_land_transfer/", create_land_transfer, name="create_land_transfer"),
    path(
        "get_cnic_by_email/<str:email>/",
        get_cnic_from_email,
        name="get_cnic_by_email",
    ),
]
