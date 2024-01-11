# serializers.py
from dj_rest_auth.registration.serializers import RegisterSerializer
from rest_framework import serializers

class CustomRegisterSerializer(RegisterSerializer):
    mobile_number = serializers.CharField(required=True)
    cnic = serializers.CharField(required=True)

    def get_cleaned_data(self):
        data = super().get_cleaned_data()
        data['mobile_number'] = self.validated_data.get('mobile_number', '')
        data['cnic'] = self.validated_data.get('cnic', '')
        return data
