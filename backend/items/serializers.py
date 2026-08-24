from rest_framework import serializers


class ItemSerializer(serializers.Serializer):
    """Redisに登録する1件のkey/value"""

    key = serializers.CharField(max_length=512)
    value = serializers.CharField(max_length=4096, allow_blank=True)
