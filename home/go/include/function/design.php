<?php
// Emanage Template Engine 
// Powered by EMط¢آ® Version 1.0.6 www.mls.com.eg
// Copyright &copy; 2008-2011 mls.com.eg Enterprises Limited. All rights reserved.

function DesignFile($FilePath)
{
	
	$FILE=@fopen("$FilePath", "r");
	if ($FILE)
	{
		while (!feof($FILE)) 
		{
			$DesignCode .= fread($FILE, 8192);
		}
		
		fclose($FILE);			
	}
	else
	{
		echo "$FilePath File not found.";
	}
	
	return DesignCode($DesignCode,$FilePath);
}

function DesignCode($DesignCode,$DesignName)
{
	if ($DesignCode!="")
	{
		extract($GLOBALS);
		
		$DesignCode = str_ireplace("<space>","&nbsp;", $DesignCode);
		$DesignCode = str_ireplace("<tab>","&nbsp;&nbsp;&nbsp;&nbsp;", $DesignCode);
		$DesignCode = str_ireplace("[BR]",$BREAK, $DesignCode);
		
		if (stristr($DesignCode,"<php>") or stristr($DesignCode,"</rem>") or stristr($DesignCode,"</loop>") or stristr($DesignCode,"</sql>") or stristr($DesignCode,"</xtable>") or stristr($DesignCode,"</if>") or stristr($DesignCode,"</switch>") or stristr($DesignCode,"</math>") or stristr($DesignCode,"</print>") or stristr($DesignCode,"</switch>") or stristr($DesignCode,"</string>") or stristr($DesignCode,"</foreach>"))
		{
			$DesignCode = str_ireplace("<php>","</code>\";", $DesignCode);
			$DesignCode = str_ireplace("</php>","echo \"<code>", $DesignCode);
			
			$DesignCode = str_replace("echo \\","echo ",$DesignCode);
			
			
			$SlashQS='\";';
			$QS='";';
			$DesignCode = str_replace("$SlashQS","$QS",$DesignCode);
			
			// Designe Commands
			
			// Foreach
			$DesignCode=ForeachTags($DesignCode);
			
			
			// Rem 
			$DesignCode=RemTags($DesignCode);
			
			// Example 1
			// <rem> comment </rem>
			// End Rem
			
			
			// Math
			$DesignCode=MathTags($DesignCode);
			
			// Example 1
			// <math>$A=5+20</math>
			// <print>$A</print>
			
			// Example 2
			// <math>5*10</math>
			// End Math
			
			// Print
			$DesignCode=PrintTags($DesignCode);
			
			
			
			
			// Example 1
			// <math>$A=5+20</math>
			// <print>$A</print>
			// End Print
			
			// Assign
			$DesignCode=AssignTags($DesignCode);
			
			// Example 1
			// <assign>$A="Khaled"</assign>
			// <print>$A</print>
			// End Assign
			
			
			// String
			$DesignCode=StringTags($DesignCode);
			
			// Example 1
			// <len>KHALED</len>
			// End String
			
			// IF 
			$DesignCode=IFTags($DesignCode);
			$DesignCode=str_ireplace("<else>","</code>\";} else {echo \"<code>",$DesignCode);
			// END IF 
			
			// Loop 
			$DesignCode=LoopTags($DesignCode);
			
			// Example 1
			// <loop start=10 end=25 value=loop rotate="Red,Blue,#ffddcc" cycle=$Color>
			// <span color=$Color>khaled $loopd <br />
			// </loop>
			
			// Example 2 (Array)
			// <loop value=loop array=$ArrayVar rotate="Red,Blue,#ffddcc" cycle=$Color>
			// <span color=$Color>khaled $loopd <br />
			// </loop>
			// END Loop
			
			
			// Xtable
			$DesignCode=XTableTags($DesignCode);
			
			// Example 1
			// <xtable align=center start=1 end=21 cols=3 CellPadding=1 cellSpacing='1' value=var rotate="10%,20%,70%" cycle=CellWidth CellBGColor=yellow width='50%'><span style='color:#00ff00'>khad </xtable>
			// End Xtable
			
			// Switch & Case
			$DesignCode=SwitchTags($DesignCode);
			$DesignCode=CaseTags($DesignCode);
			
			// Example
			// <switch $Var>
			// <case $Var="1"> Var equal one </case>
			// <case $Var="2"> Var equal Two </case>
			// </switch>
			
			// END Switch 
			
			
			
			// Debug Tags
			
			
			$DesignCode = "echo \"<code>".$DesignCode."</code>\";";	
			
			// END DESIGN COMMAND
			
			// Sql 
			$DesignCode=SqlTags($DesignCode);
			
			// Example 1
			// 
			// 
			// 	
			
			
			if (trim($DesignCode)!="");	
			{
				// Replace " with \" until I can echo html code with no prblem
				$DesignCode=HTMLQuotation($DesignCode);
				
				// DELETE <CODE> & </CODE>
				$DesignCode=str_replace("<code>","",$DesignCode);
				$DesignCode=str_replace("</code>","",$DesignCode);
				
				$DesignCode=trim(str_replace('echo "";','',$DesignCode));
				
				
				
				$DesignCodeLog=$DesignCode;
				$DesignNameLog=$DesignName;
				
				$DesignCode.= "\nreturn true;";
				ob_start();
				
				// echo php_syntax_error ($DesignCode);

				$CheckEval=eval ($DesignCode);
				$DesignCode = ob_get_contents();
				
				
				
				
				
				ob_end_clean();
				if (!$CheckEval == true) 
				{
					$Error=error_get_last();
					echo "Compilation error in Emanage template code:<br />Template: $DesignNameLog<br />Type: {$Error['type']}<br />Message: {$Error['message']}<br />Line: {$Error[line]}";
					include "include/function/log.php";
				}							
				
			}
		}
		else
		{
			$Quotation='\"';
			$DesignCode=str_replace("\"","$Quotation",$DesignCode);
			eval("\$DesignCode = \"$DesignCode\";");
		}
		
		
		return $DesignCode;
	}
}

function LoopTags($Input)
{
	extract($GLOBALS);
	
	$RegEx = '#\<loop([\$\#\~\!\@\%\^\&\*\+\-\_\[\]\=\|\,\"\'\ a-zA-Z0-9]*)>((?:[^<]|\<(?!/?loop)|(?R))+)\</loop>#';
	
	if (is_array($Input)) 
	{
		$Input1=trim($Input[1]);
		
		// strips excess whitespace from a string
		$Input1 = preg_replace("/\s\s+/"," ", $Input1);
		
		$Input1 = str_replace("\"","", $Input1);
		
		eval("\$Input1 = \"$Input1\";");
		
		$Input1 = str_ireplace("start=","Start=", $Input1);	
		$Input1 = str_ireplace("end=","End=", $Input1);
		$Input1 = str_ireplace("value=","Value=", $Input1);
		$Input1 = str_ireplace("array=","Array=", $Input1);
		$Input1 = str_ireplace("cycle=","Cycle=", $Input1);
		$Input1 = str_ireplace("rotate=","Rotate=", $Input1);
		$Input1 = str_ireplace(" ","&", $Input1);
		
		parse_str ($Input1);
		
		
		// default
		if ($Start=="") {$Start=0;}
		if ($End=="") {$End=1;}
		if ($Value=="") {$Value="loop";}
		if ($Cycle=="") {$Cycle="cycle";}
		
		
		$Value="$"."$Value";
		$Array="$"."$Array";
		$Cycle="$"."$Cycle";
		
		
		if ($End>=$Start)
		{
			$PM="++";
			$GL="<=";
		}
		
		if ($End<$Start) 
		{
			$PM="--";
			$GL=">=";
		}
		
		
		
		// Loop Array 
		if (strlen($Array)>1)
		{
			$PM="++";
			$GL="<=";
			
			if ($Rotate!="")
			{
				
				//
				$RotateCount=substr_count($Rotate,",")+1;
				
				$VariableName=str_replace("$","",$Cycle);
				$RotateArray=explode (",",$Rotate);
				
				$RotateCode="";	
				for ($x=0;$x<=$RotateCount-1;$x++)
				{
					$RotateCode=$RotateCode."if ($"."Rotate$VariableName % $RotateCount==$x"."){"."$Cycle=\"$RotateArray[$x]\";}";
				}
				
				if (stristr($Explode[0],"-"))
				{
					$Part=explode("-",$Explode[0]);
				}
				
				if (stristr($Explode[0]," to "))
				{
					$Part=explode(" to ",$Explode[0]);
				}
				
				$Input ="</code>\"; "."$"."Rotate$VariableName=0; for ($Value=0;$Value".$GL."count($Array)-1;$Value$PM){"."$RotateCode "."$"."Rotate$VariableName=$"."Rotate$VariableName+1  ;echo \"<code>$Input[2]</code>\";} echo \"<code>";
				
			}
			else
			{
				$Input ="</code>\"; for ($Value=$Start;$Value".$GL."count($Array);$Value$PM){echo \"<code>$Input[2]</code>\";} echo \"<code>";
			}
			
		}
		else
		{
			// loop not array
			
			if ($Rotate!="")
			{
				
				//
				$RotateCount=substr_count($Rotate,",")+1;
				
				$VariableName=str_replace("$","",$Cycle);
				$RotateArray=explode (",",$Rotate);
				
				$RotateCode="";	
				for ($x=0;$x<=$RotateCount-1;$x++)
				{
					$RotateCode=$RotateCode."if ($"."Rotate$VariableName % $RotateCount==$x"."){"."$Cycle=\"$RotateArray[$x]\";}";
				}
				
				if (stristr($Explode[0],"-"))
				{
					$Part=explode("-",$Explode[0]);
				}
				
				if (stristr($Explode[0]," to "))
				{
					$Part=explode(" to ",$Explode[0]);
				}
				
				$Input ="</code>\"; "."$"."Rotate$VariableName=0; for ($Value=$Start;$Value".$GL."$End;$Value$PM){"."$RotateCode "."$"."Rotate$VariableName=$"."Rotate$VariableName+1  ;echo \"<code>$Input[2]</code>\";} echo \"<code>";
				
			}
			else
			{
				$Input ="</code>\"; for ($Value=$Start;$Value".$GL."$End;$Value$PM){echo \"<code>$Input[2]</code>\";} echo \"<code>";
			}
			
			
		}
		
		
		
	}
	
	return preg_replace_callback($RegEx,'LoopTags',$Input);
}

function SqlTags($Input)
{
	extract($GLOBALS);
	
	$RegEx = '#\<sql ([\$\[\]\(\)\,\ \_\-\!\=\"\.\'a-zA-Z0-9]*)>((?:[^<]|\<(?!/?sql)|(?R))+)\</sql>#';
	
	if (is_array($Input)) 
	{
		$Input1=trim($Input[1]);
		
		// strips excess whitespace from a string
		$Input1 = preg_replace("/\s\s+/"," ", $Input1);
		
		$Input1 = str_ireplace("value=\"","Value=[", $Input1);
		$Input1 = str_ireplace("name=\"","Name=[", $Input1);
		$Input1 = str_ireplace("\"","]", $Input1);
		
	
		
		preg_match("/\[(.*?)\]/i",$Input1,$T);
		$Value=trim($T[1]);
		

		// default
		// if ($Name=="") {$Name="Row";}
		
		
		
		echo "======= ".$Value." ====";

		$Input ="</code>\"; while ($"."RowQQQ = mysql_fetch_array($PDO->query(\"$Value\"))){echo \"<code>$Input[2]</code>\";} echo \"<code>";
			
		echo $Input;
			
	}
	
	return preg_replace_callback($RegEx,'SqlTags',$Input);
}


function IfTags($Input)
{
	//$RegEx = '#\<if ([\$\[\]\(\)\,\ \_\-\!\=\"\.\%\'a-zA-Z0-9]*)>((?:[^<]|\<(?!/?if)|(?R))+)\</if>#';
	//$ReplaceWith ="</code>\"; if (\$1){echo \"<code>$2</code>\";} echo \"<code>";
	//return preg_replace($RegEx,$ReplaceWith,$Input);

	$Input=preg_replace("/<if (.*?)>/i","</code>\"; if ($1){echo \"<code>",$Input);
	$Input=str_ireplace("</if>","</code>\";} echo \"<code>",$Input);

	return $Input;
}

function XTableTags($Input)
{
	extract($GLOBALS);
	
	$RegEx = '#\<xtable([\$\#\~\!\@\%\^\&\*\+\-\[\]\=\|\,\"\'\ a-zA-Z0-9]*)>((?:[^<]|\<(?!/?xtable)|(?R))+)\</xtable>#';
	
	
	if (is_array($Input)) 
	{
		$Input1=trim($Input[1]);
		
		// strips excess whitespace from a string
		$Input1 = preg_replace("/\s\s+/"," ", $Input1);
		
		$Input1 = str_replace("\"","", $Input1);
		
		eval("\$Input1 = \"$Input1\";");
		
		$Input1 = str_ireplace("start=","Start=", $Input1);	
		$Input1 = str_ireplace("end=","End=", $Input1);
		$Input1 = str_ireplace("value=","Value=", $Input1);
		$Input1 = str_ireplace("cols=","Cols=", $Input1);
		$Input1 = str_ireplace("cellspacing=","CellSpacing=", $Input1);
		$Input1 = str_ireplace("cellpadding=","CellPadding=", $Input1);
		$Input1 = str_ireplace("border=","Border=", $Input1);
		$Input1 = str_ireplace("bgcolor=","BGColor=", $Input1);
		
		$Input1 = str_ireplace("background=","BackGround=", $Input1);
		$Input1 = str_ireplace("cellbackground=","CellBackGround=", $Input1);
		
		$Input1 = str_ireplace("cellbgcolor=","CellBGColor=", $Input1);
		$Input1 = str_ireplace("width=","Width=", $Input1);
		$Input1 = str_ireplace("cellwidth=","CellWidth=", $Input1);
		$Input1 = str_ireplace("align=","Align=", $Input1);
		$Input1 = str_ireplace("cellalign=","CellAlign=", $Input1);
		
		$Input1 = str_ireplace("cycle=","Cycle=", $Input1);
		$Input1 = str_ireplace("rotate=","Rotate=", $Input1);
		$Input1 = str_ireplace(" ","&", $Input1);
		
		parse_str ($Input1);
		
		
		// default
		if ($Start=="") {$Start=0;}
		if ($End=="") {$End=1;}
		if ($CellSpacing=="") {$CellSpacing="0";}
		if ($CellPadding=="") {$CellPadding="0";}
		if ($Border=="") {$Border="0";}
		if ($BGColor=="") {$BGColor="#000000";}
		if ($CellBGColor=="") {$CellBGColor="#FFFFFF";}
		
		
		
		if ($Width=="") {$Width="100%";}
		if ($Align=="") {$Align="center";}
		
		
		
		if ($Value=="") {$Value="var";}
		if ($Cycle=="") {$Cycle="cycle";}
		
		
		$Value="$"."$Value";
		$Cycle="$"."$Cycle";
		
		
		
		if ($End>=$Start)
		{
			$PM="++";
			$GL="<=";
		}
		
		if ($End<$Start) 
		{
			$PM="--";
			$GL=">=";
		}
		
		
		
		$RotateCount=substr_count($Rotate,",")+1;
		
		$VariableName=str_replace("$","",$Cycle);
		$RotateArray=explode (",",$Rotate);
		
		$RotateCode="";	
		for ($x=0;$x<=$RotateCount-1;$x++)
		{
			$RotateCode=$RotateCode."if ($"."Rotate$VariableName % $RotateCount==$x"."){"."$Cycle=\"$RotateArray[$x]\";}";
		}
		
		
		$Input ="</code>\";"."$"."CellAlign='$CellAlign'; "."$"."CellWidth='$CellWidth'; "."$"."CellBGColor='$CellBGColor'; "."$"."CellBackGround='$CellBackGround';"."$"."Rotate$VariableName=0;$"."Xtable=0"."; echo \"<table align='$Align' bgcolor='$BGColor' background='$BackGround' CellSpacing='$CellSpacing' CellPadding='$CellPadding' border='$Border' width='$Width'>\";for ($Value=$Start;$Value".$GL."$End;$Value$PM){"."$RotateCode "."$"."Rotate$VariableName=$"."Rotate$VariableName+1;"."$"."Xtable=$"."Xtable+1 ; echo \" <code> <td align='$"."CellAlign' BGColor='$"."CellBGColor' background='$"."CellBackGround' width='$"."CellWidth'>$Input[2]</td> </code>\";  if ($"."Xtable % $Cols==0 and $"."Xtable<$End){echo \"<TR>\";}} echo \"</table>\"; echo \"<code>";
		
		
		
	}
	
	return preg_replace_callback($RegEx,'XTableTags',$Input);
}

function SwitchTags($Input)
{
	
	$RegEx = '#\<switch ([\$a-zA-Z0-9]*)>((?:[^<]|\<(?!/?switch)|(?R))+)\</switch>#';
	

	$ReplaceWith ="</code>\"; switch($1){ $2 } echo \"<code>";
	
	
	return preg_replace($RegEx,$ReplaceWith,$Input);
}

function CaseTags($Input)
{
	
	$RegEx = '#\<case ([\$a-zA-Z0-9]*)=([\$\"a-zA-Z0-9]*)>((?:[^<]|\<(?!/?case)|(?R))+)\</case>#';
	
	
	if (is_array($Input)) 
	{
		
		$CaseValue=str_replace("\"","",$Input[2]);
		$Input ="case \"$CaseValue\": echo \"<code> $Input[3] </code>\";break;";
		
	}
	
	return preg_replace_callback($RegEx,'CaseTags',$Input);
}

function ForeachTags($Input)
{
	$Input=preg_replace('/<foreach\s+array=\$([a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*)\s+value=\$([a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*)\s*>/','</code>"; foreach ($$1 as $$2) {echo "<code>',$Input);
	$Input=str_ireplace("</foreach>","</code>\";} echo \"<code>",$Input);
	
	return $Input;
}

function RemTags($Input)
{
	$RegEx = '#\<rem>((?:[^<]|\<(?!/?rem)|(?R))+)\</rem>#';


	return preg_replace($RegEx,"",$Input);
}

function MathTags($Input)
{
	$RegEx = '#\<math>((?:[^<]|\<(?!/?math)|(?R))+)\</math>#';
	if (is_array($Input)) 
	{
		if (stristr($Input[1],"="))
		{
			$Input ="</code>\"; $Input[1]; echo \"<code>";
		}
		else
		{
			$Input ="</code>\"; echo $Input[1]; echo \"<code>";
		}
	}
	return preg_replace_callback($RegEx,'MathTags',$Input);
}

function PrintTags($Input)
{
	$RegEx = '#\<print>((?:[^<]|\<(?!/?print)|(?R))+)\</print>#';
	$ReplaceWith ="</code>\"; echo $1; echo \"<code>";
	return preg_replace($RegEx,$ReplaceWith,$Input);
}

function AssignTags($Input)	
{
	$RegEx = '#\<assign>((?:[^<]|\<(?!/?assign)|(?R))+)\</assign>#';

	$ReplaceWith ="</code>\"; $1; echo \"<code>";
	
	return preg_replace($RegEx,$ReplaceWith,$Input);
}

function StringTags($Input)
{
	
	$RegEx = '#\<string([\$\#\~\!\@\%\^\&\*\+\-\[\]\=\|\,\"\'\ a-zA-Z0-9]*)>((?:[^<]|\<(?!/?string)|(?R))+)\</string>#';
	
	if (is_array($Input)) 
	{
		
		$Input1=trim($Input[1]);
		
		// strips excess whitespace from a string
		$Input1 = preg_replace("/\s\s+/"," ", $Input1);
		
		$Input1 = str_replace("\"","", $Input1);
		
		eval("\$Input1 = \"$Input1\";");
		
		$Input1 = str_ireplace("function=","Function=", $Input1);	
		$Input1 = str_ireplace("value=","Value=", $Input1);
		$Input1 = str_ireplace("replacewith=","ReplaceWith=", $Input1);
		$Input1 = str_ireplace("matchcase=","MatchCase=", $Input1);
		$Input1 = str_ireplace(" ","&", $Input1);
		
		parse_str ($Input1);
		
		// default
		if ($Function=="") {$Function="len";}
		if ($Value=="") {$Value=" ";}
		if ($MatchCase=="") {$MatchCase="false";}
		
		$Function=strtolower($Function);
		
		$MatchCase=strtolower($MatchCase);
		
		$Input2=str_replace ("\"","\\\"",$Input[2]);
		
		if ($Function=="len")
		{
			$Input ="</code>\"; echo strlen(\"$Input2\"); echo \"<code>";
		}
		elseif ($Function=="words")
		{
			$Input2=trim("$Input2");
			// strips excess whitespace from a string
			$Input2 = preg_replace("/\s\s+/"," ", $Input2);
			$Input ="</code>\"; echo count(explode(\" \",\"$Input2\")); echo \"<code>";
		}
		elseif ($Function=="upper")
		{
			
			$Value=strtolower($Value);
			if ($Value=="words")
			{
				$Input ="</code>\"; echo ucwords(\"$Input2\"); echo \"<code>";
			}
			elseif ($Value=="first")
			{
				$Input ="</code>\"; echo ucfirst(\"$Input2\"); echo \"<code>";
				// <string function=upper value=first>egypt</string>
			}
			else
			{
				$Input ="</code>\"; echo strtoupper(\"$Input2\"); echo \"<code>";
			}
		}
		elseif ($Function=="lower")
		{
			$Input ="</code>\"; echo strtolower(\"$Input2\"); echo \"<code>";
		}
		elseif ($Function=="trim")
		{
			$Input ="</code>\"; echo trim(\"$Input2\"); echo \"<code>";
		}
		elseif ($Function=="trim")
		{
			$Input ="</code>\"; echo trim(\"$Input2\"); echo \"<code>";
		}
		elseif ($Function=="html")
		{
			$Input ="</code>\"; echo htmlspecialchars(\"$Input2\"); echo \"<code>";
		}
		elseif ($Function=="parse")
		{
			$Input ="</code>\"; parse_str(\"$Input2\"); echo \"<code>";
			// Exam
			// <string function=parse>Name=Khaled&Age=29</string>
			// <print>$Age<print>
		}
		elseif ($Function=="md5")
		{
			$Input ="</code>\"; echo md5(\"$Input2\"); echo \"<code>";
		}
		elseif ($Function=="shuffle")
		{
			$Input ="</code>\"; echo str_shuffle(\"$Input2\"); echo \"<code>";
		}
		elseif ($Function=="striptags")
		{
			$Input ="</code>\"; echo strip_tags(\"$Input2\"); echo \"<code>";
			// <string function=striptags><b><i>Khaled</i></b></string>
		}
		elseif ($Function=="reverse")
		{
			$Input ="</code>\"; echo strrev(\"$Input2\"); echo \"<code>";
			// <string function=Reverse><b>Khaled</string>
		}
		
		
		
		
		elseif ($Function=="count")
		{
			$Input ="</code>\"; echo substr_count(\"$Input2\",\"$Value\"); echo \"<code>";
		}
		elseif ($Function=="repeat")
		{
			$Input ="</code>\"; echo str_repeat(\"$Input2\",\"$Value\"); echo \"<code>";
			// Exam : <string function=repeat value=10>Khaled <br /></string>
		}
		elseif ($Function=="join")
		{
			$Input ="</code>\"; echo join(\"$Value\",$Input2); echo \"<code>";
			// Exam : <string function=join value=",">$Array</string>
		}
		elseif ($Function=="replace")
		{
			if ($MatchCase=="false")
			{
				$Input ="</code>\"; echo str_ireplace(\"$Value\",\"$ReplaceWith\",\"$Input2\"); echo \"<code>";
			}
			else
			{
				$Input ="</code>\"; echo str_replace(\"$Value\",\"$ReplaceWith\",\"$Input2\"); echo \"<code>";
			}
		}
		else
		{
			// if function not found
			$Input ="</code>\"; echo strlen(\"$Input2\"); echo \"<code>";
		}
		
		
		
		
		
		
		
		
		
		
	}
	
	return preg_replace_callback($RegEx,'StringTags',$Input);
}

function HTMLQuotation($String)
{
	$Quotation='\"';
	
	$Tablo=explode("<code>",$String);
	$String="";
	$String.=$Tablo[0];
	foreach($Tablo as $Cle=>$Valeur)
	{
		if(stristr($Valeur,"</code>"))
		{
			$TabloOne=explode("</code>",$Valeur);
			$TabloOne[0]=str_ireplace("\"","$Quotation",$TabloOne[0]);
			
			foreach($TabloOne as $CleOne=>$ValeurOne)
			{
				if($CleOne==0)
				$ValeurOne="<code>".$ValeurOne."</code>";
				$String.=$ValeurOne;
			}
		}        
	}
	return $String;
} 


function php_syntax_error($code){
    if(!defined("CR"))
        define("CR","\r");
    if(!defined("LF"))
        define("LF","\n") ;
    if(!defined("CRLF"))
        define("CRLF","\r\n") ;
    $braces=0;
    $inString=0;
    foreach (token_get_all('<?php ' . $code) as $token) {
        if (is_array($token)) {
            switch ($token[0]) {
                case T_CURLY_OPEN:
                case T_DOLLAR_OPEN_CURLY_BRACES:
                case T_START_HEREDOC: ++$inString; break;
                case T_END_HEREDOC:   --$inString; break;
            }
        } else if ($inString & 1) {
            switch ($token) {
                case '`': case '\'':
                case '"': --$inString; break;
            }
        } else {
            switch ($token) {
                case '`': case '\'':
                case '"': ++$inString; break;
                case '{': ++$braces; break;
                case '}':
                    if ($inString) {
                        --$inString;
                    } else {
                        --$braces;
                        if ($braces < 0) break 2;
                    }
                    break;
            }
        }
    }
    $inString = @ini_set('log_errors', false);
    $token = @ini_set('display_errors', true);
    ob_start();
    $code = substr($code, strlen('<?php '));
    $braces || $code = "if(0){{$code}\n}";
    if (eval($code) === false) {
        if ($braces) {
            $braces = PHP_INT_MAX;
        } else {
            false !== strpos($code,CR) && $code = strtr(str_replace(CRLF,LF,$code),CR,LF);
            $braces = substr_count($code,LF);
        }
        $code = ob_get_clean();
        $code = strip_tags($code);
        if (preg_match("'syntax error, (.+) in .+ on line (\d+)$'s", $code, $code)) {
            $code[2] = (int) $code[2];
            $code = $code[2] <= $braces
                ? array($code[1], $code[2])
                : array('unexpected $end' . substr($code[1], 14), $braces);
        } else $code = array('syntax error', 0);
    } else {
        ob_end_clean();
        $code = false;
    }
    @ini_set('display_errors', $token);
    @ini_set('log_errors', $inString);
    return $code;
}




?>
