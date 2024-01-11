from .views import aPage
from django.urls import path

urlpatterns = [
    path('', aPage, name='aPage'),
]
