from django.db import models
from django.contrib.auth.models import AbstractUser
from django.contrib.gis.db import models as gis_models


class User(AbstractUser):
    mobile_number = models.CharField(max_length=11, unique=True)
    cnic = models.CharField(max_length=15, unique=True)
    name = models.CharField(max_length=255)
    wallet_address = models.CharField(max_length=42, null=True, blank=True)
    role = models.CharField(
        max_length=50,
        choices=(("user", "User"), ("tehsildar", "Tehsildar"), ("pa", "PA")),
    )
    filer_status = models.CharField(
        max_length=50,
        choices=(("filer", "Filer"), ("nonfiler", "Non-Filer")),
        null=True,
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


class Land(models.Model):
    tehsil = models.CharField(max_length=255)
    khasra_number = models.CharField(max_length=255, unique=True)
    division = models.CharField(max_length=255, null=True, blank=True)
    owner = models.ForeignKey(User, related_name="lands", on_delete=models.CASCADE)
    land_area = models.DecimalField(max_digits=10, decimal_places=2)
    land_geometry = gis_models.PolygonField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


class LandTransfer(models.Model):
    land = models.ForeignKey(Land, on_delete=models.CASCADE)
    transferor_user = models.ForeignKey(
        User, related_name="transfers_made", on_delete=models.CASCADE
    )
    transferee_user = models.ForeignKey(
        User, related_name="transfers_received", on_delete=models.CASCADE
    )
    transfer_type = models.CharField(
        max_length=50,
        choices=(
            ("selling", "Selling"),
            ("gift", "Gift"),
            ("death_mutation", "Death Mutation"),
            ("in_life_mutation", "In Life Mutation"),
        ),
    )
    status = models.CharField(
        max_length=50,
        choices=(
            ("pending", "Pending"),
            ("approved", "Approved"),
            ("disapproved", "Disapproved"),
        ),
    )
    scheduled_datetime = models.DateTimeField(null=True, blank=True)
    transfer_date = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


class NFT(models.Model):
    land = models.ForeignKey(Land, on_delete=models.CASCADE)
    owner = models.ForeignKey(User, on_delete=models.CASCADE)
    token_id = models.CharField(max_length=255)
    metadata_url = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


class AuthToken(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    token = models.CharField(max_length=255)
    expiry_date = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)


class TaxesFee(models.Model):
    transfer = models.ForeignKey(LandTransfer, on_delete=models.CASCADE)
    tax_type = models.CharField(
        max_length=50,
        choices=(("transferor", "Transferor"), ("transferee", "Transferee")),
    )
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(
        max_length=50, choices=(("pending", "Pending"), ("paid", "Paid"))
    )
    payment_date = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
