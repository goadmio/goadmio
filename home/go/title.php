<?php

echo "
<div class='Title {$Dir}Title' style='background-color: var(--background-quaternary); background-image:url(theme/{$_SESSION['SessionTheme']}/svg/$ControlImage);background-repeat: no-repeat; background-position: $DAlign 16px center; background-size: 32px;'>
$Control
</div>
";

if (trim($Buttons)!="")
{
echo "
<div class='DivButton'>
$Buttons
</div>
";
}

if (trim($MainMenu)!="")
{
echo "
<div style='display: flex;justify-content: flex-end;align-items: center;border-bottom: 1px solid var(--border-tertiary);height:60px;padding-left: 20px;padding-right: 20px;'>
$MainMenu
</div>
";
}


?>