from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class EnvVars(BaseSettings):
    django_secret: str = Field(description='Djangoシークレットキー')
    django_debug: bool = Field(description='Djangoデバッグ')
    django_allowed_hosts: list[str] = Field(description='許可ホストのリスト', default=['*'])

    redis_host: str = Field(description='Redisホスト')
    redis_port: int = Field(description='Redisポート', default=6379)
    redis_db: str = Field(description='Redisデータベース名', default="0")
    redis_ssl: bool = Field(description='RedisにSSL接続するかどうか', default=False)

    model_config = SettingsConfigDict(env_file='.env')


env_vars = EnvVars()
