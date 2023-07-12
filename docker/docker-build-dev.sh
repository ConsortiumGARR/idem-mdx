#!/bin/bash

docker build --build-arg be_cert_path=certs/be-dev/ \
    --build-arg pyff_cert_name=pyff-dev.crt \
    --build-arg pyff_privkey=pyff-dev.key \
    -f docker/idem-mdx-be/pyff/Dockerfile \
    -t mdx-pyff:dev .

docker build --build-arg key_path=certs/be-dev/ \
    --build-arg mdx_key=pyff-dev.key \
    -f docker/idem-mdx-be/crsync/Dockerfile \
    -t mdx-crsync:dev .

docker build --build-arg fe_cert_path=certs/fe-dev/ \
    -f docker/idem-mdx-fe/nginx/Dockerfile \
    -t mdx-nginx:dev .

