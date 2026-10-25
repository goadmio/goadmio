<?php

	function BBCode($String)
	{
	$String=trim($String);
	
    //$String = str_replace(">", "&gt;", $String);
    //$String = str_replace("<", "&lt;", $String);


    	$SimpleSearch = array(
				'#  #si',
				'#\t#si',
                '/\[b\](.*?)\[\/b\]/is',                                 
                '/\[i\](.*?)\[\/i\]/is',                                 
                '/\[u\](.*?)\[\/u\]/is',                                 
				'/\[ShowTitle\](.*?)\[\/ShowTitle\]/is',   
				'/\[ShowUnderTitle\](.*?)\[\/ShowUnderTitle\]/is',  
				'/\[Question\](.*?)\[\/Question\]/is',   
				'/\[Answer\](.*?)\[\/Answer\]/is',   
				'/\[Head\](.*?)\[\/Head\]/is',   
				'/\[Message\](.*?)\[\/Message\]/is',   
                '/\[url\=(.*?)\](.*?)\[\/url\]/is',                          
                '/\[url\](.*?)\[\/url\]/is',                              
                '/\[align\=(left|center|right)\](.*?)\[\/align\]/is',     
                '/\[img\](.*?)\[\/img\]/is',                             
                '/\[mail\=(.*?)\](.*?)\[\/mail\]/is',                     
                '/\[mail\](.*?)\[\/mail\]/is',  
                '/\[email\=(.*?)\](.*?)\[\/email\]/is',                     
                '/\[email\](.*?)\[\/email\]/is',   				
                '/\[font\=(.*?)\](.*?)\[\/font\]/is',                     
                '/\[size\=(.*?)\](.*?)\[\/size\]/is',                     
                '/\[color\=(.*?)\](.*?)\[\/color\]/is',  
				'/\[highlight\=(.*?)\](.*?)\[\/highlight\]/is',
				'#\[(\/)indent\]#si',
				'#\[(sub|sup|strike|blockquote|hr|b|i|u)\]#si',
				'#\[\/(sub|sup|strike|blockquote|b|i|u)\]#si',
				'#\[center\]#si',
				'#\[left\]#si',
				'#\[right\]#si',
				'#\[justify\]#si',
				'#\[\/(center|left|right|justify)\]#si',
				'#\[FLASH=(.*?),(.*?)\](.*?)\[\/FLASH\]#si'
                ); 

    $SimpleReplace = array( 
				'&nbsp;&nbsp;', 
				'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',
                '<strong>$1</strong>', 
                '<em>$1</em>', 
                '<u>$1</u>', 
				'<span class=ShowTitle>$1</span>', 
				'<span class=ShowUnderTitle>$1</span>',
				'<span class=Question>$1</span>', 
				'<span class=Answer>$1</span>', 
				'<span class=Head>$1</span>', 
				'<span class=Message>$1</span>', 
                '<a href="$1" target="_blank">$2</a>', 
                '<a href="$1" target="_blank">$1</a>', 
                '<div style="text-align: $1;">$2</div>', 
                '<img src="$1" />', 
                '<a href="mailto:$1">$2</a>', 
                '<a href="mailto:$1">$1</a>', 
				'<a href="mailto:$1">$2</a>', 
                '<a href="mailto:$1">$1</a>', 
                '<span style="font-family: $1;">$2</span>', 
                '<span size=$1>$2</span>', 
                '<span style="color: $1;">$2</span>', 
				'<span style="background-color: $1;">$2</span>',
				'<$1blockquote>',
				'<$1>',
				'</$1>',
				'<div align="center">',
				'<div align="left">',
				'<div align="right">',
				'<div align="justify">',
				'</div>',
				'<object width="$1" height="$2"><param name="movie" value="$3"></param><param name="wmode" value="transparent"></param><embed src="$3" type="application/x-shockwave-flash" wmode="transparent" width="$1" height="$2"></embed></object>',
                ); 

    		// Do simple BBCode's 
    		$String = preg_replace ($SimpleSearch, $SimpleReplace, $String); 


		// [CODE]  [/CODE] > [code] must be small leter
	    $String = str_ireplace("[code]","[code]",$String);
	   	$String = str_ireplace("[/code]","[/code]",$String);
	
		$String=BBCodeCode($String);
	
	
	
		// [PHP]  [/PHP]
			$String = str_ireplace("[php]","[php]",$String);
			$String = str_ireplace("[/php]","[/php]",$String);
	
		$String=BBCodePHP($String);
		
	
	
	
	
	
	
	
	    	$String = str_ireplace("\r\n[output]\r\n","[output]",$String);
	   	$String = str_ireplace("\r\n[/output]","[/output]",$String);
	
		// [output]  [/output]
		$String=BBCodeOutput($String);
	
	
	
	       	$String = str_replace("\r\n", "<br />",$String);


	return $String;
	}

	function BBCodeCode($Input)
	{
	global $Lng;

	        $RegEx = '#\[code]((?:[^[]|\[(?!/?code])|(?R))+)\[/code]#';

	    	if (is_array($Input)) 
		{
		$Input1=$Input[1];


			$CountLines=substr_count($Input1, "\n")+1;
			
			for ($x=1;$x<=$CountLines;$x++)
			{
			$LineCode=$LineCode."$x<br />";
			}


			if ($Lng=="ar")
			{
		        $LNG['Code']="كود";
			}
			else
			{
		        $LNG['Code']="Code";
			}


		$Input ="<fieldset style='width:95%;background:#F8F8F8;'><legend>{$LNG['Code']}:</legend><p dir=ltr style='margin:0;'><table align=center cellSpacing=0 cellPadding=1 bgcolor=#F8F8F8 width='100%' ><td align=right valign=top background='image/bbcode/code.gif' width=4% class=Pre><span style='color:#0a00a0'><span face=Fixedsys>$LineCode</span></td><td bgcolor=#cccccc width='1%'><td bgcolor=#F8F8F8 width='1%'><td valign=top bgcolor=#F8F8F8 width=94%><pre class=Pre><span face=Fixedsys>$Input1</span></xmp></td></table></fieldset>";
 		}
	
	return preg_replace_callback($RegEx,'BBCodeCode',$Input);
	}

	
	
	function BBCodePHP($Input)
	{
	global $Lng;

	    $RegEx = '#\[php]((?:[^[]|\[(?!/?php])|(?R))+)\[/php]#';
			
		if (is_array($Input)) 
		{
		$Input1=$Input[1];
		

			$CountLines=substr_count($Input1, "\n")+1;
			
			for ($x=1;$x<=$CountLines;$x++)
			{
			$LineCode=$LineCode."$x<br />";
			}


			if ($Lng=="ar")
			{
		        $LNG['PHPCode']=" كود بى اتش بى";
			}
			else
			{
		        $LNG['PHPCode']="PHP Code";
			}


		$Input ="<fieldset style='width:95%;background:#F8F8F8;'><legend>{$LNG['PHPCode']}:</legend><p dir=ltr style='margin:0;'><table align=center cellSpacing=0 cellPadding=1 bgcolor=#F8F8F8 width='100%' ><td align=right valign=top background='image/bbcode/code.gif' width=4% class=Pre><span style='color:#0a00a0'><span face=Fixedsys>$LineCode</span></td><td bgcolor=#cccccc width='1%'><td bgcolor=#F8F8F8 width='1%'><td valign=top bgcolor=#F8F8F8 width=94%><pre class=Pre><span face=Fixedsys>$Input1</span></xmp></td></table></fieldset>";


 		}
	
	return preg_replace_callback($RegEx,'BBCodePHP',$Input);
	}
	
	



	function BBCodeOutput($Input)
	{
	global $Lng;

	        $RegEx = '#\[output]((?:[^[]|\[(?!/?output])|(?R))+)\[/output]#';

	    	if (is_array($Input)) 
		{
		$Input1=$Input[1];


			if ($Lng=="ar")
			{
		        $LNG['Output']="المخرجات";
			}
			else
			{
		        $LNG['Output']="Output";
			}

		$Input ="<fieldset style='width:95%;background:#F8F8F8'><legend>{$LNG['Output']}:</legend><p dir=ltr style='margin:0;'><table align=center cellSpacing=0 cellPadding=1 bgcolor=#D0D0BF width='100%' ><td bgcolor=#F8F8F8 width='95%'>$Input1</td></table></fieldset>";
 		}
	
	return preg_replace_callback($RegEx,'BBCodeOutput',$Input);
	}
	
	
	



?>
