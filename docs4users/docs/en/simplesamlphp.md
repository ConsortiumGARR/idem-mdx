# SimpleSAMLphp IdP/SP Configuration

## SimpleSAMLphp v.1.14+ IdP

#### 1. Edit the configuration

Edit `config.php` opportunely:

``` bash
vim /var/simplesamlphp/config/config.php
```

by changing the SimpleSAMLphp `metadata.sources` configuration to load the new metadata provider,
**commenting/uncommenting** the `server` value depending on the Metadata flow used:

``` php
'metadata.sources' => [
    ['type' => 'flatfile'],
    ['type' => 'mdq',
        // IDEM Production Federation
        //'server' => 'https://mdx.idem.garr.it/idem',
        // IDEM Test Federation
        'server' => 'https://mdx.idem.garr.it/idem-test',
        // eduGAIN
        //'server' => 'https://mdx.idem.garr.it/edugain',
        'validateFingerprint' => '46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95',
        'cachedir' => '/var/simplesamlphp/mdq-cache',
        'cachelength' => 3600],
],
```

**Warning**: The `metarefresh` module needs to be disabled and the file
`saml20-idp-hosted.php*` needs to be the only file in the `/metadata` folder.

#### 2. Cache folder creation

Create the `mdq-cache` folder:

- ``` bash
    sudo mkdir /var/simplesamlphp/mdq-cache
    ```

- ``` bash
    chown www-data /var/simplesamlphp/mdq-cache
    ```

#### 3. Manage unnecessary files

- Removing files:

``` bash
cd /var/simplesamlphp/metadata ; rm !(saml20-idp-hosted.php)
```

- Moving files:

``` bash
mkdir /var/simplesamlphp/metadata.old
```

``` bash
mv /var/simplesamlphp/metadata/!(saml20-idp-hosted.php) /var/simplesamlphp/metadata.old
```

## SimpleSAMLphp v.1.14+ SP

#### 1. Edit the configuration

Edit `config.php` opportunely:

``` bash
vim /var/simplesamlphp/config/config.php
```

by changing the SimpleSAMLphp `metadata.sources` configuration to load the new metadata provider,
**commenting/uncommenting** the `server` value depending on the Metadata flow used:

``` php
'metadata.sources' => [
    ['type' => 'mdq',
        // IDEM Production Federation
        //'server' => 'https://mdx.idem.garr.it/idem',
        // IDEM Test Federation
        'server' => 'https://mdx.idem.garr.it/idem-test',
        // eduGAIN
        //'server' => 'https://mdx.idem.garr.it/edugain',
        'validateFingerprint' => '46:FC:EB:7B:D0:67:46:EA:0C:B1:B2:61:4C:DC:37:DA:BD:B4:8A:95',
        'cachedir' => '/var/simplesamlphp/mdq-cache',
        'cachelength' => 3600],
    ['type' => 'flatfile'],
],
```

**Warning**: The `metarefresh` module needs to be disabled and the file
`saml20-idp-hosted.php*` needs to be the only file in the `/metadata` folder.

#### 2. Cache folder creation

Create the `mdq-cache` folder:

- ``` bash
    sudo mkdir /var/simplesamlphp/mdq-cache
    ```

- ``` bash
    chown www-data /var/simplesamlphp/mdq-cache
    ```
