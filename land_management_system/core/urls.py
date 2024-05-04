from .views import *
from django.urls import path

urlpatterns = [
    path("get_user_nfts", get_user_nfts, name="get_user_nfts"),
    path("registration/", aPage, name="aPage"),
    path("login/", login_view, name="login"),
    path("login_check/", login_check, name="login_check"),
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
        "challan/<str:khasra_number>/<str:tehsil>/<str:division>/<str:user_type>/",
        get_challan_details,
        name="challan-details",
    ),
    # WEBSIT URLS
    path("teh_status/", view_status, name="teh_status"),
    path("teh_approved/<int:id>/", view_approved, name="teh_approved"),
    path("teh_dispproved/<int:id>/", view_disapp, name="teh_dispproved"),
    path("teh_register/", view_registration, name="teh_register"),
    path("teh_login/", view_login, name="teh_login"),
    path("teh_dashboard/", view_dashboard, name="teh_dashboard"),
    path("teh_store/", store_data, name="teh_store"),
    path("teh_logout/", logout_view, name="teh_logout"),
    path("calculate_tax/", calculate_tax, name="calculate_tax"),
    path("user_login/", user_login, name="user_login"),
    path("user_dashboard/", user_dashboard, name="user_dashboard"),
    path('user_logout/', user_logout, name='user_logout'),
]
