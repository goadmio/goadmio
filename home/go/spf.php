<?php



include "navigator.php";
include "no.php";
$Buttons="";
include "title.php";

	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	";
	
	if (stristr($Output," "))
	{
	$OutputArray=explode(" ",$Output);

	$Domain=$OutputArray[0];
	$Domain=str_replace("@","",$Domain);

	$Email=$OutputArray[1];
	}
	else
	{
	$Domain="";
	$Email="";
	}
	
	echo "
	<div class=UnderTitle>
	
	{$LNG['SPFDescription']}

	</div>

	<div class='DivInput {$Dir}DivInput'>{$LNG['Domain']}<br>
	";
	
		unset($Domains);
		$Result = SQL("select * from Site where Trash=0 $SearchSql");
		foreach ($Result as $Row)
		{
		$Domains[]=$Row['Domain'];
		}
				
		if (is_array($Domains))
		{
			sort($Domains);
		}
		else
		{
			$Domains[]="";
		}
		
		echo "
		<select name='Domain' id='Domain' onchange='SPF()' class=Select>
		";
		
		foreach ($Domains as $Domain) 
		{
			if ($Domain==$_REQUEST['Domain'])
			{
			echo "<option value='$Domain' selected>$Domain</option>";
			}
			else
			{
			echo "<option value='$Domain'>$Domain</option>";
			}
		}

		echo "</select>
	
	</div>

	<div id=DivSPF style='margin:10px' ></div>

</form>
";

?>