<?php

if ($_REQUEST['server']=="")
{
	$_POST['auth'] = [
	'driver' => 'server', // or 'sqlite', 'pgsql', etc.
	'server' => 'localhost',
	'username' => $_COOKIE['CookiesMySQLUsername'],
	'password' => $_COOKIE['CookiesMySQLPassword'], 
	'db' => ''
	];
}

include "adminer.php";

?>