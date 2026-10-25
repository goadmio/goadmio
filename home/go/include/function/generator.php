<?php

function TitleGenerator($Server,$Lng,$EnItem,$ArItem,$DistrictID,$CityID,$EnDistrict,$ArDistrict,$EnCity,$ArCity,$EnMetaKeywords,$ArMetaKeywords,$PropertyFor,$Mobile)
{
	$Stamp=time();

	IF ($Server==0)
	{
	srand ((float) microtime() * 1000000);
	$Server=rand(1,3);
	}


	if ($Lng=="en")
	{
	$Title=$EnItem;
	}
	else
	{
	$Title=$ArItem;
	}

	if ($Stamp%5==0)
	{
		if ($Lng=="en")
		{
		$ExtraTitle=" Call: {$Mobile}";
		}
		else
		{
		$ExtraTitle=" اتصل الان: {$Mobile}";
		}
	}

	if ($Lng=="ar")
	{
			if ($Server==2)
			{
				if ($DistrictID>=1)
				{
					if ($Stamp%40==0)
					{
					$Title="كمبوند {$ArDistrict} {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==1)
					{
					$Title="موقع كمبوند  {$ArDistrict} {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==2)
					{
					$Title="اسعار كمبوند {$ArDistrict} {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==3)
					{
					$Title="مكان كمبوند {$ArDistrict}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==4)
					{
					$Title="اسعار {$ArDistrict}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==5)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="عقارات للبيع فى {$ArDistrict}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="عقارات للايجار قى {$ArDistrict}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==6)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="{$ArCategory} للبيع فى {$ArDistrict}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="{$ArCategory} للايجار فى {$ArDistrict}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==7)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="{$ArCategory} {$ArDistrict} للبيع{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="{$ArCategory} {$ArDistrict} للايجار{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==8 and $PropertyFor=="Sale")
					{
						$Title="{$ArDistrict} {$ArCity} الاسعار وانظمة السداد{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==9 and $PropertyFor=="Sale")
					{
						$Title="اسعار {$ArCategory} {$ArDistrict}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==10 and $PropertyFor=="Sale")
					{
						$Title="اسعار {$ArCategory} {$ArDistrict} {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==11 and $PropertyFor=="Sale")
					{
						$Title="اسعار {$ArCategory} كمبوند {$ArDistrict}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==12 and $PropertyFor=="Sale")
					{
						$Title="اسعار {$ArCategory} كمبوند {$ArDistrict} {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==13 and $PropertyFor=="Sale")
					{
						$Title="{$ArDistrict} {$ArCity} للبيع بالتقسيط{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==14 and $PropertyFor=="Sale")
					{
						$Title="{$ArDistrict}  ريسيل{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==15 and $PropertyFor=="Sale")
					{
						$Title="{$ArDistrict} {$ArCity} ريسيل{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==16 and $PropertyFor=="Sale")
					{
						$Title="سعر المتر في {$ArDistrict} {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==17 and $PropertyFor=="Sale")
					{
						$Title="رقم كمبوند {$ArDistrict} {$ArCity} {$Mobile}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==18 and $PropertyFor=="Sale")
					{
						$Title="رقم كمبوند {$ArDistrict} {$Mobile}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==19 and $PropertyFor=="Sale")
					{
						$Title="مشروع {$ArDistrict} {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==20 and $PropertyFor=="Sale")
					{
						$Title="مشروع {$ArDistrict}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==21)
					{
						if ($Lng=="en")
						{
						$Title="{$EnItem} | {$ArItem}";
						}
						else
						{
						$Title="{$ArItem} | {$EnItem}";
						}
					}
					elseif ($Stamp%50==22 and $PropertyFor=="Sale")
					{
						$Title="{$ArDistrict} {$ArCity} اسعار{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==23)
					{
						$Title="اين تقع {$ArDistrict} {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==24)
					{
						$Title="اين تقع {$ArDistrict}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==25)
					{
						$Title="{$ArDistrict} مصر{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==26 and $PropertyFor=="Sale")
					{
					$Title="اسعار كمبوند {$ArDistrict} 2018{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==27 and $PropertyFor=="Sale")
					{
					$Title="اسعار كمبوند {$ArDistrict} 2018 للبيع بالتقسيط{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==28 and $PropertyFor=="Sale")
					{
					$Title="{$ArDistrict} {$ArCity} للبيع من المالك {$Mobile}, $Title";
					}
					elseif ($Stamp%50==29 and $PropertyFor=="Sale")
					{
					$Title="{$ArDistrict} للبيع من المالك {$Mobile}, $Title";
					}
					elseif ($Stamp%50==30 and $PropertyFor=="Sale")
					{
					$Title="مشروع {$ArDistrict}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==31 and $PropertyFor=="Sale")
					{
					$Title="مشروع {$ArDistrict} {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==32)
					{
					$Title="افضل كمبوند فى {$ArCity} - {$ArDistrict}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==33 and $PropertyFor=="Sale")
					{
					$Title="احلى كمبوند فى {$ArCity} - {$ArDistrict} {$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==34 and $PropertyFor=="Sale")
					{
					$Title="ارخص كمبوند فى مصر - {$ArDistrict} {$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==35 and $PropertyFor=="Sale")
					{
					$Title="ارخص كمبوند فى {$ArCity} - {$ArDistrict} {$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==36 and $PropertyFor=="Sale")
					{
					$Title="افضل كمبوند في مصر - {$ArDistrict} {$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==37)
					{
					$Title="افضل كمبوندات {$ArCity} - {$ArDistrict}{$ExtraTitle}, $Title";
					}	
					elseif ($Stamp%50==38)
					{
					$Title="اسماء كمبوندات {$ArCity} - {$ArDistrict}{$ExtraTitle}, $Title";
					}	
					elseif ($Stamp%50==39)
					{
					$Title="كمبوندات {$ArCity} 2018 - {$ArDistrict}{$ExtraTitle}, $Title";
					}	
					elseif ($Stamp%50==40)
					{
					$Title="مشاكل كمبوند {$ArDistrict}{$ExtraTitle}, $Title";
					}	
					elseif ($Stamp%50==41 and $PropertyFor=="Sale")
					{
					$Title="{$ArCategory} للبيع بالتقسيط على 10 سنوات في كمبوند {$ArDistrict} {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==42)
					{
					$Title="احسن كمبوند في مصر - {$ArDistrict}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==43)
					{
					$Title="احسن كمبوند في {$ArCity} - {$ArDistrict}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==44)
					{
					$Title="ارخص شقق بالتقسيط في مصر - {$ArDistrict}{$ExtraTitle}, $Title";
					}
					else
					{
					$Title="{$ArDistrict} {$ArCity}{$ExtraTitle}, $Title";
					}
					
				}
				else
				{

					if ($Stamp%40==0)
					{
					$Title="اسعار {$ArCity} {$ArRegion}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==1)
					{
					$Title="اسعار {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==2)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="عقارات للبيع فى {$ArCity}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="عقارات للايجار فى {$ArCity}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==3)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="{$ArCategory} للبيع فى {$ArCity}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="{$ArCategory} للايجار فى {$ArCity}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==4)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="{$ArCategory} للبيع {$ArCity}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="{$ArCategory} للايجار {$ArCity}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==5)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="عقارات للبيع فى {$ArCity} {$ArRegion}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="عقارات للايجار فى {$ArCity} {$ArRegion}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==6)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="{$ArCategory} للبيع فى {$ArCity} {$ArRegion}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="{$ArCategory} للايجار فى {$ArCity} {$ArRegion}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==7)
					{
						if ($Lng=="en")
						{
						$Title="{$EnItem} | {$ArItem}";
						}
						else
						{
						$Title="{$ArItem} | {$EnItem}";
						}
					}
					elseif ($Stamp%50==8)
					{
					$Title="افضل كمبوند فى {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==9)
					{
					$Title="اسماء كمبوندات {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==10 and $PropertyFor=="Sale")
					{
					$Title="اسعار الكمبوند فى {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==11 and $PropertyFor=="Sale")
					{
					$Title="احلى كمبوند فى {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==12)
					{
					$Title="افضل كمبوندات {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==13 and $PropertyFor=="Sale")
					{
					$Title="{$ArCategory} كمبوند {$ArCity} بالتقسيط{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==14 and $PropertyFor=="Sale")
					{
					$Title="{$ArCategory} كمبوند {$ArCity} تقسيط{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==15 and $PropertyFor=="Sale")
					{
					$Title="{$ArCategory} للبيع بالتقسيط 2018 - {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==16 and $PropertyFor=="Sale")
					{
					$Title="{$ArCategory} تقسيط على 10 سنوات - {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==17 and $PropertyFor=="Sale")
					{
					$Title="{$ArCategory} تقسيط على 10 سنوات 2018 - {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==18 and $PropertyFor=="Sale")
					{
					$Title="{$ArCategory} تقسيط على 7 سنوات 2018 - {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==19)
					{
					$Title="افضل احياء {$ArCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==20 and $PropertyFor=="Sale" and $CategoryID==1)
					{
					$Title="ارخص شقق بالتقسيط في {$ArCity}{$ExtraTitle}, $Title";
					}
					else
					{
					$Title="{$ArCity} {$ArRegion}{$ExtraTitle}, $Title";
					}
				}
			
			
			}
			elseif ($Server==3)
			{
				$KeywordsAray=explode(",",$ArMetaKeywords);
			
				shuffle($KeywordsAray);
				
				$Title="{$KeywordsAray['0']}{$ExtraTitle}, $Title";
			}

			
	}
	else
	{
			if ($Server==2)
			{

				if ($DistrictID>=1)
				{
				
					if ($DistrictID==1449)
					{
						if (stristr($EnItem,"villa"))
						{
						
							if ($PropertyFor=="Sale")
							{
							$Title="فيلا نموذج a للبيع بكمبوند ديار المخابرات{$ExtraTitle}";
							}
							else
							{
							$Title="فيلا نموذج a للايجار بكمبوند ديار المخابرات{$ExtraTitle}";
							}
						
						}
						else
						{
							if ($PropertyFor=="Sale")
							{
							$Title="تاون هاوس نموذج a للبيع بكمبوند ديار المخابرات{$ExtraTitle}";
							}
							else
							{
							$Title="تاون هاوس نموذج a للايجار بكمبوند ديار المخابرات{$ExtraTitle}";
							}
						}
						
						
					}
					elseif ($Stamp%40==0)
					{
					$Title="{$EnDistrict} compound {$EnCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%40==1)
					{
					$Title="compound {$EnDistrict} {$EnCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==2)
					{
					$Title="{$EnDistrict} {$EnCity} location{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==3)
					{
					$Title="{$EnDistrict} {$EnCity} prices{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==4)
					{
					$Title="{$EnDistrict} location{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==5)
					{
					$Title="{$EnDistrict} prices{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==6)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="Properties for sale in {$EnDistrict}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="Properties for rent in {$EnDistrict}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==7)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="Properties for sale in {$EnDistrict} {$EnCity}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="Properties for rent in {$EnDistrict} {$EnCity}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==8)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="{$EnCategory} for sale in {$EnDistrict}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="{$EnCategory} for rent in {$EnDistrict}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==9)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="{$EnDistrict} {$EnCategory} for sale{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="{$EnDistrict} {$EnCategory} for rent{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==10 and $PropertyFor=="Sale")
					{
						$Title="{$EnDistrict} {$EnCity} for sale with installments{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==11 and $PropertyFor=="Sale")
					{
						$Title="{$EnDistrict} for sale with installments{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==12 and $PropertyFor=="Sale")
					{
						$Title="{$EnDistrict} {$EnCategory} for sale with installments{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==13 and $PropertyFor=="Sale")
					{
						$Title="{$EnDistrict} {$EnCity} payment plan{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==14 and $PropertyFor=="Sale")
					{
						$Title="{$EnDistrict} payment plan{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==15 and $PropertyFor=="Sale")
					{
						$Title="{$EnDistrict} {$EnCity} resale{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==16 and $PropertyFor=="Sale")
					{
						$Title="{$EnDistrict} resale{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==17 and $PropertyFor=="Sale")
					{
						$Title="{$EnDistrict} master plan{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==18 and $PropertyFor=="Sale")
					{
						srand ((float) microtime() * 1000000);
						$ParcelNo=rand(1,23);
		
						$Title="{$EnDistrict} parcel $ParcelNo{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==19 and $PropertyFor=="Sale")
					{
						srand ((float) microtime() * 1000000);
						$ParcelNo=rand(1,23);
		
						$Title="{$EnDistrict} {$EnCity} parcel $ParcelNo{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==20 and $PropertyFor=="Sale")
					{
						srand ((float) microtime() * 1000000);
						$YearNo=rand(7,10);
		
						$Title="Installments over $YearNo years in {$EnDistrict} {$EnCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==21 and $PropertyFor=="Sale")
					{
						srand ((float) microtime() * 1000000);
						$YearNo=rand(7,10);
		
						$Title="Installments over $YearNo years in {$EnDistrict}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==22 and $PropertyFor=="Sale")
					{
							$Title="{$EnDistrict} {$EnCity} layout{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==23 and $PropertyFor=="Sale")
					{
							$Title="{$EnDistrict} layout{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==24 and $PropertyFor=="Sale")
					{
							$Title="{$EnDistrict} hotline: {$Mobile}, $Title";
					}
					elseif ($Stamp%50==25 and $PropertyFor=="Sale")
					{
							$Title="{$EnDistrict} {$EnCity} hotline: {$Mobile}, $Title";
					}
					elseif ($Stamp%50==26 and $PropertyFor=="Sale")
					{
							$Title="{$EnDistrict} number: {$Mobile}, $Title";
					}
					elseif ($Stamp%50==27 and $PropertyFor=="Sale")
					{
							$Title="{$EnDistrict} {$EnCity} number: {$Mobile}, $Title";
					}
					elseif ($Stamp%50==28 and $PropertyFor=="Sale")
					{
							$Title="{$EnDistrict} developer{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==29 and $PropertyFor=="Sale")
					{
							$Title="{$EnDistrict} developments{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==30)
					{
							srand ((float) microtime() * 1000000);
							$ParcelNo=rand(1,7);
						
							$Title="{$EnDistrict} $ParcelNo{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==31)
					{
							$Title="{$EnDistrict} brochure{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==32)
					{
							$Title="{$EnDistrict} properties{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==33)
					{
							$Title="{$EnDistrict} {$EnCity} brochure{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==34)
					{
							$Title="{$EnDistrict} {$EnCity} by owner {$Mobile}, $Title";
					}
					elseif ($Stamp%50==35)
					{
							$Title="{$EnDistrict} for sale by owner {$Mobile}, $Title";
					}
					elseif ($Stamp%50==36)
					{
							$Title="{$EnDistrict} {$EnCity} address{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==37)
					{
						if ($Lng=="en")
						{
						$Title="{$EnDistrict} {$EnCity} | {$ArDistrict} {$ArCity}{$ExtraTitle}";
						}
						else
						{
						$Title="{$ArDistrict} {$ArCity} | {$EnDistrict} {$EnCity}{$ExtraTitle}";
						}
					}
					elseif ($Stamp%50==38 and $PropertyFor=="Sale")
					{
						$Title="resale {$EnCategory} {$EnDistrict} {$EnCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==39 and $PropertyFor=="Sale")
					{
						$Title="resale {$EnCategory} {$EnDistrict}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==40 and $PropertyFor=="Sale")
					{
						srand ((float) microtime() * 1000000);
						$YearNo=rand(7,10);
		
						$Title="installments up to $YearNo years in {$EnDistrict} {$EnCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==41 and $PropertyFor=="Sale")
					{
						srand ((float) microtime() * 1000000);
						$YearNo=rand(7,10);
		
						$Title="{$EnCategory} installments up to $YearNo years in {$EnDistrict} {$EnCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==42 and $PropertyFor=="Sale")
					{
						srand ((float) microtime() * 1000000);
						$YearNo=rand(7,10);
		
						$Title="{$EnCategory} installments up to $YearNo years for sale in {$EnDistrict} {$EnCity}{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==43 and $PropertyFor=="Sale")
					{
						if ($PropertyFor=="Sale")
						{
						$Title="{$EnDistrict} {$EnCity} {$EnCategory} for sale{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="{$EnDistrict} {$EnCity} {$EnCategory} for rent{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==44)
					{
						if ($Lng=="en")
						{
						$Title="compound {$EnDistrict} {$EnCity} | كمبوند {$ArDistrict} {$ArCity}{$ExtraTitle}";
						}
						else
						{
						$Title="كمبوند {$ArDistrict} {$ArCity} | compound{$EnDistrict} {$EnCity}{$ExtraTitle}";
						}
					}
					else
					{
					//$Title="{$EnDistrict} {$EnCity}{$ExtraTitle}, $Title";
					
						if ($Lng=="en")
						{
						$Title="{$EnDistrict} {$EnCity} | {$ArDistrict} {$ArCity}{$ExtraTitle}";
						}
						else
						{
						$Title="{$ArDistrict} {$ArCity} | {$EnDistrict} {$EnCity}{$ExtraTitle}";
						}
					
					}
					
				}
				else
				{

					if ($Stamp%40==0)
					{
					$Title="{$EnCity} {$EnRegion} prices{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==1)
					{
					$Title="{$EnCity} prices{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==2)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="Properties for sale in {$EnCity}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="Properties for rent in {$EnCity}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==3)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="{$EnCategory} for sale in {$EnCity}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="{$EnCategory} for rent in {$EnCity}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==4)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="Properties for sale in {$EnCity} {$EnRegion}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="Properties for rent in {$EnCity} {$EnRegion}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==5)
					{
						if ($PropertyFor=="Sale")
						{
						$Title="{$EnCategory} for sale in {$EnCity} {$EnRegion}{$ExtraTitle}, $Title";
						}
						else
						{
						$Title="{$EnCategory} for rent in {$EnCity} {$EnRegion}{$ExtraTitle}, $Title";
						}
					}
					elseif ($Stamp%50==6 and $PropertyFor=="Sale")
					{
						$Title="{$EnCity} projects{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==7 and $PropertyFor=="Sale")
					{
						$Title="{$EnCity} new projects{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==8 and $PropertyFor=="Sale")
					{
						$Title="{$EnCity} properties{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==9 and $PropertyFor=="Sale")
					{
						$Title="{$EnCity} properties for sale{$ExtraTitle}, $Title";
					}
					elseif ($Stamp%50==10)
					{
						$Title="{$EnCity} location{$ExtraTitle}, $Title";
					}
					else
					{
					$Title="{$EnCity} {$EnRegion}{$ExtraTitle}, $Title";
					}

				}
			}
			elseif ($Server==3)
			{
				$KeywordsAray=explode(",",$EnMetaKeywords);
			
				shuffle($KeywordsAray);
				
				$Title="{$KeywordsAray['0']}{$ExtraTitle}, $Title";
			}
		
	}
	
	
	if ($Server==1)
	{
	
		if ($Stamp%2==0)
		{
		$Title=str_ireplace ("New Cairo","fifth settlement",$Title);
		}
		else
		{
		$Title=str_ireplace ("New Cairo","5th settlement",$Title);
		}
		
		$Title=str_ireplace ("القاهرة الجديدة","التجمع الخامس",$Title);
	
		$Title=str_ireplace ("6th of October","October",$Title);
		$Title=str_ireplace ("6 of October","October",$Title);
		$Title=str_ireplace ("6 ctober","October",$Title);
		$Title=str_ireplace ("Sheikh Zayed City","Sheikh Zayed",$Title);
		$Title=str_ireplace ("Sokhna","Sukhna",$Title);
		$Title=str_ireplace ("North Coast","sahel",$Title);
		$Title=str_ireplace ("heliopolis","masr el gedida",$Title);
		$Title=str_ireplace ("Mostakbal city","future city",$Title);
		$Title=str_ireplace ("Mostakbal","future city",$Title);

	
	}
	
	

return $Title;
}

?>