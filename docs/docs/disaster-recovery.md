# IDEM MDX Disaster Recovery

The MDX service consists of two parts:

- a single Backend that creates and signs metadata
     (PyFF container) and make all the metadata created,
     along with the JSON Web Tokens that are created for
     how MDX works with Embedded Discovery Services
     (Crsync container).
- multiple Frontends (2 planned at the moment) that take care of
     distribute metadata in high reliability and balance.

In the event of an accident that has made ALL the nodes unavailable
participate in the provision of the service (power outage), the
MDX service restarts automatically:

- Inserted the restart inside the docker compose, both for the BE and for the FE
- Moved the private key decryption process inside the container (BE)
- Eliminated the static SSL certificates within the FEs, nginx will look for the certificates in the volume shared with Certbot

Therefore, no intervention on our part is necessary, other than checking
that the reboot procedure went well (CheckMk is enough?).

In case there is any problem or it is necessary
move the service to another site, it is necessary to have on the new node
the Certbot and HaProxy containers, which are not brought up by the deployment
of the MDX service.
