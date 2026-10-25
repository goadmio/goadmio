<?php
unset ($_COOKIE['CookiesMySQLUsername']);
unset ($_COOKIE['CookiesMySQLPassword']);
setcookie ("CookiesMySQLUsername","",time() - (86400 * 30), "/");
setcookie ("CookiesMySQLPassword","",time() - (86400 * 30), "/");
header("Location: index.php");
?>
