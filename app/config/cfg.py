import datetime as dt
import os
from dataclasses import dataclass

__author__ = 'kclark'


@dataclass()
class Configuration:
    app_env: str
    debug_mode: bool
    start_time: dt.datetime
    version: str

# Create global singleton for configuration settings
cfg = Configuration(
    app_env=os.getenv('APP_ENV', 'dev'),
    debug_mode=bool(os.getenv('FLASK_DEBUG', False)),
    start_time=dt.datetime.utcnow(),
    version=os.getenv('VERSION', None)
)
