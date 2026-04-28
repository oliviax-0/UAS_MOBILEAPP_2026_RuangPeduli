from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    RegisterStartView, VerifyOtpView, ResendOtpView, LoginView,
    ForgotPasswordRequestView, ForgotPasswordResetView,
    GoogleAuthView, GoogleRegisterView,
    ChangePasswordView,
    RequestEmailChangeView, RequestNewEmailVerifyView, ConfirmEmailChangeView,
)

urlpatterns = [
    path('pending/',                   RegisterStartView.as_view(),          name='register-start'),
    path('verify/',                    VerifyOtpView.as_view(),              name='register-verify'),
    path('resend-otp/',                ResendOtpView.as_view(),              name='resend-otp'),
    path('login/',                     LoginView.as_view(),                  name='login'),
    path('token/refresh/',             TokenRefreshView.as_view(),           name='token-refresh'),
    path('forgot-password/',           ForgotPasswordRequestView.as_view(),  name='forgot-password'),
    path('reset-password/',            ForgotPasswordResetView.as_view(),    name='reset-password'),
    path('google-auth/',               GoogleAuthView.as_view(),             name='google-auth'),
    path('google-register/',           GoogleRegisterView.as_view(),         name='google-register'),
    path('change-password/',           ChangePasswordView.as_view(),         name='change-password'),
    path('request-email-change/',      RequestEmailChangeView.as_view(),     name='request-email-change'),
    path('request-new-email-verify/',  RequestNewEmailVerifyView.as_view(),  name='request-new-email-verify'),
    path('confirm-email-change/',      ConfirmEmailChangeView.as_view(),     name='confirm-email-change'),
]