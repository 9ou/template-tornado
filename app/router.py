from app.model.index.handler import IndexHandler

ROUTERS = [
    (r"/", IndexHandler),
]
