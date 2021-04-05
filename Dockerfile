##### Base Layer #####

# Apply python-base image
FROM tiangolo/uwsgi-nginx-flask:python3.8 as python-base

# Install extra libraries
RUN apt-get update -yqq \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    libssl-dev \
    libboost-all-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VERSION=1.1.5 \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

##### Builder Base Layer #####

# "builder" stage uses "python-base" stage to install app depedencies
FROM python-base as app-builder
RUN apt-get update && apt-get install --no-install-recommends -y \
    curl \
    build-essential

# Install Poetry (uses $POETRY_HOME & $POETRY_VERSION environment variables)
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python -

# Copy Python requirements and install only runtime dependencies
WORKDIR $PYSETUP_PATH
COPY ./poetry.lock ./pyproject.toml ./
RUN poetry install --no-dev

##### Deployment Layer (--target application) #####

# "application" stage uses "python-base" stage and copies in app dependencies from "app-builder"
FROM python-base as application

EXPOSE 5000

ENV UWSGI_INI=/app/uwsgi.ini

# Copy "app-builder" layer python environment into application layer
COPY --from=app-builder $VENV_PATH $VENV_PATH

# Copy custom supervisord conf to run with non-root user
COPY conf/components/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set active directory
WORKDIR /app

# Add non-root user
RUN adduser --disabled-password --gecos '' appuser

# Change owner to non-root user
RUN chown appuser \
    /app \
    /etc/nginx/conf.d \
    /etc/nginx/nginx.conf \
    /etc/supervisor/conf.d/supervisord.conf \
    /etc/uwsgi/uwsgi.ini \
    /usr/bin/supervisord \
    /usr/local/bin/uwsgi \
    /usr/sbin/nginx \
    /var/cache/nginx \
    /var/log/supervisor \
    /var/run

# Copy configuration components then application code
COPY /conf/components/start.sh \
     /conf/components/nginx.conf \
     /conf/components/uwsgi.ini ./
COPY /app ./app

# Assign start shell script permission privilege to non-root user
RUN chmod +x /app/start.sh

# Set non-root user
USER appuser

# Set default command to start shell command
CMD ["/app/start.sh"]

##### Test-Builder Layer #####

# "test-builder" stage uses "builder" stage and install test dependencies
FROM builder as test-builder

# Install the other dev dependencies originally skipped via the poetry "--no-dev" install flag
WORKDIR $PYSETUP_PATH
RUN poetry install

##### Testing Layer (--target testing) #####

# "testing" stage uses "application" stage and adds test dependencies to execute test script
FROM application as testing

# Copy test-builder python env into testing layer
COPY --from=test-builder $VENV_PATH $VENV_PATH

# Set active directory and copy test dependencies
WORKDIR /app
COPY /tests ./

# Set default to command run tests
CMD ["/tests/test_runner.sh"]
