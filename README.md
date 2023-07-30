# mediawiki-ad
MediaWiki with Active Directory Integrations

This repository builds from MediaWiki 1.39.3 because that's what I was working with before I decided I wanted to do Active Directory Logon.  For reference, I'm using the Docker-ized Samba AD Server from [here](https://github.com/Fmstrat/samba-domain).  From that image's default settings, LDAP is available via SSL and doesn't use StartTLS.  I chose to disable certificate verification.

Also, props to the people who made the [Active Directory Integration Manual](https://www.mediawiki.org/wiki/Manual:Active_Directory_Integration).  Some of it is outdated, but it was very helpful to make these settings work.

# Build the Docker Image
The stock MediaWiki docker image does not have LDAP compiled into its PHP and does not have any of the [LDAP Stack](https://www.mediawiki.org/wiki/LDAP_Stack) extensions installed. The included Dockerfile recompiles PHP and adds those extensions at the default location `/var/www/html/extensions`.

Build the image with:

```
$ docker build . --tag mediawiki-ldap:1.39.3
```

If you want to use a different version of MediaWiki, you'll need to change the `FROM` line in the Dockerfile and potentially change the URLs for each extension to have matching versions of all.  You should also change the image tag in the above command and edit docker-compose.yml to use the same tag.

# Generate LocalSettings.php
Per the [recommended docker-compose.yml](https://hub.docker.com/_/mediawiki/) file, you'll next need to startup MediaWiki and have it generate a starting LocalSettings.php:

```
$ docker-compose up -d
```

With luck, you should be able to access MediaWiki on your server at port 8080.  Assuming that this works, grab the generated LocalSettings.php to the same directory as docker-compose.yml.  Depending on settings, you may need to change the Docker container name (i.e. mediawiki_mediawiki_1) in the following command.

```
$ docker cp mediawiki_mediawiki_1:/var/www/html/LocalSettings.php .
```

# Edit Config Files
Copy everything from AddTo_LocalSettings.php to the end of the LocalSettings.php you just downloaded.  Edit the settings you just copied with the details for your Active Directory server, and save the file.  Now, edit the contents of ldap.json with your options (it may help to refer to [this](https://www.mediawiki.org/wiki/Manual:Active_Directory_Integration#Prepare_ldap.json)).  In particular, be sure you rename the section of the json file with your domain name and that it matches the 'domain' setting of `$wgPluggableAuth_Config` in LocalSettings.php.

Once you've done this, uncomment the lines:

```
- ./LocalSettings.php:/var/www/html/LocalSettings.php
- ./ldap.json:/var/www/ldap.json
```

in docker-compose.yml, and restart the container:

```
$ docker-compose restart
```

# Update MediaWiki
You should again be able to access MediaWiki on port 8080, but you'll find that LDAP/Active Directory login still fails.  This will continue to fail until you run a maintenance command in the container.

First, get a bash shell to your container, again you may need to change the container:

```
$ docker exec -it mediawiki_mediawiki_1 bash
```

Then, run the necessary MediaWiki maintenance command:

```
php /var/www/html/maintenance/update.php
```

Congratulations, with any luck, you should now be able to login to MediaWiki with credentials from your Active Directory.