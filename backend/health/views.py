from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView


class HealthCheckView(APIView):
    """Liveness probe. Returns 200 as long as the application can serve requests."""

    authentication_classes = []
    permission_classes = [AllowAny]

    def get(self, request):
        return Response({'status': 'ok'}, status=status.HTTP_200_OK)
