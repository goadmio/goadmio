<?php
$TextAreaName=$_REQUEST['TextAreaName'];
$FormName=$_REQUEST['FormName'];
$SwitchCase=$_REQUEST['SwitchCase'];
$Window=$_REQUEST['Window'];


if ($Service=="")
{
	$Service="popup";
}

$CurrentFileName=basename ($_SERVER['PHP_SELF']);
include "/usr/local/goadmio/include/config/config.php";
include("../../$AdminFolder/style/default.php");
include "/usr/local/goadmio/home/go/include/function/function.php";

Echo "<BODY onLoad=\"window.focus()\" text=#666699 bgcolor=#FFFFEE leftMargin=0 RightMargin=0 topMargin=0 marginheight=0 marginwidth=0>";


echo "<title>Upload - Powered by EM.com</title>";


if ($Window=="POPUP")	
{
	echo "

	<script type='text/javascript'>
	
	
	function SendUploadImg(ImgURL)
	{
	
		if ($SwitchCase==1)
		{
		opener.getIFrameDocument(\"Div$TextAreaName\").body.innerHTML=opener.getIFrameDocument(\"Div$TextAreaName\").body.innerHTML+'<img src='+ImgURL+'>';
		}
		else		
		{
		opener.$FormName.$TextAreaName.value=opener.$FormName.$TextAreaName.value+' '+'[IMG]'+ImgURL+'[/IMG]'+' ';
		}
	
	window.close();
	}
	
	</script>
	";
}

if ($Window=="IFRAME")	
{
	echo "

	<script type='text/javascript'>
	
	
	function SendUploadImg(ImgURL)
	{
	
		if ($SwitchCase==1)
		{
		top.getIFrameDocument(\"Div$TextAreaName\").body.innerHTML=top.getIFrameDocument(\"Div$TextAreaName\").body.innerHTML+'<img src='+ImgURL+'>';
		}
		else		
		{
		top.$FormName.$TextAreaName.value=top.$FormName.$TextAreaName.value+' '+'[IMG]'+ImgURL+'[/IMG]'+' ';
		}
	
	window.close();
	}
	
	</script>
	";
}


Echo "<table  cellPadding=1 cellSpacing='1' bgcolor=$BGColor[6] bordercolor=$BGColor[4] width='100%'><TD colspan=2 Align=Left BGColor=$BGColor[7] width='100%'>";

Echo "<table  cellPadding=1 cellSpacing=0 bgcolor=$BGColor[6] width='100%'>";
Echo "<TD ALIGN=Right BGColor=$BGColor[6] width='100%'>";

$TABLE="<table  cellPadding=0 cellSpacing=0 bgcolor=$BGColor[6] width='100%'>";
$TD[1]="<TD Colspan=2 ALIGN=Right BGColor=$BGColor[6] width='100%'>";
$TD[2]="<TD ALIGN=right BGColor=$BGColor[4] width='40%'>";
$TD[3]="<TD ALIGN=left BGColor=$BGColor[4] width='60%'>";

$TDLine[1]="<TD ALIGN=right BGColor=$BGColor[4] width='40%' height=1>";
$TDLine[2]="<TD ALIGN=right BGColor=$BGColor[6] width='60%' height=1>";

$STD="</TD>";
$TR="<TR>";
$STABLE="</TABLE>";




if ($_SERVER['REQUEST_METHOD']=="POST")
{
	Echo "
	$BREAK

	<table class=Table width='$InsideMiddleWidth'>
	";

	$IP = getenv ("REMOTE_ADDR");
	$ArrayBossIP=explode(".",$IP);
	$BossIP=$ArrayBossIP[0];

	$FileSizeMax="100000000000000000";
	
	// تحميل الملف المرفق
	iF ($_FILES[FileName]['name']!="none" and $_FILES[FileName]['name']!="")
	{
		$L=StrLen($_FILES[FileName]['name'])-4;
		$E=strtolower(SubStr($_FILES[FileName][name],$L,4));
		
		
		if (stristr("|*.gif|*.jpg|*.png|",$E))
		{
			if ($_FILES[FileName]['size']<=$FileSizeMax)
			{
				//
				// $Attach=$BossIP."-".time().$E;
				// for sequrity reason I remove file exetention
				$Attach=time();	

				// remove all . from filename for protect
				$Attach=str_replace(".","",$Attach);
				
				$AttachName=$FileName_name;
				
				$X=move_uploaded_file($_FILES[FileName][tmp_name],"../media/upload/editor/$Attach");
				
				IF ($X)
				{
					
					echo "<TD colspan=2 align=middle width='100%' bgcolor='#FFFFFF'> 
					<a href=\"javascript:SendUploadImg('$ScriptUrl/media/upload/editor/$Attach')\"'><img src='$ScriptUrl/media/upload/editor/$Attach' ></a>
					</td>";
					echo "<script type='text/javascript'>X=SendUploadImg('$ScriptUrl/media/upload/editor/$Attach')</script>";
				}
				ELSE
				{
					echo Error("Can not Upload file.");
				}
			}
			else
			{
				echo Error("File size is $FileName_size Bytes , it's more than alloed size ($FileSizeMax)");
			}
		}
		else
		{
			echo "<TD colspan=2 align=middle width='100%' bgcolor='#FFFFFF'>you can upload image file only.</td>";
			
		}
	}
	
	

	Echo "</TABLE>";

}



Echo "

	$TABLE

	<form Name=UploadImg method=post ENCTYPE='multipart/form-data' action='$CurrentFileName'>
	<input type=hidden name=SwitchCase value='$SwitchCase'>
	<input type=hidden name=document.forms['Form'].ame.value='$FormName'>
	<input type=hidden name=TextAreaName value='$TextAreaName'>
	<input type=hidden name=Service value='$Service'>
	<input type=hidden name=Window value='$Window'>
		
	<TD colspan=2 Align=middle background='theme/{$_SESSION['SessionTheme']}/image/bar-bg.gif' width='100%'>
	$FONT[1]
	Upload your image files
	</span>
	</TD>

	<TR>

	<TD colspan=2 Align=middle bgcolor='$BGColor[6]' width='100%' height=1>

	<TR>

	$TD[2]
	$FONT[3]
	<b>Upload file from your computer
	</TD>

	$TD[3]
	<input type=file name=FileName class=InputText>
	</TD>
	
	<TR>
	
	$TDLine[1] $TDLine[2]
	
	<TR>
	
	$TD[2]
	</TD>

	$TD[3]
	<input type=submit name='Submit' class=InputText>
	</TD>

	</TABLE>
	</form>

</td></TABLE>
";



?>
