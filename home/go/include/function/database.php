<?php
function ReplaceInDatabase ($FindWhat,$ReplaceWith,$TableName)
{
	global $Sql;
	
	$ResultField = $PDO->query("select * from $TableName");
	$FieldsNo = mysql_num_fields($ResultField);
	
	$FieldNameString="";			
	for ($XField=0;$XField<$FieldsNo;$XField++)
	{
		
		
		$FieldName=mysql_field_name($ResultField, $XField);
		
		if ($XField==0)
		{
			$IDFieldName=$FieldName;
		}
		else
		{
			
			if ($XField+1==$FieldsNo)
			{
				$FieldNameString.="$FieldName=replace($FieldName,'$FindWhat','$ReplaceWith')";
			}
			else
			{
				$FieldNameString.="$FieldName=replace($FieldName,'$FindWhat','$ReplaceWith'),";
			}				
		}
	}
	
	$Sql = "UPDATE $Prefix".$TableName." SET $FieldNameString where $IDFieldName>=1";
	$Result = SQL($Sql);
	$AffectedRowsNo=$PDO->affected_rows;
	
	return $AffectedRowsNo;
}


function Insert ($TableName)
{
	extract($GLOBALS);
	
	$ResultField = $PDO->query("select * from $TableName");
	$FieldsNo = mysql_num_fields($ResultField);
	
	$FieldNameString="";			
	for ($XField=0;$XField<$FieldsNo;$XField++)
	{
		
		
		$FieldName=mysql_field_name($ResultField, $XField);
		
		if ($XField==0)
		{
			$IDFieldName=$FieldName;
		}
		else
		{
			
			if ($XField+1==$FieldsNo)
			{
				$FieldNameString.="$FieldName";
			}
			else
			{
				$FieldNameString.="$FieldName,";
			}				
		}
	}
	
	$FieldNameStringValues="'$".str_replace(",","','$",$FieldNameString)."'";
	
	$Sql = "INSERT INTO $TableName ($FieldNameString) VALUES ($FieldNameStringValues)";
	eval("\$Sql = \"$Sql\";");
	$Result = SQL($Sql);
	$ID=$PDO->lastInsertId(); 
	
	return $ID;
	
	
}




function AlterAdd($TableName,$StartField,$CreateSql)
{
	global $PDO;

	$CreateSqlArray=explode(",",$CreateSql);
	
	for ($X=0;$X<count($CreateSqlArray);$X++)
	{
		
		if ($X==0)
		{
			$FieldName=$StartField;
		}
		else
		{
			$FieldNameArray=explode (" ",$CreateSqlArray[$X-1]);
			$FieldName=$FieldNameArray[0];
		}
		
		$Sql ="ALTER TABLE $TableName ADD $CreateSqlArray[$X] AFTER $FieldName";
		$Result = SQL($Sql);
		if ($Result)
		{
		$AffectedRowsNo=$Result->fetchColumn();
		echo "<fieldset><legend>$Sql.</legend><span style='color:blue'> $AffectedRowsNo row(s) has been affected.</span></fieldset>";
		}
		else
		{
		echo "<fieldset><legend>$Sql.</legend><span style='color:red'>".$mysqli->error."</span></fieldset>";
		}
		
		flush();
	}
	
}

function AlterChange($TableName,$CreateSql)
{
$CreateSqlArray=explode(",",$CreateSql);

	for ($X=0;$X<count($CreateSqlArray);$X++)
	{
		$FieldNameArray=explode (" ",$CreateSqlArray[$X]);
		$FieldName=$FieldNameArray[0];
		
		$Sql ="ALTER TABLE $TableName CHANGE $FieldName $CreateSqlArray[$X]";
		$Result = SQL($Sql);
		$AffectedRowsNo=$Result->fetchColumn();
		if ($AffectedRowsNo==-1) {$FONTCOLOR="<span class=Error>";}else{$FONTCOLOR="";}
		echo "<fieldset><legend>$Sql.</legend>$FONTCOLOR $AffectedRowsNo row(s) has been affected.</span></fieldset>";
	}
	
}

function FieldToArray ($Sql,$FieldName)
{

	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
		
		if ($Row[$FieldName]!="")
		{
		$Array[]=$Row[$FieldName];
		}
	}
	
	if (count($Array)==0)
	{
	echo "$FieldName Field not found or Empty.";
	Exit;
	}
	else
	{
	return $Array;
	}
}



function Backup($TableName = '*',$TargetDir)
    {
	global $PDO;
	
            

            


            $return = '';

        
            $return .= "-- Database: ".DBName."\n";
			
			
            $return .= "--\n\n";
            $return .= "-- --------------------------------------------------------\n\n";

            $numtypes = array(
                'tinyint', 
                'smallint',
                'mediumint',
                'int',
                'bigint',
                'float',
                'double',
                'decimal',
                'real'
            );

            // get all of the tables
            if ($TableName == '*')
            {
                    $TableName = array();
                    $result = $PDO->query('SHOW TABLES');
                    while ($row = $result->fetch_row())
                    {
                            $TableName[] = $row[0];
                    }

                    $result->close();
            }
            else
            {
                    $TableName = is_array($TableName) ? $TableName : explode(',',$TableName);
            }

            for ($z = 0; $z == 0; $z++)
            {
                

            // cycle through tables
            foreach ($TableName as $table)
            {
                    //
                    $typesarr = array();
                    $result = $PDO->query("SHOW COLUMNS FROM `".$table."`");

                    foreach ($Result as $Row)
                    {
                            $typesarr[] = $row;
                    }
                    $result->close();

                    #echo '<h2>'.$table.'</h2>';
                    #print("<pre>" . print_r($typesarr, true). "</pre>");

                    // table structure dump
                    $return .= "--\n";
                    $return .= "-- Table structure for table `$table`\n";
                    $return .= "--\n\n";                        
                    $return.= 'DROP TABLE IF EXISTS `'.$table.'`;'."\n\n";
                    $result = $PDO->query("SHOW CREATE TABLE `".$table."`");
                    $row = $result->fetch_array();
                    $return.= $row[1].";\n\n";
                    $result->close();

                    // table data dump
                    $return .= "--\n";
                    $return .= "-- Dumping data for table `$table`\n";
                    $return .= "--\n\n";

                    $result = $PDO->query("SELECT * FROM `".$table."`");
                    $num_fields = $result->field_count;

                    if ($result->num_rows > 0)
                    {
                            // put field names in array and into sql insert for dump
                            $fields_str = '';
                            $fields =  array();
                            $finfo = $result->fetch_fields();

                            foreach ($finfo as $val)
                            {
                                    $fields_str .= '`'.$val->name.'`, ';
                                    $fields[] = $val->name;
                            }                                

                            $fields_str = '('.rtrim($fields_str, ', ').')';
                            $return.= 'INSERT INTO `'.$table.'` '.$fields_str.' VALUES'."\n";

                            // cycle through fields and check if int for later use
                            for ($i = 0; $i < $num_fields; $i++) 
                            {
                                    // strip brackets from type
                                    $acttype = trim(preg_replace('/\s*\([^)]*\)/', '', $typesarr[$i]['Type']));
                                    $acttype = explode(' ', $acttype);

                                    // build array, is field int or not
                                    if (is_numeric(array_search($acttype[0], $numtypes)))
                                    {
                                            $numflag[$i] = 1;
                                    }
                                    else
                                    {
                                            $numflag[$i] = 0;        
                                    }
                            }
                    }  

                    $x = 0;
                    $num_rows = $result->fetchColumn();

                    // cycle through table rows
                    while($row = $result->fetch_row())
                    {
                            $x++;

                            // cycle through rows fields
                            for($j=0; $j<$num_fields; $j++) 
                            {          
                                    if (isset($row[$j]) and $j === 0) { $return .= '('; }

                                    // field data has value or not NULL
                                    if (isset($row[$j]))
                                    { 
                                            // field data dump (INT)
                                            if ($numflag[$j]==1)
                                            {
                                                    #echo '(INT) '. $fields[$j].' = '.$row[$j].'<br>';
                                                    $return.= $row[$j];
                                            } 
                                            else
                                            {
                                                    // field data dump values (empty string, NULL and INT)
                                                    $return.= "'".$row[$j]."'";
                                                    #echo $fields[$j]." = '".$mysqli->real_escape_string($row[$j])."'<br>";
                                            }
                                    }
                                    else
                                    {
                                            // field data dump (NULL)
                                            if (is_null($row[$j]))
                                            {
                                                    $row[$j] = 'NULL';
                                                    #echo '(NULL) '. $fields[$j].' = '.$row[$j].'<br>';
                                                    $return.= $row[$j]; 
                                            }
                                            else
                                            {
                                                    // field data dump (empty string)
                                                    $return.= "''";
                                            }
                                    }

                                    if ($j<($num_fields-1)) { $return.= ', '; }
                            }

                            if ($x<$num_rows) { $return.= "),\n"; } else { $return .= ");\n"; }

                            #echo '<br>';
                    }
                    #echo 'Rows: '.$rows.'<br>';
                    #echo 'Iterations: '.$x.'<br>';
                    $return.="\n-- --------------------------------------------------------\n\n";
            }

            }

            $result->close();


				$Date=date ("Y-m-d");
			
				if (count($TableName)==1)
				{
				$FileName=$TableName[0];
				}
				else
				{
				$FileName=DBName;
				}


			if ($TargetDir=="PC")
			{

			
			header("Content-Type: plain/text");
			header("Content-Disposition: Attachment; filename=\"$FileName-$Date.sql\"");
			header("Pragma: no-cache");
			

			echo $return;
						
			}
			else
			{
            $handle = fopen($TargetDir."/$FileName-$Date.sql",'a');
            fwrite($handle,$return);
            fclose($handle);
			}
			
			
			
    }


?>