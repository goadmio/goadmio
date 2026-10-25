<?php
include "navigator.php";

$TimeStamp=time();

if ($Action=="Cancel")
{
	$Error=SSH ("shutdown -c",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	SSH ("echo '0' > /usr/local/goadmio/reboot.db",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("The system reboot has been cancelled.");
}

if ($_REQUEST['Shutdown']!="")
{

	if ($DemoPassword!="")
	{
	echo Error("This functionality is not available in demo mode.");
	exit;
	}


	$Shutdown=$_REQUEST['Shutdown'];
	$Hours=intval($_REQUEST['Hours']);
	$Minutes=intval($_REQUEST['Minutes']);

	if ($Shutdown=="Now")
	{
	$Error=SSH ("reboot",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Reboot now, Please wait...");
	}
	
	if ($Shutdown=="Delay")
	{
	$M=($Hours*60)+$Minutes;
	$S=$M*60;
	$RebootStamp=time()+$S;
	
	SSH ("echo '$RebootStamp' > /usr/local/goadmio/reboot.db",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

	$Error=SSH ("shutdown -r +$M",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	echo Error("Reboot after $Hours Hour(s) and $Minutes Minute(s)...");		
	}
	
	if ($Shutdown=="ScheduleTime")
	{

		$H=intval($_REQUEST['H']);
		$M=intval($_REQUEST['M']);
		$AMPM=$_REQUEST['AMPM'];

		if ($AMPM=="PM")
		{
			$H=$H+12;
			if ($H==24) {$H="12";}
		}
		
		if ($AMPM=="AM" and $H=="12")
		{
			$H="00";
		}
		
		if (strlen($H)==1)
		{
		$H="0{$H}";
		}
		
		if (strlen($M)==1)
		{
		$M="0{$M}";
		}
		
		$RebootDate=date ("Y-m-d");
		$RebootStamp=strtotime ("$RebootDate $H:$M:00");
		if ($RebootStamp<$TimeStamp)
		{
			$DateTime = new DateTime('tomorrow');
			$RebootDate=$DateTime->format('Y-m-d');

			$RebootStamp=strtotime ("$RebootDate $H:$M:00");
		}
		
		SSH ("echo '$RebootStamp' > /usr/local/goadmio/reboot.db",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);

		$Error=SSH ("shutdown -r $H:$M",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
		echo Error("Reboot at {$_REQUEST['H']}:{$_REQUEST['M']} {$_REQUEST['AMPM']}");		
	}

}


	$RebootStamp=SSH ("cat /usr/local/goadmio/reboot.db",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
	
	$Result = SQL("select * from Config");
	foreach ($Result as $Row)
	{
	$RebootPassword=$Row['RebootPassword'];
	}

	Echo "
	<form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
	<input type='hidden' id=TimeStamp value='$TimeStamp'>
	<input type='hidden' id=RebootStamp value='$RebootStamp'>

	<div class=NavigatorInfo>
	<span class=ColonA>&nbsp;Current Time: ".date ("D j M Y g:i a")."
	</div>
	
	<div class=DivInput>
	Reboot Password
	<br>
	<input type='text' name='RebootPassword' value='$RebootPassword' class=InputText>
	</div>
	
	<div class='DivInput {$Dir}DivInput'>
	<label class=\"radio-enhanced\">
		<input type='radio' name='Shutdown' value='Now' onclick='ShutdownMethod()' checked>
		<span class=\"radio-custom\"></span>
		<span class=\"radio-label-text\">Immediately</span>
	</label>

	<label class=\"radio-enhanced\">
		<input type='radio' name='Shutdown' value='Delay' onclick='ShutdownMethod()'>
		<span class=\"radio-custom\"></span>
		<span class=\"radio-label-text\">Delay</span>
	</label>

	<label class=\"radio-enhanced\">
		<input type='radio' name='Shutdown' value='ScheduleTime' onclick='ShutdownMethod()'>
		<span class=\"radio-custom\"></span>
		<span class=\"radio-label-text\">Schedule Time</span>
	</label>

	</div>

	<div class=DivInput  id=Delay style='display:none'>
	<input type='text' name='Hours' value='' placeholder='Hours' class=InputText style='width:100px' maxlength=2 size=5> &nbsp;&nbsp;&nbsp; <input type='text' name='Minutes' value='' placeholder='Minutes' class=InputText style='width:100px' maxlength=2 size=5>
	</div>

	<div class=DivInput id=ScheduleTime style='display:none'>
	<select name=H class=Select style='width:50px'>
	<option value='12'>12</option>
	<option value='01'>01</option>
	<option value='02'>02</option>
	<option value='03'>03</option>
	<option value='04'>04</option>
	<option value='05'>05</option>
	<option value='06'>06</option>
	<option value='07'>07</option>
	<option value='08'>08</option>
	<option value='09'>09</option>
	<option value='10'>10</option>
	<option value='11'>11</option>
	</select>
	:
	<select name=M class=Select style='width:50px'>
	<option value='00'>00</option>
	<option value='01'>01</option>
	<option value='02'>02</option>
	<option value='03'>03</option>
	<option value='04'>04</option>
	<option value='05'>05</option>
	<option value='06'>06</option>
	<option value='07'>07</option>
	<option value='08'>08</option>
	<option value='09'>09</option>
	<option value='10'>10</option>
	<option value='11'>11</option>
	<option value='12'>12</option>
	<option value='13'>13</option>
	<option value='14'>14</option>
	<option value='15'>15</option>
	<option value='16'>16</option>
	<option value='17'>17</option>
	<option value='18'>18</option>
	<option value='19'>19</option>
	<option value='20'>20</option>
	<option value='21'>21</option>
	<option value='22'>22</option>
	<option value='23'>23</option>
	<option value='24'>24</option>
	<option value='25'>25</option>
	<option value='26'>26</option>
	<option value='27'>27</option>
	<option value='28'>28</option>
	<option value='29'>29</option>
	<option value='30'>30</option>
	<option value='31'>31</option>
	<option value='32'>32</option>
	<option value='33'>33</option>
	<option value='34'>34</option>
	<option value='35'>35</option>
	<option value='36'>36</option>
	<option value='37'>37</option>
	<option value='38'>38</option>
	<option value='39'>39</option>
	<option value='40'>40</option>
	<option value='41'>41</option>
	<option value='42'>42</option>
	<option value='43'>43</option>
	<option value='44'>44</option>
	<option value='45'>45</option>
	<option value='46'>46</option>
	<option value='47'>47</option>
	<option value='48'>48</option>
	<option value='49'>49</option>
	<option value='50'>50</option>
	<option value='51'>51</option>
	<option value='52'>52</option>
	<option value='53'>53</option>
	<option value='54'>54</option>
	<option value='55'>55</option>
	<option value='56'>56</option>
	<option value='57'>57</option>
	<option value='58'>58</option>
	<option value='59'>59</option>
	</select>
	
	<select name=AMPM class=Select style='width:50px'>
	<option value='AM'>AM</option>
	<option value='PM'>PM</option>
	</select>
	
	</div>

	";
	
	if ($RebootStamp>$TimeStamp)
	{
	echo "
	<div class=NavigatorInfo>
	Scheduled Reboot : <span id=Countdown style='font-family:Arial;font-size:20px;padding-left:5px;padding-right:5px'></span> &nbsp;&nbsp;&nbsp; <a href=\"javascript:Load('$CurrentFileName?Action=Cancel')\" class=Action>Cancel</a>
	</div>
	<br>
	";
	}
	
	echo "
	<div id=DivSubmit class=DivSubmit>
	<input type=submit value='Reboot' Class=InputButton>
	</div>

</form>
	
	";

?>