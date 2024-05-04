from django.urls import path
from .views import *

urlpatterns = [
    path(
        "transfer-nft/<int:land_id>/<str:receiver_wallet_address>/",
        transfer_nft,
        name="transfer_nft",
    ),
    path(
        "update-metadata/<int:land_id>/<str:new_owner_wallet>/",
        update_metadata,
        name="update_metadata",
    ),
    path("fetch-metadata/<int:land_id>/", fetch_metadata, name="fetch_metadata"),
    path(
        "check-wallet-connection/",
        check_wallet_connection,
        name="check_wallet_connection",
    ),
    path("user_nfts/", get_user_nfts, name="get_user_nfts"),
    path(
        "nft_by_land_details/<str:tehsil>/<str:khasra_number>/<str:division>/",
        get_nft_by_land_details,
        name="get_nft_by_land_details",
    ),
]
