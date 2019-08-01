from app.model.index.handler import IndexHandler
from app.model.health_check.handler import HealthCheckHandler

ROUTERS = [
    (r"/", IndexHandler),
    (r"/ping", HealthCheckHandler),
]
