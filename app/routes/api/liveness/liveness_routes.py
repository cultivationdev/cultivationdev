import datetime as dt

from flask import jsonify

from app.config.cfg import cfg
from app.routes.route_blueprints import api_liveness_blueprint

__author__ = 'kclark'


bp = api_liveness_blueprint


@bp.route('/liveness', methods=['GET'])
def handle_liveness_get_req():
    result = {
        'environment': cfg.app_env,
        'current_time': dt.datetime.utcnow().isoformat(),
        'start_time': cfg.start_time.isoformat(),
        'version': cfg.version
    }

    return jsonify(result)
