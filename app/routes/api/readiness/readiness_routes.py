import datetime as dt

from flask import jsonify

from app.config.cfg import cfg
from app.routes.route_blueprints import api_readiness_blueprint

__author__ = 'kclark'


bp = api_readiness_blueprint


@bp.route('/readiness', methods=['GET'])
def handle_readiness_get_req():
    print('did we even hit this???')
    result = {
        'environment': cfg.app_env,
        'current_time': dt.datetime.utcnow().isoformat(),
        'start_time': cfg.start_time.isoformat(),
        'version': cfg.version
    }

    return jsonify(result)
