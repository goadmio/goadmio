<?php

	function Advertise($AdvertiseMessage,$AdvertiseTitle,$AdvertiseWidth,$StartX,$StartY)
	{
	global $Theme;
	
	if ($Theme=="default")
	{
	$TColor="#ffffff";
	}
	else
	{
	$TColor="#505050";
	}
	
	
	if ($StartX=="")
	{
	$StartX=10;
	}
	
	if ($StartY=="")
	{
	$StartY=10;
	}
	
	$AdvertiseCode="

	<script type='text/javascript'>
	var persistclose=0 
	var startX = $StartX;
	var startY = $StartY; 
	var verticalpos='fromtop' //enter 'fromtop' or 'frombottom'

	function iecompattest()
	{
	return (document.compatMode && document.compatMode!=\"BackCompat\")? document.documentElement : document.body
	}

	function CloseAdvertiseBar()
	{

	document.getElementById(\"AdvertiseBar\").style.visibility=\"hidden\";
	}

	function StaticBar()
	{
	barheight=document.getElementById(\"AdvertiseBar\").offsetHeight
	var ns = (navigator.appName.indexOf(\"Netscape\") != -1) || window.opera;
	var d = document;
	function ml(id){
	var el=d.getElementById(id);
	if (!persistclose || persistclose && get_cookie(\"remainclosed\")==\"\")
	el.style.visibility=\"visible\"
	if(d.layers)el.style=el;
	el.sP=function(x,y){this.style.left=x+\"px\";this.style.top=y+\"px\";};
	el.x = startX;
	if (verticalpos==\"fromtop\")
	el.y = startY;
	else{
	el.y = ns ? pageYOffset + innerHeight : iecompattest().scrollTop + iecompattest().clientHeight;
	el.y -= startY;
	}
	return el;
	}
	window.stayTopLeft=function(){
	if (verticalpos==\"fromtop\"){
	var pY = ns ? pageYOffset : iecompattest().scrollTop;
	ftlObj.y += (pY + startY - ftlObj.y)/8;
	}
	else{
	var pY = ns ? pageYOffset + innerHeight - barheight: iecompattest().scrollTop + iecompattest().clientHeight - barheight;
	ftlObj.y += (pY - startY - ftlObj.y)/8;
	}
	ftlObj.sP(ftlObj.x, ftlObj.y);
	setTimeout(\"stayTopLeft()\", 10);
	}
	ftlObj = ml(\"AdvertiseBar\");
	stayTopLeft();
	}

	if (window.addEventListener)
	window.addEventListener(\"load\", StaticBar, false)
	else if (window.attachEvent)
	window.attachEvent(\"onload\", StaticBar)
	else if (document.getElementById)
	window.onload=StaticBar
	</script> 
	
	<style>
	.AdvertiseTitle {FONT-WEIGHT:normal;FONT-SIZE: 12px; COLOR: $TColor; FONT-FAMILY: Arial,Times New Roman,Verdana}
	.AdvertiseMessage {FONT-WEIGHT: bold;FONT-SIZE: 14px; COLOR: #000000; FONT-FAMILY: Times New Roman}
	</style>

	<div id=\"AdvertiseBar\" style='position:absolute;border: 0px solid black;padding: 0px;width: $AdvertiseWidth"."px;visibility: hidden;z-index: 0;'> 
	<table  cellPadding=0 cellSpacing='1' bgcolor=#505050 width='100%'>
	<TD bgcolor=#505050 width='100%'>
		
		<table style='border: 0px solid green;padding:3px; border-collapse: collapse; width: 100%'>
		<td background='../media/image/advertise/$Theme/title-bg.gif' width=98% class=AdvertiseTitle height=20>
		$AdvertiseTitle
		</TD>
		<td background='../media/image/advertise/$Theme/title-bg.gif' width='2%' class=AdvertiseTitle>
		<a onclick=\"CloseAdvertiseBar();\"><img src='../media/image/advertise/$Theme/close.gif' onmouseover=\"this.src='../media/image/advertise/$Theme/close-on.gif';\" onmouseout=\"this.src='../media/image/advertise/$Theme/close.gif';\" hspace=1 hspace=10 ></a>
		</td>
		
		<TR>
		
		<td bgcolor=#505050 colspan=2 height=1></td>
		
		<TR>
		<td colspan=2 background='../media/image/advertise/$Theme/bg.gif' width='100%' class=AdvertiseMessage>
		$AdvertiseMessage
		</td>
		</table>
	</TD>
	</TABLE>
	</div> 
	";

	return $AdvertiseCode;
	}
?>