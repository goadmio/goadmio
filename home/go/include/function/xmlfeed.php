<?php
function XMLFeed($Type,$FileName,$Service,$Limit)
{
	global $PDO,$ScriptUrl,$Lng;
	$LService=strtolower($Service);

	$FILE=@fopen("$FileName","w");
	if ($FILE)
	{
	
		
		fputs($FILE,"<?xml version='1.0' encoding='UTF-8'?>");
		fputs($FILE,"\n");		
		
		fputs($FILE,"<$Type>");
		fputs($FILE,"\n");				


			if ($Type=="Latest")
			{
				
				$Result = SQL("select * from $Service where Active=1 ORDER by ID DESC LIMIT $Limit");
				foreach ($Result as $Row)
				{
				
					$ID=$Row['ID'];
					
					if ($Lng)
					{
					$Item=$Row['EnItem'];
					}
					else
					{
					$Item=$Row['ArItem'];
					}
					

					$ShowPageUrl=EncodeUrl($LService,$Lng,$ID,$Item,"Show");

					if ($Item!="")
					{

						fputs($FILE,"	<Item><![CDATA[$Item]]></Item>");
						fputs($FILE,"\n");
						fputs($FILE,"	<ShowPageUrl>$ShowPageUrl</ShowPageUrl>");
						fputs($FILE,"\n");
						fputs($FILE,"\n");

					}
					

				}
			}
			

			if ($Type=="Parked")
			{
				$Result = SQL("select * from Domain where DomainID>=1 order by Title ASC LIMIT 100");
				foreach ($Result as $Row)
				{
				$Title=$Row['Title'];
				$Domain=$Row['Domain'];

					if ($Title!="" and $Domain!="")
					{

						fputs($FILE,"	<Title><![CDATA[$Title]]></Title>");
						fputs($FILE,"\n");
						fputs($FILE,"	<Domain><![CDATA[$Domain]]></Domain>");
						fputs($FILE,"\n");
						fputs($FILE,"\n");

					}
					

				}
			}
			
			if ($Type=="Country")
			{
				$Result = SQL("select * from Country,$Service where Country.CountryID=$Service.CountryID group by $Service.CountryID order by Country.EnCountry ASC");
				foreach ($Result as $Row)
				{
				$CountryID=$Row['CountryID'];
				$EnCountry=$Row['EnCountry'];

					if ($EnCountry!="")
					{

						fputs($FILE,"	<CountryID><![CDATA[$CountryID]]></CountryID>");
						fputs($FILE,"\n");
						fputs($FILE,"	<EnCountry>$EnCountry</EnCountry>");
						fputs($FILE,"\n");
						fputs($FILE,"\n");

					}
					

				}
			
			}
			
			
		fputs($FILE,"</$Type>");
		return (1);

	}
	else
	{
	return (0);
	}
	
	
	
} 

?>
