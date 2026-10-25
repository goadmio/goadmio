<?php
include "en.php";

// sort($LNG);

echo "<span class=notranslate>&lt?php</span><br>";

foreach($LNG as $Name => $Value) 
{
	echo "<span class=notranslate>\$LNG['".$Name."']=\"</span>$Value<span class=notranslate>\";</span><br>";
}

echo "<span class=notranslate>?&gt</span>";

?>