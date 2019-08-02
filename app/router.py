from app.model.index import handler as index
from app.model.health_check import handler as health_check

ROUTERS = [
    (r"/", index.IndexHandler),
    (r"/ping", health_check.HealthCheckHandler),
]
