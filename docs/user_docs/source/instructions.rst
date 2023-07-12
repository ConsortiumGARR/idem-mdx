#####################
IDEM MDX Instructions
#####################

The following instructions are meant to be used to retrive metadata by the IDEM MDX service.

For all the configuration a cache duration value of 1 hour (3600 seconds) is chosen. This choice was made taking into account that all the metadata are signed every hour and the validUntil field in the metadata file is 48 hours. 

For Shibboleth, we set a maxCacheDuration value equal to 48 hours (172800 seconds), with a refreshDelayFactor of 0.025 to get in case of changes the metadata refresh every hour, like the other configurations.

The configurations implicitly formulates a Metadata Query Protocol URL from the given baseURL.

For example, if the **entityID** is https://wiki.idem.garr.it/rp, the provider will request the following resource:

      https://mdx.idem.garr.it/idem/entities/https:%2F%2Fwiki.idem.garr.it%2Frp

.. warning::
   Change the baseURL according to the metadata stream you need:

   * "https://mdx.idem.garr.it/idem/" for IDEM Federation
   * "https://mdx.idem.garr.it/edugain/" for IDEM + eduGAIN Interfederation
   * "https://mdx.idem.garr.it/idem-test/" for IDEM Test Federation


Shibboleth IdP v.3.1+
======================

Configure the IdP to retrieve the Federation Metadata:
------------------------------------------------------

1. Retrieve the Federation Certificate used to verify signed metadata:

.. code-block:: bash

   wget https://mdx.idem.garr.it/idem-mdx-service-crt.pem -O /opt/shibboleth-idp/credentials/idem-mdx-service-crt.pem

2. Check the validity:

.. code-block:: bash

   cd /opt/shibboleth-idp/credentials

   openssl x509 -in idem-mdx-service-crt.pem -fingerprint -sha1 -noout

   (sha1: 46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95)

   openssl x509 -in idem-mdx-service-crt.pem -fingerprint -md5 -noout

   (md5: 5D:19:CC:AA:1E:63:E9:50:9D:C7:BE:99:60:0F:1F:96)


3. Edit *metadata-providers.xml* opportunely:

.. code-block:: default

   vim /opt/shibboleth-idp/conf/metadata-providers.xml

and add before the last *</MetadataProvider>* this piece of code:

.. code-block:: xml

    <!-- MDX Service -->

    <MetadataProvider id="DynamicEntityMetadata" xsi:type="DynamicHTTPMetadataProvider"
              connectionRequestTimeout="PT2S"
              connectionTimeout="PT2S"
              socketTimeout="PT4S"
              refreshDelayFactor="0.025"
              maxCacheDuration="PT48H">
        <!--
        Verify the signature on the root element of the metadata
        using a trusted metadata signing certificate.
        -->
        <MetadataFilter xsi:type="SignatureValidation" requireSignedRoot="true" 
                  certificateFile="%{idp.home}/credentials/idem-mdx-service-crt.pem"/>

        <!--
        Require a validUntil XML attribute on the root element and
        make sure its value is no more than 3 days into the future.
        -->
        <MetadataFilter xsi:type="RequiredValidUntil" maxValidityInterval="P3D"/>
        
        <!-- Base URL for MDQ -->
        <MetadataQueryProtocol>https://mdx.idem.garr.it/edugain/</MetadataQueryProtocol>
    </MetadataProvider>
  

4. Reload service with id *shibboleth.MetadataResolverService* to retrieve the Metadata:

.. code-block:: bash

   bash /opt/shibboleth-idp/bin/reload-service.sh -id shibboleth.MetadataResolverService


Shibboleth SP v3
================

Configure the SP to retrieve the Federation Metadata:
-----------------------------------------------------

1. Retrieve the Federation Certificate used to verify signed metadata:

.. code-block:: bash

   wget https://mdx.idem.garr.it/idem-mdx-service-crt.pem -O /etc/shibboleth/idem-mdx-service-crt.pem

2. Check the validity:

.. code-block:: bash

   cd /etc/shibboleth/

   openssl x509 -in idem-mdx-service-crt.pem -fingerprint -sha1 -noout

   (sha1: 46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95)

   openssl x509 -in idem-mdx-service-crt.pem -fingerprint -md5 -noout

   (md5: 5D:19:CC:AA:1E:63:E9:50:9D:C7:BE:99:60:0F:1F:96)

3. Edit *shibboleth2.xml* opportunely:

.. code-block:: bash

   vim /etc/shibboleth/shibboleth2.xml

and add before the last *</MetadataProvider>* this piece of code:

.. code-block:: xml

   <!-- MDX Service -->

   <MetadataProvider type="MDQ" id="mdx" cacheDirectory="mdq-cache" 
             baseUrl="https://mdx.idem.garr.it/edugain/" maxCacheDuration="172800" 
             refreshDelayFactor="0.025" ignoreTransport="true">
       <MetadataFilter type="RequireValidUntil" maxValidityInterval="259200"/>
       <MetadataFilter type="Signature" certificate="idem-mdx-service-crt.pem"/>
   </MetadataProvider>

4. Restart *shibd* daemon:

.. code-block:: bash

   sudo systemctl restart shibd


SimpleSAMLphp v.1.14+
====================================

Configure the Identity Provider to retrieve the Federation Metadata:
---------------------------------------------------------------------

1. Edit *config.php* opportunely:

.. code-block:: bash

   vim /var/simplesamlphp/config/config.php

by changing the SimpleSAMLphp configuration to load the new metadata provider:

.. code-block:: default

     'metadata.sources' => [
        ['type' => 'flatfile'],
        ['type' => 'mdq',
         'server' => 'https://mdx.idem.garr.it/edugain',
         'validateFingerprint' => '46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95',
         'cachedir' => '/var/simplesamlphp/mdq-cache',
         'cachelength' => 3600],
     ],

.. note::
   The **metarefresh** module needs to be disabled and the file *saml20-idp-hosted.php* needs to be the only file in the */metadata* folder.

2. Create the *mdq-cache* folder:

.. code-block:: default
  
  sudo mkdir /var/simplesamlphp/mdq-cache
  chown www-data /var/simplesamlphp/mdq-cache

3. Remove not needed files:

.. code-block:: default

  cd /var/simplesamlphp/metadata ; rm !(saml20-idp-hosted.php)


Configure the Service Provider to retrieve the Federation Metadata:
--------------------------------------------------------------------

1. Edit *config.php* opportunely:

.. code-block:: bash

   vim /var/simplesamlphp/config/config.php

by changing the SimpleSAMLphp configuration to load the new metadata provider:

.. code-block:: default

     'metadata.sources' => [
        ['type' => 'mdq',
         'server' => 'https://mdx.idem.garr.it/edugain',
         'validateFingerprint' => '46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95',
         'cachedir' => '/var/simplesamlphp/mdq-cache',
         'cachelength' => 3600],
        ['type' => 'flatfile'],
     ],

.. warning::
   The **metarefresh** module needs to be disabled and no file should be present in the */metadata* folder, unless it is the *saml20-idp-remote.php* file for the embedded discovery service.

2. Create the *mdq-cache* folder:

.. code-block:: default
  
  sudo mkdir /var/simplesamlphp/mdq-cache
  chown www-data /var/simplesamlphp/mdq-cache

Satosa
=======

Configure the IdP/SP to retrieve the Federation Metadata:
---------------------------------------------------------

1. Retrieve the Federation Certificate used to verify signed metadata:

.. code-block:: bash

   wget https://mdx.idem.garr.it/idem-mdx-service-crt.pem -O /opt/satosa/etc/idem-mdx-service-crt.pem

2. Check the validity:

.. code-block:: bash

   cd /opt/satosa/etc

   openssl x509 -in idem-mdx-service-crt.pem -fingerprint -sha1 -noout

   (sha1: 46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95)

   openssl x509 -in idem-mdx-service-crt.pem -fingerprint -md5 -noout

   (md5: 5D:19:CC:AA:1E:63:E9:50:9D:C7:BE:99:60:0F:1F:96)

3. Depending on your configuration (backends/frontends), edit the configuration file:

3a. Backends

.. code-block:: bash

  vim /opt/satosa/etc/plugins/backends/saml2_backend.yaml

and add the following configuration for metadata:

.. code-block:: default

   metadata:
      mdq: 
        - { url: "https://mdx.idem.garr.it/edugain/", 
           cert: idem-mdx-service-crt.pem, 
           freshness_period: P0Y0M0DT1H0M0S }

3b. Frontends

.. code-block:: bash

  vim /opt/satosa/etc/plugins/frontends/saml2_frontend.yaml

and add the following configuration for metadata:

.. code-block:: default

    metadata:
      mdq: 
        - { url: "https://mdx.idem.garr.it/idem-test/", 
           cert: idem-mdx-service-crt.pem, 
           freshness_period: P0Y0M0DT1H0M0S }


#############################################
MDX Embedded Discovery Service Configuration
#############################################

If an embedded Discovery Service is used, an "ad hoc" configuration must be used for the MDX service. Here you find the guides for its configuration.

Shibboleth EDS
===============

Configure the EDS to use the Federation JSON file:
---------------------------------------------------------

1. Create the folder to obtain the JSON file from the Jason Web Token:

.. code-block:: bash

   sudo mkdir /opt/idem_jwt_to_json

2. Retrieve the public key needed to decode:

.. code-block:: bash

   sudo wget "https://mdx.idem.garr.it/idem-mdx-service-pubkey.pem" -O /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem


and check the validity:

.. code-block:: bash

   cd /opt/idem_jwt_to_json

   sudo openssl rsa -pubin -in idem-mdx-service-pubkey.pem -pubout -outform DER | openssl sha1 -c
   
   ((stdin)= 30:75:93:37:d0:05:55:19:9f:76:e1:5a:73:db:45:7f:5e:66:11:4b)

   sudo openssl rsa -pubin -in idem-mdx-service-pubkey.pem -pubout -outform DER | openssl md5 -c

   ((stdin)= 84:5f:69:99:c5:f6:bb:e6:5f:ff:32:39:9a:a6:bb:85)


3. Install the needed Python modules (Python >= 3.9):

.. code-block:: bash

   sudo apt-get install python3-pip
   sudo pip install pyjwt pyjwt[crypto] pem requests

4. Retrieve the *decodeToken.py* file in the /opt/idem_jwt_to_json folder
   
.. code-block:: bash

   cd /opt/idem_jwt_to_json
   sudo wget https://registry.idem.garr.it/idem-conf/shibboleth/IDP4/decodeToken.py
   sudo chmod +x decodeToken.py
  
which contains the following code block:

.. code-block:: bash

   #!/usr/bin/env python3

   import jwt
   import json
   import pem
   import sys, getopt
   import requests

   def main(argv):
      try:
          opts, args = getopt.getopt(sys.argv[1:], 'j:o:k:hd', ['jwt=','output=','publickey=','help','debug' ])
      except getopt.GetoptError as err:
         print (str(err))
         print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
         print ("The JSON file will be put in the output directory")
         sys.exit(2)

      inputurl = None
      outputpath = None
      publickey = None

      for opt, arg in opts:
         if opt in ('-h', '--help'):
            print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
            print ("The JSON file will be put in the output directory")
            sys.exit()
         elif opt in ('-j', '--jwt'):
            inputurl = arg
         elif opt in ('-o', '--output'):
            outputpath = arg
         elif opt in ('-k', '--publickey'):
            publickey = arg
         elif opt == '-d':
            global _debug
            _debug = 1
         else:
            print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
            print ("The JSON file will be put in the output directory")
            sys.exit()

      if inputurl == None:
         print ("Token file is missing!\n")
         print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
         sys.exit()

      if outputpath == None:
         print ("Output path is missing!\n")
         print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
         sys.exit()

      if publickey == None:
         print ("Public Key path is missing!\n")
         print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
         sys.exit()

      with open(publickey, 'r') as rsa_pubkey:
          pubkey = rsa_pubkey.read()

      jwt_token = requests.get(inputurl, allow_redirects=True)
      token = jwt_token.content
      decode = jwt.decode(token, pubkey, algorithms=["RS256"])

      x = decode["data"]
      json_decoded = json.dumps(x, indent=4, ensure_ascii=False)

      result_path = open(outputpath, "w", encoding="utf-8")
      result_path.write(json_decoded)
      result_path.close()

   if __name__ == "__main__":
      main(sys.argv[1:])


5. Insert one of the following commands in the Crontab, according to the metadata stream used and the Discovery Service location (default /var/www/html):

* IDEM Production Federation:

  .. code-block:: bash

   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/idem-token -o /var/www/html/idem-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1

* eduGAIN + IDEM Interfederation:

  .. code-block:: bash

   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/edugain2idem-token -o /var/www/html/edugain2idem-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1

  version without logos:

  .. code-block:: bash

   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/edugain2idem-token-nologo -o /var/www/html/edugain2idem-eds-nologo.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1

* IDEM Test Federation:

  .. code-block:: bash

   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/idem-test-token -o /var/www/html/idem-test-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1

  
.. note::
   Example Crontab:

   \*/30 \* \* \* \*   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/edugain2idem-token -o /var/www/html/edugain2idem-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1


6. Modify the EDS configuration:

.. code-block:: bash

  sudo vim /etc/shibboleth-ds/idpselect_config.js

by changing the value of *this.dataSource* with the json file location (e.g. for eduGAIN interfederation):

.. code-block:: bash

  this.dataSource='/edugain2idem-eds.json';

.. warning::
  
  The *dataSource* is the URL of the source of the data feed of IdPs to the Discovery Service. 
  This feed **MUST** be at the same location as the DS itself and so it is usual for the protocol and host part of the URL (https://example.org) to be dropped.
  
  The data source is a JSON file. The schema of this file is defined in `EDSDetails <https://shibboleth.atlassian.net/wiki/spaces/DEV/pages/1120895097/EDSDetails>`_


SimpleSAMLphp
===============

Configure the creation of EDS's files:
----------------------------------------------------

1. Create the folder to obtain the JSON file from the Jason Web Token:

.. code-block:: bash

   sudo mkdir /opt/idem_jwt_to_php

2. Retrieve the public key needed to decode:

.. code-block:: bash

   sudo wget "https://mdx.idem.garr.it/idem-mdx-service-pubkey.pem" -O /opt/idem_jwt_to_php/idem-mdx-service-pubkey.pem


and check the validity:

.. code-block:: bash

   cd /opt/idem_jwt_to_php

   sudo openssl rsa -pubin -in idem-mdx-service-pubkey.pem -pubout -outform DER | openssl sha1 -c
   
   ((stdin)= 30:75:93:37:d0:05:55:19:9f:76:e1:5a:73:db:45:7f:5e:66:11:4b)

   sudo openssl rsa -pubin -in idem-mdx-service-pubkey.pem -pubout -outform DER | openssl md5 -c

   ((stdin)= 84:5f:69:99:c5:f6:bb:e6:5f:ff:32:39:9a:a6:bb:85)

3. Install the needed Python modules (Python >= 3.9):

.. code-block:: bash

    sudo apt-install python3-pip
    sudo pip install pyjwt pyjwt[crypto] pem requests

4. Retrieve the *decodeToken.py* file in the /opt/idem_jwt_to_php folder
   
.. code-block:: bash

   cd /opt/idem_jwt_to_php
   sudo wget https://registry.idem.garr.it/idem-conf/shibboleth/IDP4/decodeToken.py
   sudo chmod +x decodeToken.py
  

which contains the following code block:

.. code-block:: bash

   #!/usr/bin/env python3

   import jwt
   import json
   import pem
   import sys, getopt
   import requests

   def main(argv):
      try:
          opts, args = getopt.getopt(sys.argv[1:], 'j:o:k:hd', ['jwt=','output=','publickey=','help','debug' ])
      except getopt.GetoptError as err:
         print (str(err))
         print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
         print ("The JSON file will be put in the output directory")
         sys.exit(2)

      inputurl = None
      outputpath = None
      publickey = None

      for opt, arg in opts:
         if opt in ('-h', '--help'):
            print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
            print ("The JSON file will be put in the output directory")
            sys.exit()
         elif opt in ('-j', '--jwt'):
            inputurl = arg
         elif opt in ('-o', '--output'):
            outputpath = arg
         elif opt in ('-k', '--publickey'):
            publickey = arg
         elif opt == '-d':
            global _debug
            _debug = 1
         else:
            print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
            print ("The JSON file will be put in the output directory")
            sys.exit()

      if inputurl == None:
         print ("Token file is missing!\n")
         print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
         sys.exit()

      if outputpath == None:
         print ("Output path is missing!\n")
         print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
         sys.exit()

      if publickey == None:
         print ("Public Key path is missing!\n")
         print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
         sys.exit()

      with open(publickey, 'r') as rsa_pubkey:
          pubkey = rsa_pubkey.read()

      jwt_token = requests.get(inputurl, allow_redirects=True)
      token = jwt_token.content
      decode = jwt.decode(token, pubkey, algorithms=["RS256"])

      x = decode["data"]
      json_decoded = json.dumps(x, indent=4, ensure_ascii=False)

      result_path = open(outputpath, "w", encoding="utf-8")
      result_path.write(json_decoded)
      result_path.close()

   if __name__ == "__main__":
      main(sys.argv[1:])

5. Retrieve the script to convert JSON file to PHP:

.. code-block:: bash

    cd /opt/idem_jwt_to_php
    sudo wget https://registry.idem.garr.it/idem-conf/simplesamlphp/SSP1/json_to_php_converter.php
    sudo chmod +x json_to_php_converter.php
 

which contains the following code block:

.. code-block:: bash

    <?php
      $jsondata = file_get_contents('/opt/idem_jwt_to_php/edugain2idem-eds.json');

    if (!empty($jsondata)) {
      $entities = json_decode($jsondata, true);
      $text = '';
      $displaynames = '';

      foreach ($entities as $entity => $entityMetadata) {

          // remove the unused elements of json
          unset($entityMetadata['Logos']);

          $entityMetadata['entityid'] = $entityMetadata['entityID'];
          unset($entityMetadata['entityID']);

          $displaynames = $entityMetadata['DisplayNames'];
          unset($entityMetadata['DisplayNames']);

          if (!empty($displaynames)) {
                  $entityMetadata['name'] = array();

                  foreach ($displaynames as $displayname => $entityName) {

                          $entityMetadata['name'][$entityName['lang']] = $entityName['value'];

                  }
          }
          $text .= '$metadata['.var_export($entityMetadata['entityid'], true).'] ='.
                  var_export($entityMetadata, true).";\n";

          $entities = $text;
        }
    }

    $file = '/opt/simplesamlphp/metadata/saml20-idp-remote.php';
    file_put_contents($file,"<?php\n");
    file_put_contents($file, print_r($entities, true),FILE_APPEND);
    ?>

 
and change the *file_get_contents* value according to your configuration:

  * IDEM Production Federation: */opt/idem_jwt_to_php/idem-eds.json*
   
  * eduGAIN + IDEM Interfederation: */opt/idem_jwt_to_php/edugain2idem-eds.json*

  * IDEM Test Federation: */opt/idem_jwt_to_php/idem-test-eds.json*


6. Create a cronjob to refresh files:

.. code-block:: bash

    vim /etc/cron.d/eds-refresh

and add the following jobs, according to your configuration:

* IDEM Production Federation:
  
.. code-block:: bash

   */30 * * * *   root	/opt/idem_jwt_to_php/decodeToken.py -j https://mdx.idem.garr.it/idem-token -o /opt/idem_jwt_to_php/idem-eds.json -k /opt/idem_jwt_to_php/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_php/jwt_to_php.log 2>&1

   */30 * * * *   root	/usr/bin/php /opt/idem_jwt_to_php/json_to_php_converter.php 

   
* eduGAIN + IDEM Interfederation:
  
.. code-block:: bash

   */30 * * * *   root	/opt/idem_jwt_to_php/decodeToken.py -j https://mdx.idem.garr.it/edugain2idem-token -o /opt/idem_jwt_to_php/edugain2idem-eds.json -k /opt/idem_jwt_to_php/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_php/jwt_to_php.log 2>&1

   */30 * * * *   root	/usr/bin/php /opt/idem_jwt_to_php/json_to_php_converter.php 

* IDEM Test Federation:
  
.. code-block:: bash

   */30 * * * *   root	/opt/idem_jwt_to_php/decodeToken.py -j https://mdx.idem.garr.it/idem-test-token -o /opt/idem_jwt_to_php/idem-test-eds.json -k /opt/idem_jwt_to_php/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_php/jwt_to_php.log 2>&1

   */30 * * * *   root	/usr/bin/php /opt/idem_jwt_to_php/json_to_php_converter.php


##############################
IDEM Metadata Aggregates
##############################

If you want to check the aggregated metadata file, you can download it below:


IDEM Federation
================

Metadata aggregate for the IDEM Federation: https://mdx.idem.garr.it/idem/entities

eduGAIN (+ IDEM) Interfederation
=================================

Metadata aggregate for the eduGAIN (+ IDEM) Interfederation: https://mdx.idem.garr.it/edugain/entities

IDEM Test Federation
=====================

Metadata aggregate for the IDEM Test Federation: https://mdx.idem.garr.it/idem-test/entities


##########
Downloads 
##########

Signing Certificate of MDQ Metadata
===================================
https://mdx.idem.garr.it/idem-mdx-service-crt.pem

Public Key for decoding JWT
===============================
https://mdx.idem.garr.it/idem-mdx-service-pubkey.pem
