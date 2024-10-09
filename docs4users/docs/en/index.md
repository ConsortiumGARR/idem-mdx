# IDEM MDX Instructions

The following instructions are meant to be used to retrive metadata by
the IDEM MDX service.

For all the configuration a cache duration value of 1 hour (3600
seconds) is chosen. This choice was made taking into account that all
the metadata are signed every hour and the *validUntil* field in the
metadata file is 48 hours.

For Shibboleth, we set a *maxCacheDuration* value equal to 48 hours
(172800 seconds), with a *refreshDelayFactor* of 0.025 to get in case of
changes the metadata refresh every hour, like the other configurations.

The configurations implicitly formulates a Metadata Query Protocol URL
from the given baseURL.

For example, if the **entityID** is <https://wiki.idem.garr.it/rp>, the
provider will request the following resource:

<https://mdx.idem.garr.it/idem/entities/https:%2F%2Fwiki.idem.garr.it%2Frp>

**WARNING**

Change the baseURL according to the metadata stream you need:

- "<https://mdx.idem.garr.it/idem/>" for IDEM Federation
- "<https://mdx.idem.garr.it/edugain/>" for IDEM + eduGAIN Interfederation
- "<https://mdx.idem.garr.it/idem-test/>" for IDEM Test Federation
