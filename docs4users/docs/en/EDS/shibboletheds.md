# Shibboleth EDS

DOC: <https://shibboleth.atlassian.net/wiki/spaces/EDS10/overview>

#### 1. Setup folder

Create the folder to obtain the JSON file from the JSON Web Token (JWT):

``` bash
sudo mkdir /opt/idem_jwt_to_json
```

#### 2. Retrieve IDEM Public key

Retrieve the public key needed to decode:

``` bash
sudo wget "https://mdx.idem.garr.it/idem-mdx-service-pubkey.pem" -O /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem
```

and check the validity:

- SHA1:

    ``` bash
    sudo openssl rsa -pubin -in /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem -pubout -outform DER | openssl sha1 -c
    ```

    will give:

    `((stdin)= 30:75:93:37:d0:05:55:19:9f:76:e1:5a:73:db:45:7f:5e:66:11:4b)`

- MD5:

    ``` bash
    sudo openssl rsa -pubin -in /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem -pubout -outform DER | openssl md5 -c
    ```

    will give:

    `((stdin)= 84:5f:69:99:c5:f6:bb:e6:5f:ff:32:39:9a:a6:bb:85)`

#### 3. Install the needed Python modules

- Python >= 3.9:

    - `sudo apt-get install python3-pip`

    - `sudo pip install pyjwt pyjwt[crypto] pem requests`

- Python >= 3.11:

    - `sudo apt-get install python3-jwt python3-requests python3-pem`

#### 4. Download the JWT decoding file

Retrieve the `decodeToken.py` file in the `/opt/idem_jwt_to_json` folder:

- `cd /opt/idem_jwt_to_json`

- `sudo wget https://mdx.idem.garr.it/decodeToken.py`

- `sudo chmod +x decodeToken.py`

which contains the following code block:

``` bash
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
        print ("Token file is missing!n")
        print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
        sys.exit()

    if outputpath == None:
        print ("Output path is missing!n")
        print ("Usage: ./decodeToken.py -j <jwt_inputurl> -o <output_path> -k <publickey_path>")
        sys.exit()

    if publickey == None:
        print ("Public Key path is missing!n")
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
```

#### 5. **[OPTIONAL]** Create a custom JSON

5.1. Retrieve the `eds-filter.py` file in the `/opt/idem_jwt_to_json` folder:

- `cd /opt/idem_jwt_to_json`

- `sudo wget https://mdx.idem.garr.it/eds-filter.py`

- `sudo chmod +x eds-filter.py`

which contains the following code block:

``` bash
#!/usr/bin/env python3

import json
import getopt
import sys

def main(argv):
    input_file = ''
    output_file = ''
    entity_ids_file = ''

    try:
        opts, args = getopt.getopt(argv, "hi:o:e:", ["input=", "output=", "entityids="])
    except getopt.GetoptError:
        print('Usage: filter_json.py -i <input_file> -o <output_file> -e <entity_ids_file>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('Usage: filter_json.py -i <input_file> -o <output_file> -e <entity_ids_file>')
            sys.exit()
        elif opt in ("-i", "--input"):
            input_file = arg
        elif opt in ("-o", "--output"):
            output_file = arg
        elif opt in ("-e", "--entityids"):
            entity_ids_file = arg

    if not input_file or not output_file or not entity_ids_file:
        print('Usage: filter_json.py -i <input_file> -o <output_file> -e <entity_ids_file>')
        sys.exit(2)

    # Leggi gli entityID dal file di testo
    with open(entity_ids_file, 'r', encoding='utf-8') as f:
        entity_ids_to_keep = [line.strip() for line in f]

    # Leggi il file JSON
    with open(input_file, 'r', encoding='utf-8') as file:
        data = json.load(file)

    # Filtra le entry mantenendo solo quelle con entityID presenti nella lista
    filtered_data = [entry for entry in data if entry['entityID'] in entity_ids_to_keep]

    # Scrivi i dati filtrati in un nuovo file JSON
    with open(output_file, 'w', encoding='utf-8') as file:
        json.dump(filtered_data, file, ensure_ascii=False, indent=4)

    print(f"Il file JSON è stato filtrato e salvato come '{output_file}'")

if __name__ == "__main__":
    main(sys.argv[1:])
```

5.2. Create a file called `entity_ids.txt` in the
`/opt/idem_jwt_to_json` folder, containing the list of entityIDs of the organizations you want to filter.
For example:

``` bash
https://idp.example.01.it/idp/shibboleth
https://idp.example.02.it/idp/shibboleth
http://idp.example.03.it/simplesaml/saml2/idp/metadata.php
```

#### 6. Create a cronjob to update JSON files

Create `eds-refresh` file:

``` bash
vim /etc/cron.d/eds-refresh
```

and, depending on the Metadata and the `DocumentRoot` used (default: `/var/www/html`),
add the following jobs:

- IDEM Production Federation **(complete)**:

    ``` bash
    */30 * * * *   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/idem-token -o /var/www/html/idem-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1 
    ```

- eduGAIN + IDEM Interfederation **(complete)**:

    ``` bash
    */30 * * * *   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/edugain2idem-token -o /var/www/html/edugain2idem-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1 
    ```

    version without logos ( **(complete)**:

    ``` bash
    */30 * * * *   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/edugain2idem-token-nologo -o /var/www/html/edugain2idem-eds-nologo.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1
    ```

- IDEM Test Federation **(complete)**:

    ``` bash
    */30 * * * *   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/idem-test-token -o /var/www/html/idem-test-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1
    ```

- IDEM Production Federation **(custom)**:

    ``` bash
    */30 * * * *   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/idem-token -o /opt/idem_jwt_to_json/idem-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1 

    */30 * * * *   /opt/idem_jwt_to_json/eds-filter.py -i /opt/idem_jwt_to_json/idem-eds.json -o /var/www/html/custom-eds.json -e /opt/idem_jwt_to_json/entity_ids.txt > /opt/idem_jwt_to_json/eds-filter.log 2>&1 
    ```

- eduGAIN + IDEM Interfederation **(custom)**:

    ``` bash
    */30 * * * *   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/edugain2idem-token -o /opt/idem_jwt_to_json/edugain2idem-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1 

    */30 * * * *   /opt/idem_jwt_to_json/eds-filter.py -i /opt/idem_jwt_to_json/edugain2idem-eds.json -o /var/www/html/custom-eds.json -e /opt/idem_jwt_to_json/entity_ids.txt > /opt/idem_jwt_to_json/eds-filter.log 2>&1 
    ```

- IDEM Test Federation **(custom)**:

    ``` bash
    */30 * * * *   /opt/idem_jwt_to_json/decodeToken.py -j https://mdx.idem.garr.it/idem-test-token -o /opt/idem_jwt_to_json/idem-test-eds.json -k /opt/idem_jwt_to_json/idem-mdx-service-pubkey.pem > /opt/idem_jwt_to_json/jwt_to_json.log 2>&1

    */30 * * * *   /opt/idem_jwt_to_json/eds-filter.py -i /opt/idem_jwt_to_json/idem-test-eds.json -o /var/www/html/custom-eds.json -e /opt/idem_jwt_to_json/entity_ids.txt > /opt/idem_jwt_to_json/eds-filter.log 2>&1 
    ```

#### 7. Configure EDS

Modify the EDS configuration:

``` bash
sudo vim /etc/shibboleth-ds/idpselect_config.js
```

by changing the value of `this.dataSource` with the appropriate value chosen from:

- IDEM Test Federation: `/idem-test-eds.json`
- IDEM Federation: `/idem-eds.json`
- eduGAIN: `/edugain2idem-eds.json`
- Custom JSON: `/custom-eds.json`

**Warning**: The value of `this.dataSource` is the URL of the source of
the data feed of IdPs to the Discovery Service. This feed **MUST** be at the same
location as the DS itself and so it is usual for the protocol and host part of
the URL (`https://example.org`) to be dropped. The data source is a JSON file.
The schema of this file is defined in [EDSDetails](https://shibboleth.atlassian.net/wiki/spaces/DEV/pages/1120895097/EDSDetails)
