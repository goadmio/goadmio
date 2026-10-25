<?php





include "navigator.php";
$Buttons="<a href=\"javascript:Load('$CurrentFileName?Action=Refresh')\" class='ButtonB {$Dir}ButtonB'>Refresh</a>";
include "title.php";

if ($Action=="Refresh")
{
	$Error=SSH ("/usr/bin/sudo screen -d -m bash -c '/go/httplog'",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
}



		include "search.php";
		
		Echo "
		<div class=DivTableX>
		<table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

		<THEAD>
		
		<tr>

		<th width='2%' height=40>

		</th>
		
		<th align='$DAlign' nowrap>
		{$LNG['Domain']}
		</th>
		
		<th align='$DAlign' nowrap>
		{$LNG['HTTP']}
		</th>
		
		<th align='$DAlign' nowrap>
		{$LNG['FTP']}
		</th>
		
		<th align='$DAlign' nowrap>
		{$LNG['Total']}
		</th>

		<th align='$DAlign' nowrap>
		{$LNG['BandwidthByCountry']}
		</th>

		<th align='$DAlign' nowrap>
		{$LNG['VisitorsByCountry']}
		</th>

		</tr>
		
		</THEAD>

		";
		
		$Table="Site";$Field="Trash=0";
		$DefaultSortBy="Domain";
		$DefaultDirection="ASC";
		include "include/sql.php";

		$X=0;
		$Result = SQL($Sql);
		foreach ($Result as $Row)
		{
		
			$Domain=$Row['Domain'];
			$Username=$Row['Username'];
			
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
			
			$SerialNo=(($Page-1)*$PageNo)+($X+1);
			
			Echo "
			<tr name=R$i id=R$i divid=Find find='{$Row['Username']}-{$Row['Domain']}-{$Row['Directory']}' class='$TDColor'>

			<TD align='middle' height=40>
			$SerialNo
			</span>
			</TD>
			";

			
				$Day=date("j");
				$Month=date("m");
				$Year=date("Y");

				$StartMonthStamp=strtotime ("$Year-$Month-01 00:00:00");
			
			
				$TOTAL=0;
				$HTTP=0;
				$ResultQ = SQL("SELECT SUM(ResponseSize) AS HTTP FROM Httplog where Domain='$Domain' and TimeStamp>='$StartMonthStamp'");
				foreach ($ResultQ as $RowQ)
				{
				$HTTP=$RowQ['HTTP'];
				$TOTAL=$RowQ['HTTP'];
				}

				$HTTP=FormatSize($HTTP);

				$FTP=0;
				$ResultQ = SQL("SELECT SUM(FileSize) AS FTP FROM Ftplog where Username='$Username' and Date like '%".date ("M Y")."%'");
				foreach ($ResultQ as $RowQ)
				{
				$FTP=$RowQ['FTP'];
				$TOTAL=$TOTAL+$RowQ['FTP'];
				}
				
				SQL("UPDATE Site set BandwidthUsed='$TOTAL' where Domain='$Domain'");
				
				$FTP=FormatSize($FTP);
				$TOTAL=FormatSize($TOTAL);
				



			
			Echo "<TD>{$Row['Domain']}</TD>";
			Echo "<TD nowrap>$HTTP</TD>";
			Echo "<TD>$FTP</TD>";
			Echo "<TD>$TOTAL</TD>";
			Echo "
			<TD>
			";
			
			$ResultQ = SQL("SELECT Country,SUM(ResponseSize) AS Size FROM Httplog where Domain='$Domain' and TimeStamp>='$StartMonthStamp' GROUP BY Country Order By Size DESC LIMIT 5");
			foreach ($ResultQ as $RowQ)
			{
				
				$Size=FormatSize($RowQ['Size']);

				echo "{$RowQ['Country']} $Size";
				echo "<hr>";
			}
			
			echo "
			</TD>
			
			<TD>
			";
			

			$ResultQ = SQL("SELECT Country,COUNT(Country) as PageViews,COUNT(distinct IP) as Visitors FROM Httplog where Domain='$Domain' and TimeStamp>='$StartMonthStamp' and HTTP=1 and Browser!='' and Method='GET' GROUP BY Country Order By PageViews DESC LIMIT 5");
			foreach ($ResultQ as $RowQ)
			{
				echo "{$RowQ['Country']} | {$RowQ['Visitors']} Visitors | {$RowQ['PageViews']} Page Views";
				echo "<hr>";
			}
			
			echo "
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

		<th align='$DAlign' colspan=3>
		Showing $X of $RowsNo records.
		</th>
		
		<th align='$OAlign' colspan=4>
		";
				
		include "pages.php";

		echo "
		</th>

		</tr>

		</TFOOT>

		</TABLE>
		</div>
		</form>
		";
		

?>