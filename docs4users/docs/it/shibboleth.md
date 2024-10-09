# Configurazione su Shibboleth IdP/SP

## Shibboleth IdP v.3.1+

#### 1. Recupera il certificato della Federazione

Scarica il certificato della Federazione per verificare la firma posta sui metadata:

```bash
wget https://mdx.idem.garr.it/idem-mdx-service-crt.pem -O /opt/shibboleth-idp/credentials/idem-mdx-service-crt.pem
```

#### 2. Controllare la validità del certificato

- SHA1:

    ```bash
    openssl x509 -in /opt/shibboleth-idp/credentials/idem-mdx-service-crt.pem -fingerprint -sha1 -noout
    ```

    deve restituire:

    `(sha1: 46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95)`

- MD5:

    ```bash
    openssl x509 -in /opt/shibboleth-idp/credentials/idem-mdx-service-crt.pem -fingerprint -md5 -noout
    ```

    deve restituire:

    `(md5: 5D:19:CC:AA:1E:63:E9:50:9D:C7:BE:99:60:0F:1F:96)`

#### 3. Configurazione metadata providers

Modifica opportunamente il file di configurazione delle sorgenti di metadata SAML:

```bash
vim /opt/shibboleth-idp/conf/metadata-providers.xml
```

aggiungendo prima dell'ultimo `</MetadataProvider>` il seguente
codice, **commentando/decommentando** opportunamente il valore di
`<MetadataQueryProtocol>` dipendentemente dal flusso di Metadata
utilizzato:

```xml
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
    <!-- IDEM Production Federation -->
    <!-- <MetadataQueryProtocol>https://mdx.idem.garr.it/idem/</MetadataQueryProtocol> -->

    <!-- IDEM Test Federation -->
    <MetadataQueryProtocol>https://mdx.idem.garr.it/idem-test/</MetadataQueryProtocol>

    <!-- eduGAIN -->
    <!-- <MetadataQueryProtocol>https://mdx.idem.garr.it/edugain/</MetadataQueryProtocol> -->
</MetadataProvider>
```

#### 4. Riavvio dei servizi

Effettua il riavvio del servizio **shibboleth.MetadataResolverService**
per applicare la configurazione precedente:

```bash
bash /opt/shibboleth-idp/bin/reload-service.sh -id shibboleth.MetadataResolverService
```

## Shibboleth SP v3

#### 1. Recupera il certificato della Federazione

Scarica il certificato della Federazione per verificare la firma posta sui metadata:

```bash
wget https://mdx.idem.garr.it/idem-mdx-service-crt.pem -O /opt/shibboleth-idp/credentials/idem-mdx-service-crt.pem
```

#### 2. Controllare la validità del certificato

- SHA1:

    ```bash
    openssl x509 -in /opt/shibboleth-idp/credentials/idem-mdx-service-crt.pem -fingerprint -sha1 -noout
    ```

    deve restituire:

    `(sha1: 46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95)`

- MD5:

    ```bash
    openssl x509 -in /opt/shibboleth-idp/credentials/idem-mdx-service-crt.pem -fingerprint -md5 -noout
    ```

    deve restituire:

    `(md5: 5D:19:CC:AA:1E:63:E9:50:9D:C7:BE:99:60:0F:1F:96)`

#### 3. Configurazione shibboleth2.xml

Modifica opportunamente il file di configurazione principale:

```bash
vim /etc/shibboleth/shibboleth2.xml
```

aggiungendo prima dell'ultimo `</MetadataProvider>` il seguente codice:

```xml
<!-- MDX Service -->

<MetadataProvider type="MDQ" id="mdx" cacheDirectory="mdq-cache"
        baseUrl="https://mdx.idem.garr.it/idem-test/"            
        maxCacheDuration="172800" refreshDelayFactor="0.025" ignoreTransport="true">
    <MetadataFilter type="RequireValidUntil" maxValidityInterval="259200"/>
    <MetadataFilter type="Signature" certificate="idem-mdx-service-crt.pem"/>
</MetadataProvider>
```

e cambiando opportunamente il valore di **`baseUrl`** dipendentemente
dal flusso di Metadata utilizzato:

- Federazione IDEM di Test: `https://mdx.idem.garr.it/idem-test/`
- Federatione IDEM: `https://mdx.idem.garr.it/idem/`
- Interfederazione IDEM + eduGAIN:
    `https://mdx.idem.garr.it/edugain/`

#### 4. Riavvio dei servizi

Effettua un restart del demone `shibd`:

```bash
sudo systemctl restart shibd
```
