<?php
session_start();

if ($_SERVER['REQUEST_METHOD']=="POST")
{

	// 10 KB
	$FileSizeMax=100000000000;

	iF ($_FILES['FileName'][name]!="none" and $_FILES['FileName'][name]!="")
	{

		copy($_FILES[FileName][tmp_name],"/home/{$_SESSION['SessionUsername']}/www/builder/image/logo.png");
			
	}
	

}


echo "
<div style='width:250px;height:250px;background:url(//{$_SESSION['SessionUsername']}/builder/image/logo.png) no-repeat center center;'></div>
";



?>