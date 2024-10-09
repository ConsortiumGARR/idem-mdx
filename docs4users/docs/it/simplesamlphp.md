# Configurazione su SimpleSAMLphp IdP/SP

## SimpleSAMLphp v.1.14+ IdP

#### 1. Modifica la configurazione

Modifica opportunamente il file di configurazione principale:

``` bash
vim /var/simplesamlphp/config/config.php
```

andando a modificare la configurazione dei `metadata.sources` per
aggiungere la fonte di metadata di MDQ,
**commentando/decommentando** opportunamente il valore di `server`
dipendentemente dal flusso di Metadata utilizzato:

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

**Attenzione**: è necessario che il modulo `metarefresh` sia disabilitato e che non
sia presente alcun file nella cartella `/metadata` diverso da `saml20-idp-hosted.php` che contiene i metadata dell'IdP.

#### 2. Creazione della cartella per la cache

Crea la cartella `mdq-cache`:

- ``` bash
    sudo mkdir /var/simplesamlphp/mdq-cache
    ```

- ``` bash
    chown www-data /var/simplesamlphp/mdq-cache
    ```

#### 3. Gestione file non necessari

- Rimozione dei file:

``` bash
cd /var/simplesamlphp/metadata ; rm !(saml20-idp-hosted.php)
```

- Spostamento dei file:

``` bash
mkdir /var/simplesamlphp/metadata.old
```

``` bash
mv /var/simplesamlphp/metadata/!(saml20-idp-hosted.php) /var/simplesamlphp/metadata.old
```

## SimpleSAMLphp v.1.14+ SP

#### 1. Modifica la configurazione

Modifica opportunamente il file di configurazione principale:

``` bash
vim /var/simplesamlphp/config/config.php
```

andando a modificare la configurazione dei `metadata.sources` per
aggiungere la fonte di metadata di MDQ,
**commentando/decommentando** opportunamente il valore di `server`
dipendentemente dal flusso di Metadata utilizzato:

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

**Attenzione**: è necessario che il modulo `metarefresh` sia disabilitato e che non
sia presente alcun file nella cartella `/metadata` diverso da
`saml20-idp-remote.php` che contiene i metadata utilizzati per il
discovery service locale.

#### 2. Creazione della cartella per la cache

Crea la cartella `mdq-cache`:

- ``` bash
    sudo mkdir /var/simplesamlphp/mdq-cache
    ```

- ``` bash
    chown www-data /var/simplesamlphp/mdq-cache
    ```
