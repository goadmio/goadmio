<?php
session_start();
header('Content-Type: text/html; charset=UTF-8'); 

$Domain=$_SERVER['HTTP_HOST'];
$Domain=str_replace("http://","",$Domain);
$Domain=str_replace("www.","",$Domain);
$Domain=str_replace(":2020","",$Domain);
$Domain=str_replace(":2022","",$Domain);

echo "<title>$Domain Webmail</title>";

if ($_REQUEST['Webmail']!="")
{
	setcookie ("Webmail",$_REQUEST['Webmail'],time()+31104000,"/");
	
	if ($_REQUEST['Webmail']=="Roundcube")
	{
	Echo "<META HTTP-EQUIV='Refresh' Content='0;URL=http://$Domain/roundcube'>";
	}
	elseif ($_REQUEST['Webmail']=="RainLoop")
	{
	Echo "<META HTTP-EQUIV='Refresh' Content='0;URL=http://$Domain/rainloop'>";
	}
	elseif ($_REQUEST['Webmail']=="Horde")
	{
	Echo "<META HTTP-EQUIV='Refresh' Content='0;URL=http://$Domain/horde'>";
	}
	else
	{
	Echo "<META HTTP-EQUIV='Refresh' Content='0;URL=http://$Domain/squirrelmail'>";
	}
exit;
}

if ($_COOKIE['Webmail']=="Roundcube")
{
	Echo "<META HTTP-EQUIV='Refresh' Content='0;URL=http://$Domain/roundcube'>";
	exit;
}

if ($_COOKIE['RainLoop']=="RainLoop")
{
	Echo "<META HTTP-EQUIV='Refresh' Content='0;URL=http://$Domain/rainloop'>";
	exit;
}

if ($_COOKIE['Webmail']=="SquirrelMail")
{
	Echo "<META HTTP-EQUIV='Refresh' Content='0;URL=http://$Domain/squirrelmail'>";
	exit;
}


echo "
		<body leftmargin=0 marginheight=0 marginwidth=0 rightmargin=0 topmargin=0>
		<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalabel=no\"/>

		<style>
		A.Action:link {FONT-WEIGHT: normal;FONT-SIZE: 15px; COLOR: #FFFFFF; TEXT-DECORATION: none ;font-family: Arial, Helvetica;background: Gray;border:1px solid Gray;border-radius:30px;padding: 7px;transition:all 0.3s ease-in-out 0s;}
		A.Action:visited {FONT-WEIGHT: normal;FONT-SIZE: 15px; COLOR: #FFFFFF; TEXT-DECORATION: none ;font-family: Arial, Helvetica;background: Gray;border:1px solid Gray;border-radius:30px;padding: 7px;transition:all 0.3s ease-in-out 0s;}
		A.Action:active {FONT-WEIGHT: normal;FONT-SIZE: 15px; COLOR: Gray; TEXT-DECORATION: none ;font-family: Arial, Helvetica;background: #ffffff;border:1px solid Gray;}
		A.Action:hover {FONT-WEIGHT: normal;FONT-SIZE: 15px; COLOR: Gray; TEXT-DECORATION: none ; font-family: Arial, Helvetica;background: #ffffff;border:1px solid Gray;}

		.Header {background:#23232E;width:100%;position:absolute;}
		.Header img {margin:16px}
		
		.UnderHeader {width:100%;height:128px}
		
		.Inner {margin-left: auto;margin-right: auto; width: 100%;font-weight:normal;FONT-SIZE: 17px; COLOR: #000000;font-family:Helvetica Neue,Helvetica,Arial;}
		
		.Box {width:49%;display:inline-table;height:200px;text-align:center}
		
		@media only screen and (max-width: 1278px) 
		{
			.Box {width:100%;display:inline-table;height:200px;text-align:center}
		}
		
		</style>
		
		<div class='Header'>
		<a href='https://www.blackhost.com'><img src='logo.svg' height=32></a>
		</div>
		

		<div class='UnderHeader'>&nbsp;</div>
		


				<div class='Inner'>


					<div class=Box>	
						<center>
						<a href='http://$Domain/roundcube'>
						<div style='background:url(roundcube.png) no-repeat center center;width:300px;height:80px;background-size:75%'></div>
						</a>
						
						<br>
						<a href='index.php?Webmail=Roundcube' class=Action>Make as Default</a>
						</center>
					</div>	
						
						

					<div class=Box>	
						<center>
						<a href='http://$Domain/rainloop'>
						<div style='background:url(rainloop.png) no-repeat center center;width:300px;height:80px;background-size:75%'></div>
						</a>
						
						<br>
						<a href='index.php?Webmail=Roundcube' class=Action>Make as Default</a>
						</center>
					</div>	
						

					<div class=Box>
						<center>
						<a href='http://$Domain/squirrelmail'>
						<div style='background:url(squirrelmail.jpg) no-repeat center center;width:300px;height:80px;background-size:75%'></div>
						
						<br>
						<a href='index.php?Webmail=SquirrelMail' class=Action>Make as Default</a>
						</center>
					</div>	
					";
					
					if (file_exists("/usr/share/horde/config/conf.php"))
					{
					echo "
					<div class=Box>
						<center>
						<a href='http://$Domain/horde'>
						<div style='background:url(horde.gif) no-repeat center center;width:300px;height:80px;background-size:75%'></div>
						</a>
						
						<br>
						<a href='index.php?Webmail=Horde' class=Action>Make as Default</a>
						</center>
					</div>
					";
					}
						
					echo "
					
				</div>


				
		</body>
		
		
";


?>