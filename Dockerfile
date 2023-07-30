FROM mediawiki:1.39.3
# recompile php with ldap
RUN apt update && apt install libldap-dev libldap-common -y \
 && docker-php-ext-configure ldap --with-ldap && docker-php-ext-install -j$(nproc) ldap \
 # this is the directory where to install extensions; this is the default in LocalSettings.php for the mediawiki docker image
 # change if you plan to use something other than the default
 && mkdir -p /var/www/html/extensions \
 # now install all of the necessary ldap extensions (per https://www.mediawiki.org/wiki/Manual:Active_Directory_Integration#Required_Extensions)
 && curl "https://extdist.wmflabs.org/dist/extensions/PluggableAuth-REL1_39-8a48b65.tar.gz" | tar -xz -C /var/www/html/extensions \
 && curl "https://extdist.wmflabs.org/dist/extensions/LDAPProvider-REL1_39-12bd838.tar.gz" | tar -xz -C /var/www/html/extensions \
 && curl "https://extdist.wmflabs.org/dist/extensions/LDAPAuthentication2-REL1_39-649e1ce.tar.gz" | tar -xz -C /var/www/html/extensions \
 && curl "https://extdist.wmflabs.org/dist/extensions/LDAPAuthorization-REL1_39-7caf22c.tar.gz" | tar -xz -C /var/www/html/extensions \
 && curl "https://extdist.wmflabs.org/dist/extensions/LDAPGroups-REL1_39-590afec.tar.gz" | tar -xz -C /var/www/html/extensions \
 && curl "https://extdist.wmflabs.org/dist/extensions/LDAPUserInfo-REL1_39-01a4b9e.tar.gz" | tar -xz -C /var/www/html/extensions
