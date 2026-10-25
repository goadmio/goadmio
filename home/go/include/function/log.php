<?php

echo "
<script type='text/javascript' type='text/javascript' src='include/js/editarea/edit_area_full.js'></script>
<script type='text/javascript' type='text/javascript'>
editAreaLoader.init({
	id : \"Code\"		
	,syntax: \"html\"			
	,allow_toggle: false
	,toolbar: \"search, go_to_line, |, undo, redo, |, highlight, reset_highlight\"
	,start_highlight: true});

</script>

		<style>
		h1 {font-size:13px;font-weight:bold;text-decoration:none;margin:0px;color:#333;margin-bottom:10px;border-bottom:5px solid #cccccc;font-family:'Open Sans',Helvetica,Geneva}

		.Outer {display: table;height: 100%;width: 100%;}
		.Middle {display: table-cell;vertical-align: middle;}
		.Inner {margin-left: auto;margin-right: auto; width: 80%;padding:20px;border: 1px solid #CCCCCC;-moz-border-radius: 8px;-webkit-border-radius: 8px;border-radius: 8px;text-align:left;box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-webkit-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-moz-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);font-weight:normal;FONT-SIZE: 17px; COLOR: #000000;font-family:Helvetica Neue,Helvetica,Arial;}
		</style>
		

				<div class='Outer'>
				<div class='Middle'>
				<div class='Inner'>

					Compilation error in Blackhost template code:<br />Template: $DesignNameLog<br />Message: $Error['message']<br />Line: $Error['line']<br />Service: $Service
					<BR>
					
					<textarea rows='17' name='Code' id='Code' cols=50 style='width:100%'>$DesignCodeLog</Textarea>

				</div>
				</div>
				</div>




	

	
	";

	exit;
?>