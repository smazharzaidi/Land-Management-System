from django.contrib import admin
from .models import User, Land, LandTransfer, NFT, AuthToken, TaxesFee


# Optional: Define custom admin classes to customize the admin interface
class UserAdmin(admin.ModelAdmin):
    list_display = ("username", "email", "name","wallet_address", "mobile_number", "cnic", "role")
    search_fields = ("username", "email", "name","wallet_address", "mobile_number", "cnic")


class LandAdmin(admin.ModelAdmin):
    list_display = ("tehsil", "khasra_number", "division", "owner", "land_area")
    search_fields = ("tehsil", "khasra_number", "owner__username")


class LandTransferAdmin(admin.ModelAdmin):
    list_display = (
        "land",
        "transferor_user",
        "transferee_user",
        "transfer_type",
        "status",
        "scheduled_date",
        "transfer_date",
    )
    search_fields = (
        "land__khasra_number",
        "transferor_user__username",
        "transferee_user__username",
        "status",
    )


# Register your models here
admin.site.register(User, UserAdmin)
admin.site.register(Land, LandAdmin)
admin.site.register(LandTransfer, LandTransferAdmin)
admin.site.register(NFT)  # Simple registration without custom admin class
admin.site.register(AuthToken)
admin.site.register(TaxesFee)
