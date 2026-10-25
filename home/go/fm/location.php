<?php
session_start();

include "/usr/local/goadmio/home/go/include/function/function.php";
include "/usr/local/goadmio/include/config/config.php";

if (stristr($_SESSION['SessionDomain'],"."))
{
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/fm {$_SESSION['SessionDomain']} login'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
    header("Location: {$_SESSION['SessionDomain']}/");
}
else
{
echo "Please Login.";
exit;
}

?>