from django.urls import path

from health.views import HealthCheckView

urlpatterns = [
    path('healthz', HealthCheckView.as_view(), name='healthz'),
]
