from django.urls import path
from .views import DonasiListCreateView

urlpatterns = [
    path('', DonasiListCreateView.as_view(), name='donasi-list-create'),
]
