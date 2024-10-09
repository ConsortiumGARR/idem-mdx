# Staging/Production Instructions

## Setup

- Retrieve the repository:

    ```bash
    cd /opt

    git clone https://gitlab.dir.garr.it/IDEM/idem-mdx.git

    cd /opt/idem-mdx
    ```

- Retrieve the production inventory repository:

    ```bash
    cd /opt/idem-mdx

    git clone https://gitlab.dir.garr.it/IDEM/idem-mdx-inventories.git
    ```

## Build docker images

- Backend:

    - PyFF:

    ```bash
    sudo docker build --build-arg be_cert_path=<INSERT-CERTS-PATH> \
        -f docker/idem-mdx-be/pyff/Dockerfile \
        -t gitlab.dir.garr.it:4567/idem/idem-mdx/be-pyff:<CHOOSE-A-TAG-VERSION> .
    ```

    - cron and rsync:

    ```bash
    sudo docker build --build-arg key_path=<INSERT-CERTS-PATH> \
        --build-arg mdx_key=<MDX-PRIV_KEY-NAME> \
        -f docker/idem-mdx-be/crsync/Dockerfile \
        -t gitlab.dir.garr.it:4567/idem/idem-mdx/be-crsync:<CHOOSE-A-TAG-VERSION> .
    ```

- Frontend:

    - Nginx:

    ```bash
    sudo docker build -f docker/idem-mdx-fe/nginx/Dockerfile \
        -t gitlab.dir.garr.it:4567/idem/idem-mdx/fe-nginx:<CHOOSE-A-TAG-VERSION> .
    ```

## Run docker images

To Run all the images created, you need to launch the following Ansible command.

The inventories are vaulted and you can retrieve the secret vault here [Password GARR](https://password.dir.garr.it/):

- Staging:

    ```bash
    ansible-playbook ansible/playbook-staging.yml -i ansible/inventories/staging/inventory.ini --ask-vault-pass
    ```

- Production:

    ```bash
    ansible-playbook ansible/playbook-prod.yml -i idem-mdx-inventories/prod/inventory.ini --ask-vault-pass
    ```

*NOTE*: You can run only the Backend part or the Frontend part,
inserting the tag in the Ansible command, and using respectively:
*docker-be* or *docker-fe*.

### Test the installation

You can retireve the metadata of a resource (for example, <https://wiki.idem.garr.it/rp>)

- at the URL:

    https://<IP or DNS NAME\>/idem/entities/https%3A%2F%2Fwiki.idem.garr.it%2Frp

- performing a cURL:

    curl -k https://<IP or DNS NAME\>/idem/entities/https%3A%2F%2Fwiki.idem.garr.it%2Frp

### Monitor and debug

All the docker instances are configured to send logs to standard output,
so to the logs give the command:

```bash
docker logs -f <CONTAINER_NAME>
```
