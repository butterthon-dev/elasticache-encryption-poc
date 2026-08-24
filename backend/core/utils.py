import redis

from env_vars import env_vars


class RedisUtil:
    """Redisのユーティリティ"""
    def __init__(self) -> None:
        self.redis_client = redis.Redis(
            host=env_vars.redis_host,
            port=env_vars.redis_port,
            db=env_vars.redis_db,
            ssl=env_vars.redis_ssl,
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
