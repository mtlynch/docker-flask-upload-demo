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

# Install nginx.
ARG NGINX_GROUP="www-data"
COPY nginx.conf /etc/nginx/sites-enabled/nginx.conf
RUN set -x && \
    apt-get install --yes \
      nginx \
      sudo && \
    rm /etc/nginx/sites-enabled/default && \
    usermod --append --groups "$NGINX_GROUP" "$APP_USER" && \
    echo "$APP_USER ALL=(ALL:ALL) NOPASSWD: /usr/sbin/nginx" >> /etc/sudoers

# Install gcsfuse.
ARG GCSFUSE_REPO="gcsfuse-stretch"
ARG GCS_MOUNT_ROOT="/mnt/gcsfuse"
RUN set -x && \
    apt-get install --yes --no-install-recommends \
    ca-certificates \
    curl && \
    echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" \
      | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
      | apt-key add -
RUN apt-get update
RUN set -x && \
    apt-get install --yes gcsfuse && \
    echo 'user_allow_other' > /etc/fuse.conf && \
    mkdir --parents "$GCS_MOUNT_ROOT" && \
    chown \
      --no-dereference \
      "${APP_USER}:${NGINX_GROUP}" "$GCS_MOUNT_ROOT"

# Create directory for app source code.
ARG APP_ROOT="/srv/demo-app"
RUN mkdir --parents "$APP_ROOT" && \
    chown \
      --no-dereference \
      --recursive \
      "${APP_USER}:${NGINX_GROUP}" "$APP_ROOT"

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

ENV GCS_BUCKET "REPLACE-WITH-YOUR-GCS-BUCKET-NAME"
ENV GCS_MOUNT_ROOT "$GCS_MOUNT_ROOT"
ENV APP_UPLOADS_DIR "${APP_ROOT}/demo/uploads"

# Run demo app.
CMD set -x && \
    sudo nginx && \
    gcsfuse \
      -o nonempty \
      -o allow_other \
      --implicit-dirs \
      "$GCS_BUCKET" "$GCS_MOUNT_ROOT" && \
    if [ ! -d "$APP_UPLOADS_DIR" ]; then \
      ln --symbolic "$GCS_MOUNT_ROOT" "$APP_UPLOADS_DIR"; \
    fi && \
    virtualenv VIRTUAL && \
    . VIRTUAL/bin/activate && \
    gunicorn \
      demo.app:app \
      --bind 127.0.0.1:5000 \
      --log-level info
