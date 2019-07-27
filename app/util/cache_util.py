import logging
import functools

from app.util import time_util

GLOBAL_LOCAL_CACHE = {}


def async_local_cache(expire=60):
    """ 异步函数执行结果本地缓存
        expire: 缓存过期时间，单位（秒）
    """
    def decorate(func):

        def get_key(func, args, kwargs):
            return f"{func.__module__}@{func.__name__}@{args}@{kwargs}"

        @functools.wraps(func)
        async def _wrapper(*args, **kwargs):
            try:
                key = get_key(func, args, kwargs)
                if key not in GLOBAL_LOCAL_CACHE:
                    GLOBAL_LOCAL_CACHE[key] = {
                        "expire": expire + time_util.timestamp(),
                        "value": await func(*args, **kwargs)
                    }
                return GLOBAL_LOCAL_CACHE[key]["value"]
            except BaseException as error:
                logging.debug("gen cache key failed.{}".format(error))
                return await func(*args, **kwargs)
        return _wrapper

    return decorate
