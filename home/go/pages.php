<?php

	$FilterSql = str_replace("'", "|Apostrophe|", $FilterSql);
	$FilterSql = str_replace(" ", "|Space|", $FilterSql);
	$SearchFor = str_replace("'", "|Apostrophe|", $SearchFor);
	$SearchFor = str_replace(" ", "|Space|", $SearchFor);

	// طباعة ارقام الصفحات 
	$MaxPage=(Int) ((($RowsNo-1)/$PageNo)+1);

	$FromPage=floor($Page-$PageBarNo/2);
	if ($FromPage<=0) {$FromPage=1;}

if ($MaxPage>=2)
{


	$NewFromPage=$FromPage+$PageBarNo;
	if ($NewFromPage<=$MaxPage)
	{
		$PageLink="$CurrentFileName?Page=$NewFromPage&SearchFor=$SearchFor&Service=$Service&FilterSql=$FilterSql&SortBy=$SortBy&FromPage=$NewFromPage&$Parameters";
		$NextPage="<a href=\"javascript:Load('$PageLink')\"><div class=Pages>Next</div></a>";
	}	    	

	if ($NewFromPage>$PageBarNo+1)
	{
		$NewPrevFromPage=$NewFromPage-($PageBarNo*2);
		if ($NewPrevFromPage<1) {$NewPrevFromPage=1;}

		$PageLink="$CurrentFileName?Page=$NewPrevFromPage&SearchFor=$SearchFor&Service=$Service&FilterSql=$FilterSql&SortBy=$SortBy&FromPage=$NewPrevFromPage&$Parameters";
		$PrevPage="<a href=\"javascript:Load('$PageLink')\"><div class=Pages>Prev</div></a>";
		
	}

	$ToPage=$FromPage+($PageBarNo-1);
	if ($ToPage>$MaxPage)
	{
		$ToPage=$MaxPage;
	}
	

	for ($i=$FromPage ;$i<=$ToPage ; $i++)
	{
		
		If ($i==$Page)
		{
			Echo "<div class=PagesOver>$i</div>";
		}
		Else
		{
			
			$PageLink="$CurrentFileName?Page=$i&SearchFor=$SearchFor&Service=$Service&FilterSql=$FilterSql&SortBy=$SortBy&Direction=$Direction&FromPage=$FromPage&$Parameters";
			Echo "<a href=\"javascript:Load('$PageLink')\"><div class=Pages>$i</div></a>";
		}
	}

	$FromPage=$MaxPage-$PageNo; if ($FromPage<1) {$FromPage=1;}
	$ToPage=$MaxPage;
	$PageLink="$CurrentFileName?Page=1&SearchFor=$SearchFor&Service=$Service&FilterSql=$FilterSql&SortBy=$SortBy&FromPage=1&$Parameters";
	Echo "<a href=\"javascript:Load('$PageLink')\"><div class=Pages>&lt</div></a>";
	
	$PageLink="$CurrentFileName?Page=$MaxPage&SearchFor=$SearchFor&Service=$Service&FilterSql=$FilterSql&SortBy=$SortBy&Direction=$Direction&FromPage=$FromPage&$Parameters";
	echo "<a href=\"javascript:Load('$PageLink')\"><div class=Pages>&gt</div></a>";

	Echo "$PrevPage";
	Echo "$NextPage";



}


?>