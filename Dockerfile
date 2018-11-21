FROM debian:stretch

RUN apt-get update
RUN apt-get install --yes \
      git-core \
      python \
      python-pip \
      python-virtualenv

# Create demo user system account.
ARG APP_USER="demo-user"
ARG APP_GROUP="demo-user"
ARG APP_HOME_DIR="/home/demo-user"
RUN set -x && \
    groupadd "$APP_GROUP" && \
    useradd \
      --comment "Demo app system account" \
      --home-dir "$APP_HOME_DIR" \
      --create-home \
      --system \
      --gid "$APP_GROUP" \
      "$APP_USER"

# Create directory for app source code.
ARG APP_ROOT="/srv/demo-app"
RUN mkdir --parents "$APP_ROOT" && \
    chown \
      --no-dereference \
      --recursive \
      "${APP_USER}:${APP_GROUP}" "$APP_ROOT"

USER "$APP_USER"
WORKDIR "$APP_ROOT"

# Install demo app.
ARG DEMO_APP_REPO="https://github.com/mtlynch/flask_upload_demo"
RUN set -x && \
    git clone "$DEMO_APP_REPO" . && \
    virtualenv VIRTUAL && \
    . VIRTUAL/bin/activate && \
    pip install --requirement requirements.txt

EXPOSE 5000

# Run demo app.
ENV FLASK_APP "demo/app.py"
CMD virtualenv VIRTUAL && \
    . VIRTUAL/bin/activate && \
    flask run --host=0.0.0.0 --port=5000
