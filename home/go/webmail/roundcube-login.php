<?php
include "/usr/local/goadmio/home/go/include/function/function.php";
include "/usr/local/goadmio/include/config/config.php";

$Email=$_COOKIE['CookiesRoundcubeEmail'];
$Pass=$_COOKIE['CookiesRoundcubePass'];

if ($Email=="" or $Pass=="")
{
echo "Please login...";
exit;
}

require_once '/usr/local/goadmio/home/go/webmail/roundcube/program/include/iniset.php';
$RCMAIL = rcmail::get_instance();
$Token = $RCMAIL->get_request_token();

echo "
<form id='Login' action='index.php' method='POST'>
<input type='hidden' name='_token' value='$Token'>
<input type='hidden' name='_task' value='login'>
<input type='hidden' name='_action' value='login'>
<input type='hidden' name='_timezone' id='rcmlogintz' value='_default_'>
<input type='hidden' name='_url' id='rcmloginurl' value=''>
<input type='hidden' name='_user' value='$Email'>
<input type='hidden' name='_pass' value='$Pass'>
</form>
<script>document.getElementById('Login').submit();</script>
";

exit;

$T=time();
if ($RCMAIL->login($Email, $Pass,'')) 
{
    header('Location: index.php?T=$T');
    exit;
} 
else 
{
    echo 'Login failed. Please check your credentials.';
}

?>