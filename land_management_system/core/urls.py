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
    path(
        "get_scheduled_datetimes/",
        get_scheduled_datetimes,
        name="get_scheduled_datetimes",
    ),
    path("get_pending_transfers/", get_pending_transfers, name="get_pending_transfers"),
    path(
        "get_approved_transfers/", get_approved_transfers, name="get_approved_transfers"
    ),
    path("resend_confirmation/", resend_confirmation_email, name="resend_confirmation"),
    path("forgot_password/", forgot_password, name="forgot_password"),
    path("get_user_profile/", get_user_profile, name="get_user_profile"),
    path("update_user_profile/", update_user_profile, name="update_user_profile"),
    path(
        "get_marked_land/<str:tehsil>/<str:khasra>/<str:division>/",
        get_marked_land,
        name="get_marked_land",
    ),
    path(
        "generate_challan/<str:userType>/",
        generate_challan,
        name="generate_challan",
    ),
]
