<?php



include "navigator.php";
$Buttons="<a href=\"javascript:Load('$CurrentFileName?Action=RestoreIMAPConfiguration&ControlID=$ControlID&Page=$Page','$ControlID')\" class='ButtonB {$Dir}ButtonB'>{$LNG['RestoreDefault']}</a>";
include "title.php";

if ($_REQUEST['Action']=="RestoreIMAPConfiguration")
{

	SQL("update Config set IMAPHostname='localhost',IMAPPort='143',IMAPSecure='None',IMAPShortLogin='Off' where ConfigID=1");

}

			$Result = SQL("select * from Config");
			foreach ($Result as $Row)
			{
				$IMAPHostname=$Row['IMAPHostname'];
				$IMAPPort=$Row['IMAPPort'];
				$IMAPSecure=$Row['IMAPSecure'];
				$IMAPShortLogin=$Row['IMAPShortLogin'];
			
				if ($IMAPSecure=="None")
				{
				$NoneSelected="selected";
				}
				elseif ($IMAPSecure=="SSL")
				{
				$SSLSelected="selected";
				}
				elseif ($IMAPSecure=="TLS")
				{
				$TLSSelected="selected";
				}
			
			}


			
			Echo "
			<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

			<div class='DivInput {$Dir}DivInput'>{$LNG['Hostname']}<br>
			
			<input type='text' value='$IMAPHostname' id='IMAPHostname' onchange=\"IMAP('IMAPHostname',encodeURI(document.getElementById('IMAPHostname').value))\" class=InputText>
			
			</div>


			<div class='DivInput {$Dir}DivInput'>{$LNG['Port']}<br>
			
			<input type='text' value='$IMAPPort' id='IMAPPort' onchange=\"IMAP('IMAPPort',encodeURI(document.getElementById('IMAPPort').value))\" class=InputText>
			
			</div>
		
		
			

			<div class='DivInput {$Dir}DivInput'>{$LNG['IMAPSecure']}<br>
			
			<select id='IMAPSecure' onchange=\"IMAP('IMAPSecure',encodeURI(document.getElementById('IMAPSecure').value))\" class=Select>
			
			<option value='None' $NoneSelected>None</option>
			<option value='SSL' $SSLSelected>SSL/TLS</option>
			<option value='TLS' $TLSSelected>STARTTLS</option>
			
			</select>
			
			</div>

			<div class='DivInput {$Dir}DivInput'>{$LNG['UseShortLogin']}<br>
			
			<input type='text' value='$IMAPShortLogin' id='IMAPShortLogin' onchange=\"IMAP('IMAPShortLogin',encodeURI(document.getElementById('IMAPShortLogin').value))\" class=InputText>
			
			</div>
			
			</form>

";


?>