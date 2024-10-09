<?php
$jsondata = file_get_contents('/opt/idem_jwt_to_php/edugain2idem-eds.json');

if (!empty($jsondata)) {
   $entities = json_decode($jsondata, true);
   $text = '';
   $displaynames = '';

   foreach ($entities as $entity => $entityMetadata) {

      // remove the unused elements of json
      unset($entityMetadata['Logos']);

      $entityMetadata['entityid'] = $entityMetadata['entityID'];
      unset($entityMetadata['entityID']);

      $displaynames = $entityMetadata['DisplayNames'];
      unset($entityMetadata['DisplayNames']);

      if (!empty($displaynames)) {
               $entityMetadata['name'] = array();

               foreach ($displaynames as $displayname => $entityName) {

                     $entityMetadata['name'][$entityName['lang']] = $entityName['value'];

               }
      }
      $text .= '$metadata['.var_export($entityMetadata['entityid'], true).'] ='.
               var_export($entityMetadata, true).";\n";

      $entities = $text;
   }
}

$file = '/var/simplesamlphp/metadata/saml20-idp-remote.php';
file_put_contents($file,"<?php\n");
file_put_contents($file, print_r($entities, true),FILE_APPEND);
?>