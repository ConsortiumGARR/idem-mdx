##############################
IDEM MDX Back End requirements
##############################

The IDEM MDX Back End (BE) component is responsible for consuming the IDEM metadata and provide
an MDQ service to the IDEM MDX Front End component.

Requirements
============

The IDEM MDX BE will be implemented according to the following requirements.

Incoming Metadata
-----------------

- Consume the feed of the aggregate of the metadata of the IDEM Production Federation through
  the endpoint provided by the current IDEM MDA service:

  - http://md.idem.garr.it/metadata/idem-metadata-sha256.xml

- Consume the feed of the aggregate of the metadata of the IDEM Production and eduGAIN Federation
  through the endpoint by the current IDEM MDA service:
  
  - http://md.idem.garr.it/metadata/edugain2idem-metadata-sha256.xml

- Consume the feed of the aggregate of the metadata of the IDEM Test Federation through
  the endpoint provided by the current IDEM MDA service:

  - http://md.idem.garr.it/metadata/idem-test-metadata-sha256.xml
    
- Both incoming feeds signatures are verified against the corresponding certificate:
  
  - https://md.idem.garr.it/certs/idem-signer-20220121.pem
    
- Both incoming feeds are validated with a simple stylesheet that provides only XML linting and
  entities ordering. No further validation is needed as both feeds has been already extensivily
  validated by the IDEM MDA service.
- Both feeds are consumed on a hourly base.

MDQ service
-----------

- Full implementation of the SAML Profile for the Metadata Query Protocol
  [draft-young-md-query-saml-15]
- The MDQ service is provided on three different endpoints:
  
  - IDEM Production Federation MDQ.
  - IDEM Production Federation and eduGAIN MDQ.
  - IDEM Test Federation MDQ.

- Standard MDQ queries are supported on the defined endpoints.
- The entities metadata provided by the MDQ service are also hourly signed (see Keys and signing
  for details) and exported to XML files named after the base64 version of the SHA1 hashing of
  the entityID.
- Entities metadata are valid until the next 48 hours.

Keys and signing
----------------

- The metadata produced by the service use a dedicated key pair named with following scheme:

  - idem-mdq-service-[key|crt]-ISSUING-DATE.pem
  
- The key pair is created on a secure host.
- The key maintained on the repository of the project is protected with a passphrase. 
- The key deployed to the MDQ service is password-less. 
- Every entity metadata provided by the service is signed with the MDQ key.

Networking
----------

- The service host have only one interface on a private network that os available for
  incoming connections from the public internet through NAT or other mechanisms.
- The service host is to communicate with hosts on the public internet only through
  connections originated on the host itself. 
- All the services published on the IDEM MDX BE respect the above requirements.

MDQ Frontend publishing
-----------------------

- Entities metadata XML files are pushed to the MDQ Frontend nodes every hour.
  
Deployment
----------

- Docker image deployed on a container hosting node.
- The docker image has no external dependencies (files, volumes, etc).
