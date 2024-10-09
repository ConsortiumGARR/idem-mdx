# Satosa Configuration

#### 1. Retrieve the Federation certificate

Retrieve the Federation Certificate used to verify signed metadata:

```bash
wget https://mdx.idem.garr.it/idem-mdx-service-crt.pem -O /opt/satosa/etc/idem-mdx-service-crt.pem
```

#### 2. Check the certificate validity

- SHA1:

    ```bash
    openssl x509 -in /opt/satosa/etc/idem-mdx-service-crt.pem -fingerprint -sha1 -noout
    ```

    will give:

    `(sha1: 46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95)`

- MD5:

    ```bash
    openssl x509 -in /opt/satosa/etc/idem-mdx-service-crt.pem -fingerprint -md5 -noout
    ```

    will give:

    `(md5: 5D:19:CC:AA:1E:63:E9:50:9D:C7:BE:99:60:0F:1F:96)`

#### 3. Configure SATOSA

Depending on your configuration (backends/frontends),
edit the configuration file:

a. Backends

```bash
vim /opt/satosa/etc/plugins/backends/saml2_backend.yaml
```

by adding the following configuration for metadata:

``` default
metadata:
    mdq: 
    - { url: "https://mdx.idem.garr.it/idem-test/", 
        cert: idem-mdx-service-crt.pem, 
        freshness_period: P0Y0M0DT1H0M0S }
```

and changing the `url` value depending on the Metadata flow used:

- IDEM Test Federation: `https://mdx.idem.garr.it/idem-test/`
- IDEM Production Federation: `https://mdx.idem.garr.it/idem/`
- eduGAIN: `https://mdx.idem.garr.it/edugain/`

b. Frontends

``` bash
vim /opt/satosa/etc/plugins/frontends/saml2_frontend.yaml
```

by adding the following configuration for metadata:

``` default
metadata:
    mdq: 
    - { url: "https://mdx.idem.garr.it/idem-test/", 
        cert: idem-mdx-service-crt.pem, 
        freshness_period: P0Y0M0DT1H0M0S }
```

and changing the `url` value depending on the Metadata flow used:

- IDEM Test Federation: `https://mdx.idem.garr.it/idem-test/`
- IDEM Production Federation: `https://mdx.idem.garr.it/idem/`
- eduGAIN: `https://mdx.idem.garr.it/edugain/`
