#!/bin/bash

docker build --build-arg be_cert_path=certs/be-dev/ \
    -f docker/idem-mdx-be/pyff/Dockerfile \
    -t mdx-pyff:dev .

docker build --build-arg key_path=certs/be-dev/ \
    --build-arg mdx_key=pyff-dev.key \
    -f docker/idem-mdx-be/crsync/Dockerfile \
    -t mdx-crsync:dev .

docker build -f docker/idem-mdx-fe/nginx/Dockerfile-dev -t mdx-nginx:dev .

