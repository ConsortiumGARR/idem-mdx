########################
Istruzioni per IDEM MDX
########################

Le seguenti istruzioni devono essere utilizzate per recuperare i metadata dal servizio IDEM MDX.

Per tutte le configurazioni e' stato scelto un valore di durata della cache pari a 1 ora (3600 secondi). Questa scelta e' stata effettuata tenendo conto che tutti i metadata vengono firmati ogni ora ed il campo *validUntil* all'interno del file di metadata e' pari a 48 ore.

Per quanto riguarda Shibboleth, e' stato inserito un valore di *maxCacheDuration* pari a 48 ore (172800 secondi), con un valore di *refreshDelayFactor* pari a 0,025 al fine di ottenere, in caso di cambiamenti, l'aggiornamento dei metadata ogni ora, come per le altre configurazioni.

Le configurazioni formulano implicitamente una URL conforme al Metadata Query Protocol partendo dall'URL di base specificato.

Ad esempio, se l'**entityID** e' https://wiki.idem.garr.it/rp, il provider richiedera' la seguente risorsa:

      https://mdx.idem.garr.it/idem/entities/https:%2F%2Fwiki.idem.garr.it%2Frp

.. warning::
   Cambia la URL di base rispetto al flusso di metadata di cui hai bisogno:

   * "https://mdx.idem.garr.it/idem/" per la Federatione IDEM
   * "https://mdx.idem.garr.it/edugain/" per l'Interfederazione IDEM + eduGAIN
   * "https://mdx.idem.garr.it/idem-test/" per la Federazione IDEM di Test


Shibboleth IdP v.3.1+
======================

Configura l'IdP per scaricare i Metadata della Federazione:
-------------------------------------------------------------

1. Scarica il certificato della Federazione per verificare i metadata firmati:

.. code-block:: bash

   wget https://mdx.idem.garr.it/idem-mdx-service-crt.pem -O /opt/shibboleth-idp/credentials/idem-mdx-service-crt.pem

2. Controlla la validita' del certificato:

.. code-block:: bash

   cd /opt/shibboleth-idp/credentials

   openssl x509 -in idem-mdx-service-crt.pem -fingerprint -sha1 -noout

   (sha1: 46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95)

   openssl x509 -in idem-mdx-service-crt.pem -fingerprint -md5 -noout

   (md5: 5D:19:CC:AA:1E:63:E9:50:9D:C7:BE:99:60:0F:1F:96)


3. Modifica opportunamente il file *metadata-providers.xml*:

.. code-block:: default

   vim /opt/shibboleth-idp/conf/metadata-providers.xml

aggiungendo prima dell'ultimo *</MetadataProvider>* il seguente codice:

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
  

4. Effettua il reload del servizio *shibboleth.MetadataResolverService* per recuperare i Metadata:

.. code-block:: bash

   bash /opt/shibboleth-idp/bin/reload-service.sh -id shibboleth.MetadataResolverService


Shibboleth SP v3
================

Configura il SP per scaricare i Metadata della Federazione:
--------------------------------------------------------------

1. Scarica il certificato della Federazione per verificare i metadata firmati:

.. code-block:: bash

   wget https://mdx.idem.garr.it/idem-mdx-service-crt.pem -O /etc/shibboleth/idem-mdx-service-crt.pem

2. Controlla la validita' del certificato:

.. code-block:: bash

   cd /etc/shibboleth/

   openssl x509 -in idem-mdx-service-crt.pem -fingerprint -sha1 -noout

   (sha1: 46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95)

   openssl x509 -in idem-mdx-service-crt.pem -fingerprint -md5 -noout

   (md5: 5D:19:CC:AA:1E:63:E9:50:9D:C7:BE:99:60:0F:1F:96)

3. Modifica opportunamente il file *shibboleth2.xml*:

.. code-block:: bash

   vim /etc/shibboleth/shibboleth2.xml

aggiungendo prima dell'ultimo *</MetadataProvider>* il seguente codice:

.. code-block:: xml

   <!-- MDX Service -->

   <MetadataProvider type="MDQ" id="mdx" cacheDirectory="mdq-cache" 
             baseUrl="https://mdx.idem.garr.it/edugain/" maxCacheDuration="172800" 
             refreshDelayFactor="0.025" ignoreTransport="true">
       <MetadataFilter type="RequireValidUntil" maxValidityInterval="259200"/>
       <MetadataFilter type="Signature" certificate="idem-mdx-service-crt.pem"/>
   </MetadataProvider>

4. Effettua un restart del demone *shibd*:

.. code-block:: bash

   sudo systemctl restart shibd


SimpleSAMLphp v.1.14+
======================

Configura l'Identity Provider per scaricare i Metadata della Federazione:
--------------------------------------------------------------------------

1. Modifica opportunamente il file *config.php*:

.. code-block:: bash

   vim /var/simplesamlphp/config/config.php

andando a modificare la configurazione *metadata.sources* per aggiungere la fonte di metadata di MDQ:


.. code-block:: default

     'metadata.sources' => [
        ['type' => 'flatfile'],
        ['type' => 'mdq',
         'server' => 'https://mdx.idem.garr.it/edugain',
         'validateFingerprint' => '46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95',
         'cachedir' => '/var/simplesamlphp/mdq-cache',
         'cachelength' => 3600],
     ],

.. warning::
   E' necessario che il modulo **metarefresh** sia disabilitato e che non sia presente alcun file nella cartella */metadata* a meno che non sia il file *saml20-idp-hosted.php* contenente i metadata dell'IdP.

2. Crea la cartella *mdq-cache*:

.. code-block:: default

  sudo mkdir /var/simplesamlphp/mdq-cache
  chown www-data /var/simplesamlphp/mdq-cache

3. Rimuovi i file non necessari:

.. code-block:: default

  cd /var/simplesamlphp/metadata ; rm !(saml20-idp-hosted.php)


Configura il Service Provider per scaricare i Metadata della Federazione:
--------------------------------------------------------------------------

1. Modifica opportunamente il file *config.php*:

.. code-block:: bash

   vim /opt/simplesamlphp/config/config.php

andando a modificare la configurazione *metadata.sources* per aggiungere la fonte di metadata di MDQ:

.. code-block:: default

     'metadata.sources' => [
        ['type' => 'mdq',
         'server' => 'https://mdx.idem.garr.it/edugain',
         'validateFingerprint' => '46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95',
         'cachedir' => '/opt/simplesamlphp/mdq-cache',
         'cachelength' => 3600],
        ['type' => 'flatfile'],
     ],

.. warning::
   E' necessario che il modulo **metarefresh** sia disabilitato e che non sia presente alcun file nella cartella */metadata*, a meno che non sia il file *saml20-idp-remote.php* per il discovery service locale.

2. Crea la cartella *mdq-cache*:

.. code-block:: default

  sudo mkdir /opt/simplesamlphp/mdq-cache
  chown www-data /opt/simplesamlphp/mdq-cache


Satosa
=======

Configura IdP/SP per scaricare i Metadata della Federazione:
----------------------------------------------------------------

1. Scarica il certificato della Federazione per verificare i metadata firmati:

.. code-block:: bash

   wget https://mdx.idem.garr.it/idem-mdx-service-crt.pem -O /opt/satosa/etc/idem-mdx-service-crt.pem

2. Controlla la validita' del certificato:

.. code-block:: bash

   cd /opt/satosa/etc

   openssl x509 -in idem-mdx-service-crt.pem -fingerprint -sha1 -noout

   (sha1: 46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95)

   openssl x509 -in idem-mdx-service-crt.pem -fingerprint -md5 -noout

   (md5: 5D:19:CC:AA:1E:63:E9:50:9D:C7:BE:99:60:0F:1F:96)

3. Dipendentemente dalla configurazione utilizzata per Satosa (backends/frontends), modifica il file di configurazione:

3a. Backends

.. code-block:: bash

  vim /opt/satosa/etc/plugins/backends/saml2_backend.yaml

aggiungi il seguente codice per la configurazione dei metadata:

.. code-block:: default

   metadata:
      mdq: 
        - { url: "https://mdx.idem.garr.it/edugain/", 
           cert: idem-mdx-service-crt.pem, 
           freshness_period: P0Y0M0DT1H0M0S }

3b. Frontends

.. code-block:: bash

  vim /opt/satosa/etc/plugins/frontends/saml2_frontend.yaml

aggiungi il seguente codice per la configurazione dei metadata:

.. code-block:: default

   metadata:
      mdq: 
        - { url: "https://mdx.idem.garr.it/edugain/", 
           cert: idem-mdx-service-crt.pem, 
           freshness_period: P0Y0M0DT1H0M0S }

###################################################
Configurazione Embedded Discovery Service per MDX
###################################################

Qualora si facesse utilizzo di un Dicovery Service locale, per il servizio MDX e' necessario utilizzare una configurazione "ad hoc", le cui guide sono presenti di seguito.

Shibboleth EDS
===============

Configura l'EDS per l'utilizzo del file JSON della Federazione:
----------------------------------------------------------------

1. Crea una cartella per ricavare il file JSON dal Jason Web Token fornito dalla federazione:

.. code-block:: bash

   sudo mkdir /opt/idem_jwt_to_json

2. Scarica la chiave pubblica necessaria per la decodifica:

.. code-block:: bash
  
   sudo wget "https://mdx.idem.garr.it/idem-mdx-service-pubkey.pem" -O /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem

e controllane la validità:

.. code-block:: bash

   cd /opt/idem_jwt_to_json

   sudo openssl rsa -pubin -in idem-mdx-service-pubkey.pem -pubout -outform DER | openssl sha1 -c
   
   ((stdin)= 30:75:93:37:d0:05:55:19:9f:76:e1:5a:73:db:45:7f:5e:66:11:4b)

   sudo openssl rsa -pubin -in idem-mdx-service-pubkey.pem -pubout -outform DER | openssl md5 -c

   ((stdin)= 84:5f:69:99:c5:f6:bb:e6:5f:ff:32:39:9a:a6:bb:85)


3. Installa i moduli Python necessari per la decodifica (Python >= 3.9):

.. code-block:: bash

    sudo apt-get install python3-pip
    sudo pip install pyjwt pyjwt[crypto] pem requests

4. Scarica il file *decodeToken.py* nella cartella /opt/idem_jwt_to_json 
  
.. code-block:: bash

    cd /opt/idem_jwt_to_json
    sudo wget https://registry.idem.garr.it/idem-conf/shibboleth/IDP4/decodeToken.py
    sudo chmod +x decodeToken.py

che contiene il seguente blocco di codice:

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
      json_decoded = json.dumps(x, indent = 4, ensure_ascii=False)

      result_path = open(outputpath, "w", encoding="utf-8")
      result_path.write(json_decoded)
      result_path.close()

   if __name__ == "__main__":
      main(sys.argv[1:])
 

5. Inserisci all'interno del Crontab uno dei seguenti comandi, dipendentemente dal flusso di metadata utilizzato e dalla 'DocumentRoot' configurata (/var/www/html di default):

* Federazione IDEM di Produzione:
  
  .. code-block:: bash

   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/idem-token -o /var/www/html/idem-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1
   
* Interfederazione eduGAIN + IDEM:
  
  .. code-block:: bash
 
   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/edugain2idem-token -o /var/www/html/edugain2idem-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1

  versione senza loghi:

  .. code-block:: bash
 
   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/edugain2idem-token-nologo -o /var/www/html/edugain2idem-eds-nologo.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1

* Federazione IDEM di Test:
  
  .. code-block:: bash
 
   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/idem-test-token -o /var/www/html/idem-test-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1

.. note::
   Esempio di Crontab:

   \*/30 \* \* \* \*   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/edugain2idem-token -o /var/www/html/edugain2idem-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1


6. Modifica la configurazione di EDS:

.. code-block:: bash

  sudo vim /etc/shibboleth-ds/idpselect_config.js

cambiando il valore di *this.dataSource* con la posizione del file JSON (ad esempio, per eduGAIN + IDEM):

.. code-block:: bash

  this.dataSource='/edugain2idem-eds.json';

.. warning::
  
  Il valore *dataSource* corrisponde alla URL della sorgente di dati del Discovery Service che contiene tutti gli IdP. 
  Questa sorgente **DEVE** essere esposta dal web server del DS e, quindi, del Service Provider in cui viene integrato. All'interno di *this.dataSource* è possibile omettere sia il protocollo che la parte host del'URL (https://example.org).
  La sorgente di dati e' un file JSON. Lo schema di questo file e' definito in `EDSDetails <https://shibboleth.atlassian.net/wiki/spaces/DEV/pages/1120895097/EDSDetails>`_


SimpleSAMLphp
===============

Configura la creazione dei file necessari all'EDS:
----------------------------------------------------

1. Crea una cartella per ricavare il file JSON dal Jason Web Token fornito dalla federazione:

.. code-block:: bash

   sudo mkdir /opt/idem_jwt_to_php

2. Scarica la chiave pubblica necessaria per la decodifica:

.. code-block:: bash
  
   sudo wget "https://mdx.idem.garr.it/idem-mdx-service-pubkey.pem" -O /opt/idem_jwt_to_php/idem-mdx-service-pubkey.pem

e controllane la validità:

.. code-block:: bash

   cd /opt/idem_jwt_to_php

   sudo openssl rsa -pubin -in idem-mdx-service-pubkey.pem -pubout -outform DER | openssl sha1 -c
   
   ((stdin)= 30:75:93:37:d0:05:55:19:9f:76:e1:5a:73:db:45:7f:5e:66:11:4b)

   sudo openssl rsa -pubin -in idem-mdx-service-pubkey.pem -pubout -outform DER | openssl md5 -c

   ((stdin)= 84:5f:69:99:c5:f6:bb:e6:5f:ff:32:39:9a:a6:bb:85)


3. Installa i moduli Python necessari per la decodifica (Python >= 3.9):

.. code-block:: bash

    sudo apt-get install python3-pip
    sudo pip install pyjwt pyjwt[crypto] pem requests

4. Scarica il file *decodeToken.py* nella cartella /opt/idem_jwt_to_php
  
.. code-block:: bash

    cd /opt/idem_jwt_to_php
    sudo wget https://registry.idem.garr.it/idem-conf/shibboleth/IDP4/decodeToken.py
    sudo chmod +x decodeToken.py

che contiene il seguente blocco di codice:

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
      json_decoded = json.dumps(x, indent = 4, ensure_ascii=False)

      result_path = open(outputpath, "w", encoding="utf-8")
      result_path.write(json_decoded)
      result_path.close()

   if __name__ == "__main__":
      main(sys.argv[1:])


5. Scarica lo script per la conversione del file JSON in PHP:

.. code-block:: bash

    cd /opt/simplesamlphp
    sudo wget https://registry.idem.garr.it/idem-conf/simplesamlphp/SSP1/json_to_php_converter.php
    sudo chmod +x json_to_php_converter.php

 
che contiene il seguente blocco di codice: 

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

e modifica il valore *file_get_contents* dipendentemente dal flusso utilizzato:

  * Federazione IDEM di Produzione: */opt/idem_jwt_to_php/idem-eds.json*
   
  * Interfederazione eduGAIN + IDEM: */opt/idem_jwt_to_php/edugain2idem-eds.json*

  * Federazione IDEM di Test: */opt/idem_jwt_to_php/idem-test-eds.json*


6. Crea un cronjob per aggiornare i file:

.. code-block:: bash

    vim /etc/cron.d/eds-refresh

e aggiungi i seguenti jobs, dipendentemente dal flusso utilizzato:

* Federazione IDEM di Produzione:
  
.. code-block:: bash

   */30 * * * *	  root	/opt/idem_jwt_to_php/decodeToken.py -j https://mdx.idem.garr.it/idem-token -o /opt/idem_jwt_to_php/idem-eds.json -k /opt/idem_jwt_to_php/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_php/jwt_to_php.log 2>&1

   */30 * * * *   root	/usr/bin/php /opt/idem_jwt_to_php/json_to_php_converter.php 

   
* Interfederazione eduGAIN + IDEM:
  
.. code-block:: bash

   */30 * * * *   root	/opt/idem_jwt_to_php/decodeToken.py -j https://mdx.idem.garr.it/edugain2idem-token -o /opt/idem_jwt_to_php/edugain2idem-eds.json -k /opt/idem_jwt_to_php/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_php/jwt_to_php.log 2>&1

   */30 * * * *   root	/usr/bin/php /opt/idem_jwt_to_php/json_to_php_converter.php 

  
* Federazione IDEM di Test:
  
.. code-block:: bash

   */30 * * * *   root	/opt/idem_jwt_to_php/decodeToken.py -j https://mdx.idem.garr.it/idem-test-token -o /opt/idem_jwt_to_php/idem-test-eds.json -k /opt/idem_jwt_to_php/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_php/jwt_to_php.log 2>&1

   */30 * * * *   root	/usr/bin/php /opt/idem_jwt_to_php/json_to_php_converter.php



##############################
Aggregati di Metadata IDEM 
##############################

Nel caso in cui si voglia visualizzare l'aggregato di metadata, e' possibile scaricarlo di seguito: 

Federazione IDEM 
================

Aggregato per la Federazione IDEM: https://mdx.idem.garr.it/idem/entities

Interfederazione eduGAIN (+ IDEM)
==================================

Aggregato per l'interfederazione eduGAIN (+ IDEM): https://mdx.idem.garr.it/edugain/entities

Federazione IDEM Test
=====================

Aggregato per la Federazione IDEM di Test: https://mdx.idem.garr.it/idem-test/entities

##########
Downloads
##########

Certificato Firma Metadata
==========================
https://mdx.idem.garr.it/idem-mdx-service-crt.pem

Chiave Pubblica per decodifica JWT
===================================
https://mdx.idem.garr.it/idem-mdx-service-pubkey.pem
