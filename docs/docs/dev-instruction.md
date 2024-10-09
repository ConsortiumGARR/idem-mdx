# Development Instructions

## Software requirements

- The Software Requirements for this projects are: Python, Ansible and
    Vagrant.

- The development environment is based on Vagrant. Vagrant can be
    downloaded at the following address:

    - <https://www.vagrantup.com/downloads.html>

    *NOTE*: on Linux systems installation with deb/rpm package is
    recommended.

    - You should also install a vagrant provider, such as VirtualBox
        (<https://www.virtualbox.org/>).

- Retrieve the repository:

    ```bash
    cd /opt

    git clone https://gitlab.dir.garr.it/IDEM/idem-mdx.git

    cd /opt/idem-mdx
    ```

- Ansible and the required packages can be installed by running the
    script inside the repository:

    ```bash
    ./install_ansible.sh
    ```

- Docker and Docker Compose will be installed directly into the
    development VM.

### Other requirements

- A certificate pair: private key and certificate (used to sign the
    metadata with pyff)

- A SSH key pair: private key and public key (used to rsync files
    between different hosts)

- A SSL certificate pair: private key and certificate (used in nginx
    for HTTPS)

    *NOTE*: certificates pairs and ssh keys are already provided for the
    development environment, DO NOT USE THEM in production or staging
    environments.

## Build and Run Docker Images

### Setup

1. The /opt/idem-mdx/certs folder already contains all the keys and
    certs needed. If you want, you can copy/move your own certificates
    into the /opt/idem-mdx/certs/ folder.
2. Move to the idem-mdx folder and create the vm with vagrant:

    ```bash
    cd /opt/idem-mdx

    vagrant up
    ```

    *NOTE*: the vagrant vm comes with ansible already installed. Please also
    ignore the warnings about [no-binary-enable-wheel-cache] and
    *Running pip as the 'root' user*.

3. Log into the vagrant machine:

    ```bash
    vagrant ssh mdx-dev
    cd /idem-mdx
    ```

4. Install docker on Vagrant VM:

    ```bash
    ansible-playbook ansible/playbook-dev.yml -i ansible/inventories/dev/inventory.ini --tags install-docker
    ```

5. (Optional) Enable docker for non root user:

    5.1. Disconnect from the Vagrant machine:

    ```bash
    exit
    ```

    5.2. Reload the Vagrant machine:

    ```bash
    vagrant reload mdx-dev
    ```

    5.3. Log into the Vagrant machine:

    ```bash
    vagrant ssh mdx-dev
    cd /idem-mdx
    ```

### Build docker images

You can build your own images (one image at time), or build the default images by running a script.

- Build one image at time:

    - Backend:

        - PyFF:

        ```bash
        sudo docker build --build-arg be_cert_path=<INSERT-CERTS-PATH> \
            -f docker/idem-mdx-be/pyff/Dockerfile \
            -t mdx-pyff:<CHOOSE-A-TAG-VERSION> .
        ```

        using default settings:

        ```bash
        sudo docker build --build-arg be_cert_path=certs/be-dev \
            -f docker/idem-mdx-be/pyff/Dockerfile \
            -t mdx-pyff:dev .
        ```

        - cron and rsync:

        ```bash
        sudo docker build --build-arg key_path=<INSERT-CERTS-PATH> \
            --build-arg mdx_key=<MDX-PRIV_KEY-NAME> \
            -f docker/idem-mdx-be/crsync/Dockerfile \
            -t mdx-crsync:<CHOOSE-A-TAG-VERSION> .
        ```

        using default settings:

        ```bash
        sudo docker build --build-arg key_path=certs/be-dev \
            --build-arg mdx_key=pyff-dev.key \
            -f docker/idem-mdx-be/crsync/Dockerfile \
            -t mdx-crsync:dev .
        ```

    - Frontend:

        - Nginx:

        ```bash
        sudo docker build --build-arg fe_cert_path=<INSERT-CERTS-PATH> \
            -f docker/idem-mdx-fe/nginx/Dockerfile-dev \
            -t mdx-nginx:<CHOOSE-A-TAG-VERSION> .
        ```

        using default settings:

        ```bash
        sudo docker build --build-arg fe_cert_path=certs/fe-dev \
            -f docker/idem-mdx-fe/nginx/Dockerfile-dev \
            -t mdx-nginx:dev .
        ```

- Build all the images with the default settings by running the script:

    ```bash
    sudo sh /idem-mdx/docker/docker-build-dev.sh
    ```

### Run docker images

To Run all the images created, you need to launch the following Ansible command:

```bash
ansible-playbook ansible/playbook-dev.yml -i ansible/inventories/dev/inventory.ini
```

*NOTE*: You can run only the Backend part or the Frontend part,
inserting the tag in the Ansible command, and using respectively:
*docker-be* or *docker-fe*.

### Test the installation

You can retireve the metadata of a resource (for example, <https://wiki.idem.garr.it/rp>)

- at the URL:

    <https://192.168.56.10/idem/entities/https:%2F%2Fwiki.idem.garr.it%2Frp>

- performing a cURL:

    curl -k <https://192.168.56.10/idem/entities/https:%2F%2Fwiki.idem.garr.it%2Frp>

### Monitor and debug

All the docker instances are configured to send logs to standard output,
so for example to monitor the pyff backend give the command:

```bash
docker logs -f mdx-be-local-pyff
```
