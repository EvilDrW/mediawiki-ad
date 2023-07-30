# Add all of the following this to the end of your LocalSettings.php after generating it per the instructions in docker-compose.yml
$wgEmailConfirmToEdit = false; // optional
$wgGroupPermissions['*']['createaccount'] = false; // if you only want AD accounts to login
$wgGroupPermissions['*']['autocreateaccount'] = true;
$wgBlockDisablesLogin = true;

// Load LDAP Config from JSON
$ldapJsonFile = "/var/www/ldap.json";
$ldapConfig = false;
if (is_file($ldapJsonFile) && is_dir("$IP/extensions/LDAPProvider")) {
  $testJson = @json_decode(file_get_contents($ldapJsonFile),true);
  if (is_array($testJson)) {
    $ldapConfig = true;
  } else {
    error_log("Found invalid JSON in file: /var/www/ldap.json");
  }
}

// Activate Extension
if ( $ldapConfig ) {
  wfLoadExtension( 'PluggableAuth' );
  wfLoadExtension( 'LDAPProvider' );
  wfLoadExtension( 'LDAPAuthentication2' );
  wfLoadExtension( 'LDAPAuthorization' );
  wfLoadExtension( 'LDAPUserInfo' );
  wfLoadExtension( 'LDAPGroups' );

  $LDAPProviderDomainConfigs = $ldapJsonFile;
  $LDAPProviderDefaultDomain = "YOUR.DOMAIN";

  // can change the 'Log In' string to whatever you want; it will appear as the login button in MediaWiki
  $wgPluggableAuth_Config['Log In'] = [
    'plugin' => 'LDAPAuthentication2',
    'data' => [
      'domain' => 'YOUR.DOMAIN'
    ]
  ];
}
