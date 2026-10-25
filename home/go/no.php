<?php
$Sites=SQL("SELECT COUNT(*) from Site where Trash=0");

if ($Sites==0)
{ 
	echo Error("There are no websites. <a href=\"javascript:Load('site.php')\" class=Action>{$LNG['CreateNewAccount']}</a>");
	exit;
}
?>