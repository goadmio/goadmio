<?php
function UTF8 ($String) 
{

	$Fixed = htmlspecialchars( $String, ENT_QUOTES );

	$TransArray = array();
	for ($i=1; $i<255; $i++)
	{
	$TransArray[chr($i)] = "&#" . $i . ";";
	}

   $Really_Fixed = strtr($Fixed, $TransArray);

   return $Really_Fixed;

}
?>
