from django.urls import path
from .views import PenghuniListView, PenghuniDetailView, PekerjaListView, PekerjaDetailView

urlpatterns = [
    path('penghuni/',        PenghuniListView.as_view()),
    path('penghuni/<int:pk>/', PenghuniDetailView.as_view()),
    path('pekerja/',         PekerjaListView.as_view()),
    path('pekerja/<int:pk>/',  PekerjaDetailView.as_view()),
]
