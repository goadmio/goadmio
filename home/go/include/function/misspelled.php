<?php
function Misspelled ($WordsArray,$SearchFor)
{

	// input misspelled word
	$InputSearchWord = $SearchFor;
	
	if (count($WordsArray)!=0)
	{
		// no shortest distance found, yet
		$Shortest = -1;
		
		// loop through words to find the closest
		foreach ($WordsArray as $Word) 
		{
			
			// calculate the distance between the input word and the current word
			$Lev = levenshtein($InputSearchWord, $Word);
			
			// check for an exact match
			if ($Lev == 0) 
			{
				
				// closest word is this one (exact match)
				$Closest = $Word;
				$Shortest = 0;
				
				// break out of the loop; we've found an exact match
				break;
			}
			
			// if this distance is less than the next found shortest
			// distance, OR if a next shortest word has not yet been found
			if ($Lev <= $Shortest || $Shortest < 0) 
			{
				// set the closest match, and shortest distance
				$Closest  = $Word;
				$Shortest = $Lev;
			}
		}
		


		return $Closest;

		
	}
}



function Similar ($WordsArray,$SearchFor)
{
$LP=0;

	foreach ($WordsArray as $Word) 
	{
	
		similar_text($Word,$SearchFor,$P);

		if ($P>$LP)
		{
		$Closest=$Word;
		$LP=$P;
		}
	
	}

		return $Closest;
	
	
}


function DeeplySimilar ($Sql,$FieldName,$SearchFor)
{
	$A=Misspelled (FieldToArray($Sql,$FieldName),$SearchFor);
	$B=Similar (FieldToArray($Sql,$FieldName),$SearchFor);

	if ($A==$B)
	{
	return $A;
	}
	else
	{
	return "";
	}
}


?>