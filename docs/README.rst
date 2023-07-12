##########################
Development Instructions
##########################

Software requirements
========================

* The Software Requirements for this projects are: Python, Ansible and Vagrant.

* The development environment is based on Vagrant. 
  Vagrant can be downloaded at the following address: 
  
  * https://www.vagrantup.com/downloads.html 
   
  >NOTE: on Linux systems installation with deb/rpm package is recommended.

  * You should also install a vagrant provider, such as VirtualBox (https://www.virtualbox.org/ 
  - default).

* Retrieve the repository:
.. code::

   cd /opt
   git clone https://github.com/ConsortiumGARR/idem-mdx.git
   cd /opt/idem-mdx

* Ansible and the required packages can be installed by running the script inside the repository:
.. code::
   
   ./install_ansible.sh

* Docker and Docker Compose will be installed directly into the development VM.


Other requirements
--------

* A certificate pair: private key and certificate (used to sign the metadata with pyff)

* A SSH key pair: private key and public key (used to rsync files between different hosts)

* A SSL certificate pair: private key and certificate (used in nginx for HTTPS)

  >NOTE: certificates pairs and ssh keys are already provided for the development environment, 
  DO NOT USE THEM in production or staging environments.


Build and Run Docker Images
============================

Setup
------------

1. The /opt/idem-mdx/certs folder already contains all the keys and certs needed.
   If you want, you can copy/move your own certificates into the /opt/idem-mdx/certs/ folder.

2. Move to the idem-mdx folder and create the vm with vagrant:

.. code::

   cd /opt/idem-mdx
   vagrant up

>NOTE: the vagrant vm comes with ansible already installed. Please also ignore the warnings 
about `no-binary-enable-wheel-cache` and "Running pip as the 'root' user".

3. Log into the vagrant machine:

.. code::

   vagrant ssh mdx-dev
   cd /idem-mdx

4. Install docker on Vagrant VM:

.. code::

   ansible-playbook ansible/playbook-dev.yml -i ansible/inventories/dev/inventory.ini --tags install-docker

5. (Optional) Enable docker for non root user:

   5.1. Disconnect from the Vagrant machine:

   .. code::

      exit


   5.2. Reload the Vagrant machine: 

   .. code::

      vagrant reload mdx-dev

   5.3. Log into the Vagrant machine:

   .. code::

      vagrant ssh mdx-dev
      cd /idem-mdx


Build and Run docker images:
-----------------------------

4. You can build your own images (one image at time), or build the default images by running a script

4.1. Build one image at time:

4.1.1. Backend:

* PyFF: 
.. code::
   
   sudo docker build --build-arg be_cert_path=<INSERT-CERTS-PATH> \
       --build-arg pyff_cert_name=<INSERT-CERT-NAME> \
       --build-arg pyff_privkey=<INSERT-KEY-NAME> \
       -f docker/idem-mdx-be/pyff/Dockerfile \
       -t mdx-pyff:<CHOOSE-A-TAG-VERSION> .

using default settings:

.. code::

   sudo docker build --build-arg be_cert_path=certs/be-dev \
       --build-arg pyff_cert_name=pyff-dev.crt \
       --build-arg pyff_privkey=pyff-dev.key \
       -f docker/idem-mdx-be/pyff/Dockerfile \
       -t mdx-pyff:dev .


* cron and rsync: 
.. code::
   
   sudo docker build --build-arg key_path=<INSERT-CERTS-PATH> \
       --build-arg mdx_key=<MDX-PRIV_KEY-NAME> \
       -f docker/idem-mdx-be/crsync/Dockerfile \
       -t mdx-crsync:<CHOOSE-A-TAG-VERSION> .

using default settings:

.. code::

   sudo docker build --build-arg key_path=certs/be-dev \
       --build-arg mdx_key=pyff-dev.key \
       -f docker/idem-mdx-be/crsync/Dockerfile \
       -t mdx-crsync:dev .

4.1.2. Frontend:

* Nginx: 
.. code::
   
   sudo docker build --build-arg fe_cert_path=<INSERT-CERTS-PATH> \
       -f docker/idem-mdx-fe/nginx/Dockerfile \
       -t mdx-nginx:<CHOOSE-A-TAG-VERSION> .

using default settings:

.. code::
   
   sudo docker build --build-arg fe_cert_path=certs/fe-dev \
       -f docker/idem-mdx-fe/nginx/Dockerfile \
       -t mdx-nginx:dev .


4.2. Build all the images with the default settings by running the script:

.. code::

   sudo sh /idem-mdx/docker/docker-build-dev.sh


5. Run the docker instances with ansible:

.. code::

   ansible-playbook ansible/playbook-dev.yml -i ansible/inventories/dev/inventory.ini

>NOTE: You can run only the Backend part or the Frontend part, inserting the tag in the Ansible command, and using respectively: *docker-be* or *docker-fe*.


6. You can retireve the metadata of a resource (for example, https://wiki.idem.garr.it/rp)

   at the URL:

     https://192.168.56.10/idem/entities/https:%2F%2Fwiki.idem.garr.it%2Frp

   or performing a cURL:

     curl -k https://192.168.56.10/idem/entities/https:%2F%2Fwiki.idem.garr.it%2Frp


7. Monitor and debug

All the docker instances are configured to send logs to standard output, so for example to monitor 
the pyff backend give the command:

.. code::

   docker logs -f mdx-be-local-pyff
