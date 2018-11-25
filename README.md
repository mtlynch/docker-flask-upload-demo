# Flask Upload Demo: Docker Image

[![Build Status](https://travis-ci.org/mtlynch/docker-flask-upload-demo.svg?branch=master)](https://travis-ci.org/mtlynch/docker-flask-upload-demo) [![Docker Pulls](https://img.shields.io/docker/pulls/mtlynch/flask-upload-demo.svg?maxAge=604800)](https://hub.docker.com/r/mtlynch/flask-upload-demo/) [![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](LICENSE)

# Overview

This is an example project that demonstrates how to package the [Flask Upload Demo App](https://github.com/mtlynch/flask_upload_demo) in a Docker container.

# Branches

Each branch demonstrates a slightly different scenario:

* [master](https://github.com/mtlynch/docker-flask-upload-demo): Demonstrates basic packaging of the demo app.
* [nginx](https://github.com/mtlynch/docker-flask-upload-demo/tree/nginx): Demonstrates a more realistic real-world architecture where nginx proxies traffic for the app.
* [gcsfuse](https://github.com/mtlynch/docker-flask-upload-demo/tree/gcsfuse): Demonstrates how to mount a Google Cloud Storage bucket from within the Docker container (assumes the container runs in a Google Compute Engine VM with read/write permissions to Google Cloud Storage).

# To run

## Basic version

```bash
docker run \
  --detach \
  --publish 80:5000 \
  mtlynch/flask-upload-demo:latest
```

App will be available at http://localhost/.

## Nginx version

```bash
docker run \
  --detach \
  --publish 80:80 \
  mtlynch/flask-upload-demo:nginx
```

App will be available at http://localhost/.
