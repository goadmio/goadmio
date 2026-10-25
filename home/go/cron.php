<?php
include "navigator.php";
$Buttons="";
include "title.php";

$Edit=$_REQUEST['Edit'];
$Delete=$_REQUEST['Delete'];
$Step=$_REQUEST['Step'];

$Domain=ValidateDomain($_REQUEST['Domain']);

if ($Domain!="")
{
	$Sql = "select Username from Site where Domain='$Domain'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
	$Username=$Row['Username'];
	}
}

$CronID=intval($_REQUEST['CronID']);
$Minute=$_REQUEST['Minute'];
$Hour=$_REQUEST['Hour'];
$DayMonth=$_REQUEST['DayMonth'];
$Month=$_REQUEST['Month'];
$DayWeek=$_REQUEST['DayWeek'];
$Command=$_REQUEST['Command'];
$Description=$_REQUEST['Description'];
$TimeStamp=time();

If ($Delete==1 and $Step==1)
{

	echo Error("Delete Cron ID \"$CronID\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&Domain={$_REQUEST['Domain']}&CronID=$CronID&Step=2')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID')\" class=Action>No</a>");
	exit;
	
}

if ($Delete==1 and $Step==2)
{
	include "access.php";
	SQL("DELETE FROM Cron WHERE CronID='$CronID'");
	echo Error("Cron Job \"$CronID\" Deleted Successfully.");
}


if ($_REQUEST['Action']=="Active")
{

	if ($_REQUEST['Active']=="1")
	{
		SQL("update Cron set Active=0 where CronID='$CronID'");	
	}
	else
	{
		SQL("update Cron set Active=1 where CronID='$CronID'");
	}
	
	SSH ("/usr/bin/sudo /go/cron $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

}


if ($_REQUEST['Action']=="Run")
{
	$Sql = "select * from Cron where CronID='$CronID' AND Domain='$Domain'";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
	$Username=$Row['Username'];
	$Command=$Row['Command'];
	}
	
	$Error=SSH ("/usr/bin/sudo -u $Username $Command",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	echo Error("<b># $Command</b><br><pre style='width:100%;overflow:hidden'>$Error</pre>");

	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;
}


if ($_REQUEST['Minute']!="")
{

	include "access.php";

	if ($Domain=="" or $Username=="")
	{
		echo Error("No Domain Or Username.");
		echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
		exit;
	}

	if (CommandSafe($Command,"/home/$Domain"))
	{
		if ($Edit==1)
		{
			
			$Sql = "select CronID from Cron where Domain='$Domain' and Command='$Command' AND CronID!='$CronID'";
			$Result = SQL($Sql);
			foreach ($Result as $Row)
			{
				echo Error("Command \"$Command\" Already Exists.");
				echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
				exit;
			}

		
			SQL("UPDATE Cron SET Minute='$Minute',Hour='$Hour',DayMonth='$DayMonth',Month='$Month',DayWeek='$DayWeek',Command='$Command',Description='$Description' WHERE CronID='$CronID'");
			echo Error("Cron Job \"$CronID\" Edited Successfully.");
			
		}
		else
		{
			
			$Sql = "select CronID from Cron where Domain='$Domain' and Command='$Command'";
			$Result = SQL($Sql);
			foreach ($Result as $Row)
			{
				echo Error("Command \"$Command\" Already Exists.");
				echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
				exit;
			}

		
			$CronID=SQL("INSERT INTO Cron (Domain,Username,Minute,Hour,DayMonth,Month,DayWeek,Command,Description,TimeStamp) VALUES ('$Domain','$Username','$Minute','$Hour','$DayMonth','$Month','$DayWeek','$Command','$Description','$TimeStamp')");
			echo Error("Cron Job \"$CronID\" Created Successfully.");
		}
		
		SSH ("/usr/bin/sudo /go/cron $Domain",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			
	}
	else
	{
	echo Error("Cron \"$Command\" not Allowed.");
	}
	
	echo Error("<a href=\"javascript:Load('$CurrentFileName')\"><img src='theme/{$_SESSION['SessionTheme']}/image/back.svg' height=24 style='padding-right:8px;vertical-align:middle'>Go Back</a>");
	exit;
	
}


	if ($Edit==1)
	{

		$Result = SQL("select * from Cron where CronID='$CronID'");
		foreach ($Result as $Row)
		{
		$Minute=$Row['Minute'];
		$Hour=$Row['Hour'];
		$DayMonth=$Row['DayMonth'];
		$Month=$Row['Month'];
		$DayWeek=$Row['DayWeek'];
		$Command=$Row['Command'];
		$Description=$Row['Description'];
		}
		
	}

	$Result = SQL("SELECT * FROM Site where Trash=0 $SearchSql");
	foreach ($Result as $Row)
	{
	$Account['Domain'][]=$Row['Domain'];
	$Account['Username'][]=$Row['Username'];
	}
		
		
	if (is_array($Account['Domain']))
	{
		array_multisort($Account['Domain'], SORT_ASC, SORT_STRING,$Account['Username'], SORT_NUMERIC, SORT_DESC);
	}
	else
	{
		echo Error("There are no websites. <a href=\"javascript:Load('site.php')\" class=Action>{$LNG['CreateNewAccount']}</a>");
		exit;
	}

	if ($Minute=="") {$Minute="*";}
	if ($Hour=="") {$Hour="*";}
	if ($DayMonth=="") {$DayMonth="*";}
	if ($Month=="") {$Month="*";}
	if ($DayWeek=="") {$DayWeek="*";}


echo "<div style=\"font-family: var(--font-family-system, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif);border-bottom:1px solid var(--border-tertiary)\">
    <div style=\"background: var(--header-background, #1a1a1a); padding: 1rem 1.5rem; border-bottom: 1px solid var(--header-border-color, rgba(255, 255, 255, 0.16));\">
        <h3 style=\"margin: 0; font-weight: 600; font-size: 1.25rem; color: var(--text-primary);\">⏰ Cron Jobs — Automated Tasks</h3>
        <p style=\"margin: 0.25rem 0 0; opacity: 0.8; font-size: 0.85rem; color: var(--header-text-color);\">Schedule commands/scripts to run at specific times</p>
    </div>
    <div style=\"padding: 1.5rem; background: var(--window-background, #000000);\">
        <div style=\"background: var(--control-background, #2C2C2E); border-left: 4px solid var(--control-accent, #0A84FF); padding: 0.75rem 1rem; border-radius: 10px; margin-bottom: 1rem;\">
            <code style=\"font-size: 0.85rem; color: var(--text-primary); font-family: var(--font-family-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace);\">0 2 * * * find /home/goadmio.com/www/cache -type f -delete</code>
            <div style=\"font-size: 0.7rem; color: var(--label-secondary, #98989D); margin-top: 6px;\">← Runs daily at 2:00 AM — Deletes all files in cache directory</div>
        </div>
        
        <div style=\"background: var(--control-background, #2C2C2E); border-left: 4px solid var(--control-accent, #0A84FF); padding: 0.75rem 1rem; border-radius: 10px; margin-bottom: 1.5rem;\">
            <code style=\"font-size: 0.85rem; color: var(--text-primary); font-family: var(--font-family-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace);\">0 3 * * * php /home/goadmio.com/www/backup.php</code>
            <div style=\"font-size: 0.7rem; color: var(--label-secondary, #98989D); margin-top: 6px;\">← Runs daily at 3:00 AM — Executes backup script</div>
        </div>
        
        <div style=\"display: grid; gap: 0.75rem; margin-bottom: 1.25rem;\">
            <div style=\"display: flex; flex-wrap: wrap; gap: 0.5rem; align-items: baseline;\">
                <span style=\"font-weight: 600; min-width: 70px; font-size: 0.8rem; color: var(--text-secondary, #DDDDDD);\">⏲️ Minute:</span>
                <span style=\"background: var(--fill-quaternary, rgba(116, 116, 128, 0.18)); padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.75rem; color: var(--text-primary, #FFFFFF);\">0-59</span>
                <span style=\"background: var(--fill-quaternary, rgba(116, 116, 128, 0.18)); padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.75rem; color: var(--text-primary, #FFFFFF);\">*/5 = every 5 min</span>
            </div>
            <div style=\"display: flex; flex-wrap: wrap; gap: 0.5rem;\"><span style=\"font-weight: 600; min-width: 70px; font-size: 0.8rem; color: var(--text-secondary, #DDDDDD);\">🕒 Hour:</span><span style=\"background: var(--fill-quaternary, rgba(116, 116, 128, 0.18)); padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.75rem; color: var(--text-primary, #FFFFFF);\">0-23</span><span style=\"background: var(--fill-quaternary, rgba(116, 116, 128, 0.18)); padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.75rem; color: var(--text-primary, #FFFFFF);\">9 = 9 AM</span></div>
            <div style=\"display: flex; flex-wrap: wrap; gap: 0.5rem;\"><span style=\"font-weight: 600; min-width: 70px; font-size: 0.8rem; color: var(--text-secondary, #DDDDDD);\">📅 Day:</span><span style=\"background: var(--fill-quaternary, rgba(116, 116, 128, 0.18)); padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.75rem; color: var(--text-primary, #FFFFFF);\">1-31</span><span style=\"background: var(--fill-quaternary, rgba(116, 116, 128, 0.18)); padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.75rem; color: var(--text-primary, #FFFFFF);\">*/2 = every 2 days</span></div>
            <div style=\"display: flex; flex-wrap: wrap; gap: 0.5rem;\"><span style=\"font-weight: 600; min-width: 70px; font-size: 0.8rem; color: var(--text-secondary, #DDDDDD);\">📆 Month:</span><span style=\"background: var(--fill-quaternary, rgba(116, 116, 128, 0.18)); padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.75rem; color: var(--text-primary, #FFFFFF);\">1-12</span><span style=\"background: var(--fill-quaternary, rgba(116, 116, 128, 0.18)); padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.75rem; color: var(--text-primary, #FFFFFF);\">1,6 = Jan & Jun</span></div>
            <div style=\"display: flex; flex-wrap: wrap; gap: 0.5rem;\"><span style=\"font-weight: 600; min-width: 70px; font-size: 0.8rem; color: var(--text-secondary, #DDDDDD);\">🗓️ Weekday:</span><span style=\"background: var(--fill-quaternary, rgba(116, 116, 128, 0.18)); padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.75rem; color: var(--text-primary, #FFFFFF);\">0-7 (Sun=0/7)</span><span style=\"background: var(--fill-quaternary, rgba(116, 116, 128, 0.18)); padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.75rem; color: var(--text-primary, #FFFFFF);\">1 = Monday</span></div>
        </div>
        
        <div style=\"background: var(--grouped-background-secondary, #1C1C1E); border-radius: 12px; padding: 0.75rem 1rem; margin: 1rem 0;\">
            <div style=\"font-weight: 600; font-size: 0.8rem; margin-bottom: 6px; color: var(--text-secondary, #DDDDDD);\">✨ Common examples</div>
            <div><code style=\"font-size: 0.75rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">0 2 * * *</code> <span style=\"color: var(--label-secondary, #98989D);\">→ Daily at 2:00 AM</span></div>
            <div><code style=\"font-size: 0.75rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">*/15 * * * *</code> <span style=\"color: var(--label-secondary, #98989D);\">→ Every 15 minutes</span></div>
            <div><code style=\"font-size: 0.75rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">0 9 * * 1</code> <span style=\"color: var(--label-secondary, #98989D);\">→ Every Monday at 9 AM</span></div>
        </div>
        
        <div style=\"background: var(--fill-quinary, rgba(116, 116, 128, 0.12));\">
            <div style=\"font-weight: 600; font-size: 0.75rem; margin-bottom: 8px; color: var(--control-accent, #0A84FF);\">✓ Allowed Commands</div>
            <div style=\"display: flex; flex-wrap: wrap; gap: 0.5rem;\">
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">php</code>
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">find</code>
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">ls</code>
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">cat</code>
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">head</code>
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">tail</code>
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">grep</code>
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">wc</code>
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">echo</code>
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">printf</code>
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">basename</code>
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">dirname</code>
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">realpath</code>
                <code style=\"background: var(--control-background, #2C2C2E); padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.7rem; color: var(--text-primary, #FFFFFF); font-family: var(--font-family-monospace, monospace);\">rm</code>
            </div>
        </div>
    </div>
</div>";


	echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type=hidden name=Edit value='$Edit'>
	<input type=hidden name=CronID value='$CronID'>


	<div class='DivInput {$Dir}DivInput'>Domain:<br>
	";

		echo "<select name='Domain' id='Domain' class=Select>";
		
		for ($E=0;$E<count($Account['Domain']);$E++)
		{
			if ($Account['Domain'][$E]==$_REQUEST['Domain'])
			{
			echo "<option value='{$Account['Domain'][$E]}' selected>{$Account['Domain'][$E]} ({$Account['Username'][$E]})</option>";
			}
			else
			{
			echo "<option value='{$Account['Domain'][$E]}'>{$Account['Domain'][$E]} ({$Account['Username'][$E]})</option>";
			}
		}

		echo "</select>
		
	</div>


	<div class='DivInput {$Dir}DivInput'>Cron Schedule:<br>
	<input type='text' name='Minute' value='$Minute' pattern='([0-5]?[0-9]|\*)' title='0-59 or *' size='3' required class=InputText style='width:9%;text-align:center'>
	<input type='text' name='Hour' value='$Hour' pattern='([01]?[0-9]|2[0-3]|\*)' title='0-23 or *' size='3' required class=InputText style='width:9%;text-align:center'>
	<input type='text' name='DayMonth' value='$DayMonth' pattern='(0?[1-9]|[12][0-9]|3[01]|\*)' title='1-31 or *' size='3' required class=InputText style='width:9%;text-align:center'>
	<input type='text' name='Month' value='$Month' pattern='(0?[1-9]|1[0-2]|\*)' title='1-12 or *' size='3' required class=InputText style='width:9%;text-align:center'>
	<input type='text' name='DayWeek' value='$DayWeek' pattern='([0-7]|\*)' title='0-7 (0/7=Sun) or *' size='3' required class=InputText style='width:9%;text-align:center'>
	</div>

	<div class='DivInput {$Dir}DivInput'>Command:<br>
	<input type='text' name='Command' value='$Command' maxlength=255 required class=InputText>
	</div>

	<div class='DivInput {$Dir}DivInput'>Description:<br>
	<input type='text' name='Description' value='$Description' maxlength=50 class=InputText>
	</div>

	<div id=DivSubmit class=DivSubmit>
	";

	if ($Edit==1)
	{
		echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
	}
	else
	{
		echo "<input type=submit value='{$LNG['Create']}' Class=InputButton>";
	}

	Echo "
	</div>


</form>


		<div class=DivXTable>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>
		
		<th align='$DAlign' width='20%'>
		{$LNG['Domain']}
		</th>
		
		<th align='$DAlign' width='20%'>
		Cron Schedule
		</th>
		
		<th align='$DAlign' width='20%'>
		Command
		</th>
		
		<th align='$DAlign' width='20%'>
		Description
		</th>

		<th align='$DAlign' width='5%'>
		Active
		</th>


		<th align='$OAlign' width='15%'>

		</th>

 		</THEAD>
		";
		
		$Table="Cron";$Field="CronID>=1";
		$DefaultSortBy="CronID";
		$DefaultDirection="DESC";
		include "include/sql.php";

		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
			$ID=$Row['CronID'];
		
			if ($X==0)
			{
			echo "<TBODY>";
			}

			if ($X%2==0)
			{
			$TDColor="Td";
			}
			else
			{
			$TDColor="TdB";
			}


			$CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);


			if ($Row['Active']==1)
			{
			$ActiveCode= "
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Active&Active={$Row['Active']}&Domain={$Row['Domain']}&CronID={$Row['CronID']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox' checked>
			<span></span>
			</label>	
			";
			}
			else
			{
			$ActiveCode="
			<label class='CheckboxToggle' onclick=\"javascript:Load('$CurrentFileName?Action=Active&Active={$Row['Active']}&Domain={$Row['Domain']}&CronID={$Row['CronID']}&Page=$Page&ScrollTo=TR{$ID}')\">
			<input type='checkbox'>
			<span></span>
			</label>	
			";
			}


			echo "
			<tr id='TR{$ID}' class='$TDColor' divid=Find find='{$Row['Domain']}-{$Row['Description']}'>

			<TD>{$Row['Domain']}</TD>
			
			<TD>
			{$Row['Minute']} {$Row['Hour']} {$Row['DayMonth']} {$Row['Month']} {$Row['DayWeek']}
			</TD>
			
			<TD>
			{$Row['Command']}
			</TD>

			<TD>
			{$Row['Description']}
			</TD>
			
			<TD>
			$ActiveCode
			</TD>

			<TD align='$OAlign'>
			
			<a href=\"javascript:Load('$CurrentFileName?Edit=1&CronID={$Row['CronID']}&Domain={$Row['Domain']}')\" class=Action>Edit</a>
			<a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&CronID={$Row['CronID']}&&Domain={$Row['Domain']}')\" class=Action>Delete</a>
			<a href=\"javascript:Load('$CurrentFileName?Action=Run&CronID={$Row['CronID']}&&Domain={$Row['Domain']}')\" class=Action>Run</a>

			</TD> 
			";
			
		$X++;
		}
			
		if ($X!=0)
		{
		echo "</TBODY>";
		}

		echo "
		<TFOOT>

		<tr class=TdDown>

		<th align='$DAlign' colspan=2>
		Showing $X of $RowsNo records.
		</th>
		
		<th align='$OAlign' colspan=3>
		";
				
		include "pages.php";

		echo "
		</th>

		</tr>

		</TFOOT>

		</TABLE>
		</div>
		";
		
?>