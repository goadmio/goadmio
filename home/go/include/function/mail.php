<?php
// دالة للبحث عن جميع الايملات فى النص و ترجع بها فى مصفوفة
function GetMails ($String)
{
$Emails = array();
preg_match_all("/([\-\.\_a-z0-9]*@[\-\.a-z0-9]*)/i", $String, $Output);
foreach($Output[0] as $Email) array_push ($Emails, strtolower($Email));
if (count ($Emails) >= 1) return $Emails;
else return false;
}
?>
