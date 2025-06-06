### Running on a server (headless)

To run davmail (headless) in Docker, download the `Dockerfile` and `compose.yml` file.

You also need to download the server config from [here](https://davmail.sourceforge.net/serversetup.html) and save it as `davmail.properties`.


After setting up the 3 files mentioned above, run the following command:
```
docker build . -t davmail
docker compose up -d
```

Note that the first time it will download and compile davmail which might take a while. The next time you run it it will be much faster as it won't need to re-compile davmail.

Also as a side note, make sure to change the ports in the `compose.yml` file to make sure you are not exposing them to the public (unless you want that, of course).

### Setting up OAuth2 on "headless"

Normally running davmail headless means that you can not use OAuth2, because you need a GUI for that. However, what you can do is download the `Dockerfile` to your computer and download the normal config from [here](https://github.com/mguessan/davmail/blob/master/src/etc/davmail.properties), make sure to save it as `davmail.properties`.

Edit the `davmail.properties` file and set `davmail.server=false` and set `davmail.mode=O365Manual` (or whatever method you want to use, see [Exchange protocol](https://davmail.sourceforge.net/gettingstarted.html)), and run the command below.

```
docker build . -t davmail
docker run --network=host --rm --name davmail --hostname davmail -v /tmp/.X11-unix:/tmp/.X11-unix  -e "DISPLAY=${DISPLAY}" -v "${XAUTHORITY:-$HOME/.Xauthority}:/.Xauthority:ro" -v davmail.properties/davmail.properties -u "$UID" davmail
```


Next, open your email client, e.g. thunderbird. Add a new account and make sure to click "Configure manually" or something like that. Set receiving/incoming (IMAP) to `localhost:1143` and sending (SMTP) to `localhost:1025`. Both using username `<email>` and password `<password>`. Note that `<email>` has to match the email you want log in to (using oauth2), and `<password>` can be ANY password, even different than your account password.

After pressing connect on the email client (sometimes you may need to ignore ssl warnings), the GUI from davmail should show instructions on how to authenticate (depending on the davmail.mode you set before).

After having followed those instructions, you can see that your account is now successfully connected. To move the configuration to your server/headless instance, stop the docker container (Ctrl+C) and type `cat davmail.properties`.

At the bottom, there is an entry called `davmail.oauth.<email>.refreshToken`. Copy this to the `server.properties` on your server and then restart the container (on your server). You can now configure your email client again using the same steps before, but instead of localhost you should use your vps ip (make sure you put in the same `<password>`).

### Setting up SSL

If you are running davmail on your server, make sure to setup SSL. In order to do this, use a service like letsencrypt or create a self signed certificate. In the case of letsencrypt, go to `certs/live/<DOMAIN>` and run the following command

```
openssl pkcs12 -export -in fullchain.pem -inkey privkey.pem -certfile cert.pem -out davmail.p12
```

Make sure to set a password `<password2>` and make sure it is different than `<password>` (it can be the same, but for your own sake use a different one, please).

Move the new `davmail.p12` file over to where you put the original `compose.yml` file, uncomment the line that uses this file and then edit `davmail.properties` and set the following values:
```
davmail.ssl.keystoreType=PKCS12
davmail.ssl.keyPass=<password2>
davmail.ssl.keystoreFile=/davmail.p12
davmail.ssl.keystorePass=<password2>
```

Make sure to put the correct `<password2>` in there!

Now go back to your email client and enable SSL (same port) and connect.
