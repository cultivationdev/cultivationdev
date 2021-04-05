import logging
import os
from importlib import import_module

from flask import Flask

from app.routes.route_blueprints import route_blueprints

__author__ = 'kclark'

logger = logging.getLogger(__name__)


def create_app():
    logger.info('Create Flask App Instance')

    app = Flask(__name__)
    app.secret_key = os.urandom(16)

    _register_blueprints(app)

    logger.info('Initialized Flask App Instance')

    return app


def _register_blueprints(app: Flask):
    logger.info('Register Flask Blueprint Routes')

    for bp in route_blueprints:
        logger.info(f'Register Route Blueprint: {bp.import_name}')
        import_module(bp.import_name)
        app.register_blueprint(bp)