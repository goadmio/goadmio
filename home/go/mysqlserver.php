<?php
include "nav.php";
include "title.php";

if (!in_array($_SESSION['SessionSSHUsername'], ['root', 'admin', 'go', $SSHUsername], true))
{

        Echo "
        Sorry, You Are Not Allowed to Access This Page
        ";

exit;
}

if ($_REQUEST['Action']=="Restart")
{

        $Error=SSH ("/usr/bin/sudo /usr/bin/systemctl restart mariadb",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
        if ($Error=="")
        {
        echo Error("MySQL restarted successfully.");
        }
        else
        {
        echo Error("$Error");
        }

        echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");


exit;

}



        $Content=DesignCode($Content,"$Control (Content)");
        echo $Content;



?>