<?php

echo "
<table  cellSpacing=0 cellPadding=0 width='100%'>
<TD width='100%' align='right' nowrap class=Top>


&nbsp;<span class=Header> Welcome {$_SESSION['SessionUsername']}


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src='theme/{$_SESSION['SessionTheme']}/image/logout.svg' style='height:20px;vertical-align:middle'> <a class=Header href=\"javascript:Load('logout.php')\">Logout</a>

&nbsp;

</td>
</table>
";
?>