import logging

from flask import Blueprint

__author__ = 'kclark'

logger = logging.getLogger(__name__)

# Utility helper to create a Blueprint instance
def create_blueprint(partial_module: str, url_prefix: str = None) -> Blueprint:
    import_name = f'app.routes.{partial_module}'
    blueprint = Blueprint(partial_module, import_name, url_prefix=url_prefix)

    return blueprint

# Define route Blueprints
api_liveness_blueprint = create_blueprint('api.liveness.liveness_routes', '/api')
api_readiness_blueprint = create_blueprint('api.readiness.readiness_routes', '/api')

route_blueprints = [
    api_liveness_blueprint,
    api_readiness_blueprint
]
