FROM debian:stretch

RUN apt-get update
RUN apt-get install --yes \
      git-core \
      python \
      python-pip \
      python-virtualenv

# Information for demo user system account.
ARG APP_USER="demo-user"
ARG APP_GROUP="demo-user"
ARG APP_HOME_DIR="/home/demo-user"
ARG WWW_GROUP="www-data"

ARG APP_ROOT="/srv/demo-app"

RUN set -xe && \
    useradd \
      --comment "Demo app system account" \
      --home-dir "$APP_HOME_DIR" \
      --create-home \
      --system \
      --gid "$WWW_GROUP" \
      "$APP_USER" && \
    groupadd "$APP_GROUP" && \
    usermod --append --groups "$APP_GROUP" "$APP_USER" && \
    mkdir --parents "$APP_ROOT" && \
    chown \
      --no-dereference \
      --recursive \
      "${APP_USER}:${WWW_GROUP}" "$APP_ROOT"

USER "$APP_USER"
WORKDIR "$APP_ROOT"

ARG DEMO_APP_REPO="https://github.com/mtlynch/flask_upload_demo"
ARG DEMO_APP_BRANCH="master"
RUN set -x && \
    git clone "$DEMO_APP_REPO" . && \
    git checkout "$DEMO_APP_BRANCH" && \
    git submodule sync && \
    git submodule update --force --init --recursive && \
    virtualenv VIRTUAL && \
    . VIRTUAL/bin/activate && \
    pip install --requirement requirements.txt

# Clean up.
USER root
RUN apt-get remove --yes \
      git-core \
      python-pip && \
    rm -rf /var/lib/apt/lists/* && \
    rm -Rf /usr/share/doc && \
    rm -Rf /usr/share/man && \
    apt-get autoremove --yes && \
    apt-get clean

USER "$APP_USER"

EXPOSE 5000

ENV FLASK_APP="demo/app.py"
CMD virtualenv VIRTUAL && \
    . VIRTUAL/bin/activate && \
    flask run --host=0.0.0.0 --port=5000
