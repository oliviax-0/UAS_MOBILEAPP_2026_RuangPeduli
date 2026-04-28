from django.urls import path
from .views import (
    DashboardView,
    JenisPemasukanListView, JenisPemasukanDetailView,
    PemasukanListView, PemasukanDetailView,
    PengeluaranListView, PengeluaranDetailView,
)

urlpatterns = [
    path('dashboard/',                      DashboardView.as_view()),
    path('jenis-pemasukan/',                JenisPemasukanListView.as_view()),
    path('jenis-pemasukan/<int:pk>/',       JenisPemasukanDetailView.as_view()),
    path('pemasukan/',                      PemasukanListView.as_view()),
    path('pemasukan/<int:pk>/',             PemasukanDetailView.as_view()),
    path('pengeluaran/',                    PengeluaranListView.as_view()),
    path('pengeluaran/<int:pk>/',           PengeluaranDetailView.as_view()),
]
