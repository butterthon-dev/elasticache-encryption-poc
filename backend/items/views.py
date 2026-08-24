from drf_spectacular.utils import extend_schema
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from core.utils import RedisUtil
from items.serializers import ItemSerializer


class ItemListCreateView(APIView):
    """Redis上のkey/valueを登録・一覧するAPI"""

    authentication_classes = []
    permission_classes = [AllowAny]

    @extend_schema(
        responses={200: ItemSerializer(many=True)},
        description='Redisに登録されている全key/valueを返す',
    )
    def get(self, request):
        items = RedisUtil().get_all()

        serializer = ItemSerializer(
            [{'key': key, 'value': value} for key, value in items.items()],
            many=True,
        )
        return Response(serializer.data, status=status.HTTP_200_OK)

    @extend_schema(
        request=ItemSerializer,
        responses={201: ItemSerializer},
        description='Redisにkey/valueを1件セットする',
    )
    def post(self, request):
        serializer = ItemSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        RedisUtil().set(serializer.validated_data['key'], serializer.validated_data['value'])

        return Response(serializer.data, status=status.HTTP_201_CREATED)
