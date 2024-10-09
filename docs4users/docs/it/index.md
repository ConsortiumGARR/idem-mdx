# Istruzioni per IDEM MDX

Le seguenti istruzioni devono essere utilizzate per recuperare i
metadata dal servizio IDEM MDX.

Per tutte le configurazioni è stato scelto un valore di durata della
cache pari a 1 ora (3600 secondi). Questa scelta è stata effettuata
tenendo conto che tutti i metadata vengono firmati ogni ora ed il campo
*validUntil* all'interno del file di metadata è pari a 48 ore.

Per quanto riguarda Shibboleth, è stato inserito un valore di
*maxCacheDuration* pari a 48 ore (172800 secondi), con un valore di
*refreshDelayFactor* pari a 0,025 al fine di ottenere, in caso di
cambiamenti, l'aggiornamento dei metadata ogni ora, come per le altre
configurazioni.

Le configurazioni formulano implicitamente una URL conforme al Metadata
Query Protocol partendo dall'URL di base specificato.

Ad esempio, se l'**entityID** è `https://wiki.idem.garr.it/rp`, il
provider richiederà la seguente risorsa:

<https://mdx.idem.garr.it/idem/entities/https:%2F%2Fwiki.idem.garr.it%2Frp>

**ATTENZIONE**

Cambia la URL di base rispetto al flusso di metadata di cui hai bisogno:

- `https://mdx.idem.garr.it/idem-test/` per la Federazione IDEM di Test
- `https://mdx.idem.garr.it/idem/` per la Federatione IDEM
- `https://mdx.idem.garr.it/edugain/` per l'Interfederazione IDEM + eduGAIN
