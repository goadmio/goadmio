<?php

	function Topic($TopicSize)
	{
	global $Lng,$Service,$LService,$Theme,$SecretCode,$Prefix;


	
	if ($TopicSize=="")
	{
	$TopicSize=1;
	}



	if ($Lng=="ar")
	{
	$DAlign="right";
	$OAlign="left";
	$LeftPx="-1px";
	}
	else
	{
	$DAlign="left";
	$OAlign="right";
	$LeftPx="-1px";
	}






echo "
<script type='text/javascript' src='../include/js/menu.js' type='text/javascript'></script>

<style>



/* All <ul> tags in the menu including the first level */
.TopicMenuList, .TopicMenuList  ul {margin: 0; padding: 0; list-style: none;}

/* Submenus (<ul> tags) are hidden and absolutely positioned downwards from their parent */
.TopicMenuList ul { display: none; position: absolute; top: 7px; margin-top: 28px;  left: $LeftPx; width: 253px;}

/* Second and third etc. level submenus - position across from parent instead */
.TopicMenuList ul ul { top: 0px; margin-top: 0; left: 100px;}

/*
 All menu items (<li> tags). 'float: left' lines them up horizontally, and they are
 positioned relatively to correctly offset submenus. Also, they have overlapping borders.
*/
.TopicMenuList li { float: $OAlign; display: block; position: relative;  border: 0px solid #330; margin-right: 0px;}

/* Items in submenus - override float/border/margin from above, restoring default vertical style */
.TopicMenuList ul li { float: none; margin: 0; margin-bottom: 0px;}
.TopicMenuList ul>li:last-child { margin-bottom: 0px;}

/* Links inside the menu */
.TopicMenuList a { display: block; padding-right: 0px; padding-left: 0px;color: #000000; text-decoration: none;}

/* Lit  items: 'hover' is mouseover, 'highlighted' are parent items to visible menus */

/*
 If you want per-item background images in your menu items, here's how to do it.
 1) Assign a unique ID tag to each link in your menu, like so: <a id='xyz' href='#'>
 2) Copy and paste these next lines for each link you want to have an image:
    .TopicMenuList a#xyz {
      background-image: url(out.gif);
    }
    .TopicMenuList a#xyz:hover, .TopicMenuList a.highlighted#xyz, .TopicMenuList a:focus {
     background-image: url(over.gif);
    }
*/

/* Only style submenu indicators within submenus. */
.TopicMenuList a .subind {
 display: none;
}
.TopicMenuList ul a .subind {
 display: block;
 float: right;
}


/* 'Escaped Comment' hack for horizontal menubar width in IE5/Mac */
.TopicMenuList a {
 float: left;
}
.TopicMenuList ul a {
 float: none;
}
/* \*/
.TopicMenuList a {
 float: none;
}
/* */


/*
 HACKS: IE/Win:
 A small height on <li> and <a> tags and floating prevents gaps in menu.
 * html affects <=IE6 and *:first-child+html affects IE7.
 You may want to move these to browser-specific style sheets.
*/
*:first-child+html .TopicMenuList ul li {
 float: left;
 width: 100%;
}

* html .TopicMenuList ul li {
 float: left;
 height: 1%;
}
* html .TopicMenuList ul a {
 height: 1%;
}
/* End Hacks */z

</style>

";


$TopicCode="

<UL class=TopicMenuList id=TopicMenuListOneRoot>
";


	$TopicCode.="

	<LI><a><img id=khaled src=\"../media/image/admin/$Theme/tools-big.gif\" onmouseover=\"this.src='../media/image/admin/$Theme/tools-big-on.gif';\" onmouseout=\"this.src='../media/image/admin/$Theme/tools-big.gif';\" onclick=\"window.location='home.php?Tab=Tools'\" style='cursor:pointer' ></a>
	<UL onmouseover=\"khaled.src='../media/image/admin/$Theme/tools-big-on.gif';\" onmouseout=\"khaled.src='../media/image/admin/$Theme/tools-big.gif';\">
	<LI><div style='background:#fff; overflow:auto;width:253px;border-left:0px solid #7f9DB9;border-top:0px solid #7f9DB9;border-bottom:0px solid #7f9DB9;border-right:0px solid #7f9DB9;'><table width='100%'  cellPadding=0 cellSpacing=0 background=\"../media/image/admin/$Theme/option-bg.gif\"><td colspan=2 width='100%' background=\"../media/image/admin/$Theme/option-u-bg.gif\" height=2></td>
	";
	

		$TopicCode.="<tr onclick=\"window.location.href='login.php?Login=1'\" style='cursor:pointer'><td align=middle width=30 height=30><img src='../media/image/icon/24x24/home.gif' ></td><td valign=middle class=TdMenu onMouseOver=\"this.className='TdMenuOver'\" OnMouseOut=\"this.className='TdMenu'\" width=220><span class=Tab>&nbsp; Login</td>";

		//$TopicCode.="<tr onclick=\"window.location.href='homepage.php?Reset=1'\" style='cursor:pointer'><td align=middle width=30 height=30><img src='../media/image/icon/24x24/home.gif' ></td><td valign=middle class=TdMenu onMouseOver=\"this.className='TdMenuOver'\" OnMouseOut=\"this.className='TdMenu'\" width=220><span class=Tab>&nbsp; Topic</td>";

		$TopicCode.="<tr><td colspan=2 width='100%' background=\"../media/image/admin/$Theme/option-line-bg.gif\" height=2></td>";

		$TopicCode.="<tr onclick=\"window.location.href='login.php?Logout=1'\" style='cursor:pointer'><td align=middle width=30 height=30><img src='../media/image/icon/24x24/logout.gif' ></td><td valign=middle class=TdMenu onMouseOver=\"this.className='TdMenuOver'\" OnMouseOut=\"this.className='TdMenu'\" width=220><span class=Tab>&nbsp; Logout</td>";


	$TopicCode.="
	<tr><td colspan=2 width='100%' background=\"../media/image/admin/$Theme/option-d-bg.gif\" height=2></td>
	</table></div></LI>

	</UL>
	";

	
	



echo "
<script type='text/javascript'>

var TopicMenuListOne = new FSMenu('TopicMenuListOne', true, 'display', 'block', 'none');


TopicMenuListOne.animations[TopicMenuListOne.animations.length] = FSMenu.animFade;
//TopicMenuListOne.animations[TopicMenuListOne.animations.length] = FSMenu.animSwipeDown;
//TopicMenuListOne.animations[TopicMenuListOne.animations.length] = FSMenu.animClipDown;

var arrow = null;
if (document.createElement && document.documentElement)
{
 arrow = document.createElement('span');
 arrow.appendChild(document.createTextNode('>'));
 // Feel free to replace the above two lines with these for a small arrow image...
 //arrow = document.createElement('img');
 //arrow.src = 'arrow.gif';
 //arrow.style.borderWidth = '0';
 arrow.className = 'subind';
 
 
 
 
 
}
addEvent(window, 'load', new Function('TopicMenuListOne.activateMenu(\"TopicMenuListOneRoot\", arrow)'));



</script>
";

// End Menus











	return $TopicCode;
	}
?>
