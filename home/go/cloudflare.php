<?php

include "navigator.php";
$Buttons="";
include "title.php";

$Result = SQL("select * from Config where ConfigID=1");
foreach ($Result as $Row)
{
$CloudflareAccountID=$Row['CloudflareAccountID'];
$CloudflareAPIToken=$Row['CloudflareAPIToken'];		
}

echo "
<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">

<div class='DivInput {$Dir}DivInput'>Account ID<br>
<input type='text' value='$CloudflareAccountID' id='CloudflareAccountID' onchange=\"Config('CloudflareAccountID',encodeURI(document.getElementById('CloudflareAccountID').value),'CloudflareAccountID')\" class=InputText>
</div>

<div class='DivInput {$Dir}DivInput'>API Token<br>
<input type='text' value='$CloudflareAPIToken' id='CloudflareAPIToken' onchange=\"Config('CloudflareAPIToken',encodeURI(document.getElementById('CloudflareAPIToken').value),'CloudflareAPIToken')\" class=InputText> <a href='https://dash.cloudflare.com/profile/api-tokens'>API Token</a>
</div>

</form>
";


			
	echo "
	<div class=DivXTable>

		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>

		<th width='100%' colspan=3 height=40>
		Required Cloudflare API Permissions
		</th>
		
		</THEAD>
			
		<TBODY>
		
		<tr class='Td'>
		<TD>Zone</TD>
		<TD>Dmarc Management</TD>
		<TD>Edit</TD>
		
		<tr class='TdB'>
		<TD>Zone</TD>
		<TD>Cache Rules</TD>
		<TD>Edit</TD>
		
		<tr class='Td'>
		<TD>Zone</TD>
		<TD>Bot Management</TD>
		<TD>Edit</TD>
		
		<tr class='TdB'>
		<TD>Zone</TD>
		<TD>Zone</TD>
		<TD>Edit</TD>
		
		<tr class='Td'>
		<TD>Zone</TD>
		<TD>Cache Purge</TD>
		<TD>Purge</TD>
		

		<tr class='TdB'>
		<TD>Zone</TD>
		<TD>Page Rules</TD>
		<TD>Edit</TD>
		
		<tr class='Td'>
		<TD>Zone</TD>
		<TD>DNS</TD>
		<TD>Edit</TD>
		
		</TBODY>
		</TABLE>

	</div>
	";


?>