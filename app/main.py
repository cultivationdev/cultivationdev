import logging

from app.config.cfg import cfg
from app.core.app_init import create_app

__author__ = 'kclark'

logger = logging.getLogger(__name__)


app = create_app()


def run_app():
    logger.info('App Server Initializing')

    app.run(host='localhost', port=5000, threaded=True, debug=cfg.debug_mode)

    logger.info('App Server Running')


if __name__ == '__main__':
    run_app()
