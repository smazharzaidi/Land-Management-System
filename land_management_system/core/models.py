from django.db import models
from django.contrib.auth.models import User,AbstractUser
class User(AbstractUser):
    email=models.EmailField(unique=True)
    mobile_number = models.CharField(max_length=11, unique=True)
    cnic = models.CharField(max_length=15, unique=True)

# Create your models here.
