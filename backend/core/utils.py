import redis
from django.conf import settings


class RedisUtil:
    """Redisのユーティリティ"""
    def __init__(self) -> None:
        self.redis_client = redis.Redis(
            host=settings.REDIS_HOST,
            port=settings.REDIS_PORT,
            db=settings.REDIS_DB,
            ssl=settings.REDIS_SSL,
        )

    def set(self, key: str, value: str) -> None:
        self.redis_client.set(key, value)

    def get_all(self) -> dict[str, str]:
        """登録されている全key/valueの辞書を返す"""
        keys = list(self.redis_client.scan_iter())
        if not keys:
            return {}

        values = self.redis_client.mget(keys)
        return {
            key.decode(): value.decode()
            for key, value in zip(keys, values)
            if value is not None
        }
