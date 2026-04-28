from django.urls import path
from .views import KebutuhanAllView, KebutuhanListView, KebutuhanDetailView

urlpatterns = [
    path('all/',      KebutuhanAllView.as_view()),
    path('',          KebutuhanListView.as_view()),
    path('<int:pk>/', KebutuhanDetailView.as_view()),
]
