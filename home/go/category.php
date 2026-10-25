<?php
include "navigator.php";
$Buttons="";
include "title.php";

$Category=$_REQUEST['Category'];
$ControlMenu=$_REQUEST['ControlMenu'];

$X=0;
$Y=0;


if ($_SESSION['SessionType']=="Root")
{
    $ServiceSql="Service!=4";
}
elseif ($_SESSION['SessionType']=="Reseller")
{
    $ServiceSql="Service in (2,3)";
}
elseif ($_SESSION['SessionType']=="Website")
{
    $ServiceSql="Service>=3";
}

echo "
<div class='DivIcon'>
";

$Result = SQL("select * from Control where $ServiceSql and ControlMenu='$ControlMenu' order by Sort");
foreach ($Result as $Row)
{
    $X++;

    $ControlID=$Row['ControlID'];
    
    $Control=$LNG[$Row['Control']];
    $ControlMenu=$LNG[$Row['ControlMenu']];
    $ControlImage=$Row['ControlImage'];
    
    $ControlUrl=$Row['ControlUrl'];
    
    $ControlUrl=str_replace("[Service]",$Service,$ControlUrl);
    $ControlUrl=str_replace("[ServiceControl]",$ServiceControl,$ControlUrl);
    $ControlUrl=str_replace("[ModuleName]",$ModuleName,$ControlUrl);
    $ControlUrl=str_replace("[CTabNo]",$CTabNo,$ControlUrl);
    $ControlUrl=str_replace("[ControlID]",$ControlID,$ControlUrl);
    
    $ControlUrlArray=explode("?",$Row['ControlUrl']);
    $ControlFile=$ControlUrlArray[0];


    $ControlTarget=$Row['ControlTarget'];
    
    if (stristr("|{$_SESSION['SessionControlFile']}|","|$ControlFile|") or $_SESSION['SessionControlFile']=="")
    { 
        if ($ControlTarget=="")
        {
            echo "
            <a href='javascript:Load(\"$ControlUrl\",\"$ControlID\")' class='Main {$Dir}Main'>
                <div class='Icon'>
                    <img src='theme/{$_SESSION['SessionTheme']}/svg/$ControlImage' alt='$Control'>
                </div>
                <span>$Control</span>
            </a>
            ";
        }
        else
        {
            echo "
            <a href='$ControlUrl' target='$ControlTarget' class='Main {$Dir}Main'>
                <div class='Icon'>
                    <img src='theme/{$_SESSION['SessionTheme']}/svg/$ControlImage' alt='$Control'>
                </div>
                <span>$Control</span>
            </a>
            ";
        }
    
    }
    
    $LastControlMenu=$ControlMenu;
}

echo "
</div>
";
?>