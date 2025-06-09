# SSL using Traefik

Note that communication between your email client and traefik will be encrypted, and then traefik will forward the unencrypted traffic (through the docker's internal network) to your DavMail instance. This way, you don't have to add another certificate manager if you are already using traefik to handle your certificates.

### Configuring DavMail
First download the new `compose.yml` from this directory. Then edit/create a `.env` file and put
```
DOMAIN=domain.com
```

This means that you can access your davmail instance over `davmail.domain.com`, make sure to change domain.com such that traefik can generate a certificate for it.

### Configuring Traefik

To use traefik to manage your certificate, change your `traefik.yml` config and add the following entrypoints:

```
entryPoints:
    imap-tls:
        address: :1143
    smtp-tls:
        address: :1025
```

Then change the `compose.yml` where you have you traefik instance, expose port 1143 and 1025 (and others if needed) and make sure that both davmail and traefik share a docker network. At last, run `docker compose up -d` for both traefik and davmail and now you can point your email clients to `davmail.domain.com` and enable SSL (note that the port stays the same).
