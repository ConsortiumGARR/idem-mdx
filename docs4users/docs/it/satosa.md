# Configurazione su Satosa

#### 1. Recupera il certificato della Federazione

Scarica il certificato della Federazione per verificare la firma posta sui metadata:

``` bash
wget https://mdx.idem.garr.it/idem-mdx-service-crt.pem -O /opt/satosa/etc/idem-mdx-service-crt.pem
```

#### 2. Controllare la validità del certificato

- SHA1:

    ```bash
    openssl x509 -in /opt/satosa/etc/idem-mdx-service-crt.pem -fingerprint -sha1 -noout
    ```

    deve restituire:

    `(sha1: 46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95)`

- MD5:

    ```bash
    openssl x509 -in /opt/satosa/etc/idem-mdx-service-crt.pem -fingerprint -md5 -noout
    ```

    deve restituire:

    `(md5: 5D:19:CC:AA:1E:63:E9:50:9D:C7:BE:99:60:0F:1F:96)`

#### 3. Configura SATOSA

Dipendentemente dalla configurazione utilizzata per Satosa
(backends/frontends), modifica il file di configurazione:

a. Backends

```bash
vim /opt/satosa/etc/plugins/backends/saml2_backend.yaml
```

aggiungendo il seguente codice per la configurazione dei metadata:

``` default
metadata:
    mdq: 
    - { url: "https://mdx.idem.garr.it/idem-test/", 
        cert: idem-mdx-service-crt.pem, 
        freshness_period: P0Y0M0DT1H0M0S }
```

e cambiando opportunamente il valore di `url` dipendentemente dal flusso di Metadata utilizzato:

- Federazione IDEM di Test: `https://mdx.idem.garr.it/idem-test/`
- Federatione IDEM: `https://mdx.idem.garr.it/idem/`
- Interfederazione IDEM + eduGAIN: `https://mdx.idem.garr.it/edugain/`

b. Frontends

``` bash
vim /opt/satosa/etc/plugins/frontends/saml2_frontend.yaml
```

aggiungendo il seguente codice per la configurazione dei
metadata:

``` default
metadata:
    mdq: 
    - { url: "https://mdx.idem.garr.it/idem-test/", 
        cert: idem-mdx-service-crt.pem, 
        freshness_period: P0Y0M0DT1H0M0S }
```

e cambiando opportunamente il valore di `url` dipendentemente
dal flusso di Metadata utilizzato:

- Federazione IDEM di Test: `https://mdx.idem.garr.it/idem-test/`
- Federatione IDEM: `https://mdx.idem.garr.it/idem/`
- Interfederazione IDEM + eduGAIN: `https://mdx.idem.garr.it/edugain/`
