<?php
session_start();

$_ENV['SNAPPYMAIL_INCLUDE_AS_API'] = true;
require_once '/usr/local/goadmio/home/go/webmail/snappymail/index.php';;
$ssoHash = \RainLoop\Api::CreateUserSsoHash($_SESSION['SessionEmail'], $_SESSION['SessionEmailPass']);
header('Location: snappymail/?sso&hash=' . $ssoHash);
?>