<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ERROR|E_PARSE);

session_start();


$Username=$_REQUEST['Username'];

include("/usr/local/goadmio/home/go/include/function/function.php");
include("/usr/local/goadmio/include/config/config.php");

$Username=ValidateUsername($_REQUEST['Username']);

$Result = SQL("select * from Auth where AuthUser='$Username'");
foreach ($Result as $Row)
{
echo "1";
}

?>