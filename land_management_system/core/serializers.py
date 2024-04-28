from rest_framework import serializers
from .models import User, Land, LandTransfer, NFT, TaxesFee


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = (
            "id",
            "username",
            "email",
            "full_name",
            "wallet_address",
            "mobile_number",
            "cnic",
            "role",
            "filer_status",
        )


class LandSerializer(serializers.ModelSerializer):
    class Meta:
        model = Land
        fields = "__all__"


class LandTransferSerializer(serializers.ModelSerializer):
    class Meta:
        model = LandTransfer
        fields = "__all__"


class NFTSerializer(serializers.ModelSerializer):
    class Meta:
        model = NFT
        fields = "__all__"


class TaxesFeeSerializer(serializers.ModelSerializer):
    class Meta:
        model = TaxesFee
        fields = "__all__"
