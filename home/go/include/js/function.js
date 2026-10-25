var CurrentFileName=''; 
var ControlID=0;
function Load(Url,CurrentControlID=0)
{

	CurrentFileName=Url;
	ControlID=CurrentControlID;

	http=Ajax();http.abort();
	http.open("POST",Url,true);
	http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	http.onreadystatechange = LoadInfo;
	http.send('');
}

function LoadInfo()
{
	if (http.readyState == 1)
	{
	document.getElementById('Load').innerHTML = '<img src=\'image/ajax/1.gif\' border=\'0\'>';
	}

	if (http.readyState == 4)
	{
		var response = http.responseText;
		document.getElementById('Load').innerHTML = response;
	
		if (CurrentFileName.match("mysql.php") || CurrentFileName.match("script.php"))
		{	
			MySQL();
		}

		if (CurrentFileName.match("timezone-fpm.php"))
		{
		CurrentTimezone();
		}
	
		if (CurrentFileName.match("customer.php"))
		{
		
			$("[data-fancybox]").fancybox({
				iframe : {
					css : {
						width : '500px',
						height : '400px'
					}
				}
			});
		
		}
		
		
		if (CurrentFileName.match("site.php") || CurrentFileName.match("expiration.php") || CurrentFileName.match("vps.php"))
		{
			$(function() {
				$('#ExpiresOn').datepicker({dateFormat: 'dd/mm/yy'});
			});
		}
		
		if (CurrentFileName.match("sql.php"))
		{
		
			$(document).ready( function() 
			{
				var WWWPath=document.forms['Form'].WWWPath.value;

				$( '#container' ).html( '<ul class="filetree start"><li class="wait">' + 'Generating Tree...' + '<li></ul>' );	
				getfilelist( $('#container') , WWWPath);
				function getfilelist(cont,root)
				{
				
					$( cont ).addClass( 'wait' );
						
					$.post('tree.php', { dir: root }, function(data) 
					{
				
						$( cont ).find( '.start' ).html('');
						$( cont ).removeClass( 'wait' ).append( data );
						if( 'Sample' == root ) 
							$( cont ).find('UL:hidden').show();
						else 
							$( cont ).find('UL:hidden').slideDown({ duration: 500, easing: null });
						
					});
				}
				
				$( '#container' ).on('click', 'LI A', function() 
				{
					var entry = $(this).parent();
					
					if( entry.hasClass('folder') ) 
					{
						if( entry.hasClass('collapsed') ) 
						{
							entry.find('UL').remove();
							getfilelist( entry, escape( $(this).attr('rel') ));
							entry.removeClass('collapsed').addClass('expanded');
						}
						else 
						{
							entry.find('UL').slideUp({ duration: 500, easing: null });
							entry.removeClass('expanded').addClass('collapsed');
						}
						
					}
					else
					{
						
						if (CurrentFileName.match("sql.php"))
						{
						document.forms['Form'].Database.value=$(this).attr('rel');
						}
						
					}
					
				return false;
				});
				
			});
		
		
		}
		
		if (CurrentFileName.match("directory.php") || CurrentFileName.match("github.php") || CurrentFileName.match("script.php") || CurrentFileName.match("ftp.php"))
		{
			Folder();
		}
		
		if (CurrentFileName.match("spf.php"))
		{
		SPF();
		}

		if (CurrentFileName.match("username.php"))
		{
		GetUsername();
		}

		if (CurrentFileName.match("document-root.php"))
		{
		GetDocumentRoot();
		}
		
		if (CurrentFileName.match("ftp.php"))
		{
		FTPDirectory();
		}

		if (CurrentFileName.match("mail-default.php"))
		{
		DefaultEmail();
		}
		
		if (CurrentFileName.match("RestartHTTPD"))
		{		
		setTimeout(function(){ Load('httpd.php?Action=Check&ControlID='+ControlID,ControlID); }, 10000);
		}
		
		if (CurrentFileName.match("RestartFPM"))
		{		
		setTimeout(function(){ Load('php-fpm.php?Action=Check&ControlID='+ControlID,ControlID); }, 10000);
		}
		
		
		if (CurrentFileName.match("RestoreApacheConfiguration"))
		{
		setTimeout(function(){ Load('apache.php?ControlID='+ControlID,ControlID); }, 10000);
		}

		if (CurrentFileName.match("RestoreNGINXConfiguration"))
		{
		setTimeout(function(){ Load('nginx.php?ControlID='+ControlID,ControlID); }, 10000);
		}

		if (CurrentFileName.match("RestorePHPConfiguration"))
		{
		setTimeout(function(){ Load('php.php?ControlID='+ControlID,ControlID); }, 10000);
		}
		
		if (CurrentFileName.match("Destination=URL"))
		{
		setTimeout(function(){ Load('history.php',0); }, 10000);
		}
		
		if (CurrentFileName.match("update.php"))
		{		
		location.reload();
		}

		if (CurrentFileName.match("logout.php"))
		{		
		window.location="index.php";
		}

		if (CurrentFileName.match("schedule.php") || CurrentFileName.match("snapshot-config.php"))
		{		
		Rclone();
		}
		
		if (CurrentFileName.match("reboot.php"))
		{	
			
			var TimeStamp=document.getElementById('TimeStamp').value;
			

			var x = setInterval(function() 
			{
				TimeStamp++;
			
				var RebootStamp=document.getElementById('RebootStamp').value;
			
				var distance = RebootStamp - TimeStamp;

				// Time calculations for days, hours, minutes and seconds
				var hours = Math.floor(distance / 3600);
				var minutes = Math.floor((distance / 60)%60);
				var seconds = Math.floor(distance%60);

				document.getElementById('Countdown').innerHTML = hours + ':' + minutes + ':' + seconds;

			}, 1000);

		}
		
		// Scroll To ID
		var ScrollToMatch = CurrentFileName.match(/ScrollTo=([^&]+)/);
		if (ScrollToMatch) {
			var TargetID = ScrollToMatch[1];
			setTimeout(function() {
				var ScrollTargetElement = document.getElementById(TargetID);
				if (ScrollTargetElement) {
					ScrollTargetElement.scrollIntoView({ 
						behavior: 'smooth', 
						block: 'nearest',
						inline: 'start'
					});
				}
			}, 100);
		}

		CheckProgress();
	
	}
}

function HandelPost()
{

	if (http.readyState == 4)
	{
		var response = http.responseText;
		document.getElementById('Load').innerHTML = response;
	}
}


function SearchPost(FileName)
{
var SearchFor = document.getElementById('SearchFor').value;

Load (FileName+'?SearchFor='+SearchFor+'&ControlID='+ControlID);

return false;
}

function Radio (Name)
{
	var radios = document.getElementsByName(Name);

	for (var i = 0, length = radios.length; i < length; i++)
	{
		if (radios[i].checked)
		{
		return (radios[i].value);

		break;
		}
	}
}

function IsEmpty(str)
{
	var i;
	var len;
	if( str == null )
	return true;

	len = str.length;

	for( var i=0; i<len; i++ )
	{
	if( str.charAt(i) != ' ')
	return false;
	}
	
	return true;
}

var SubmitFileName='';
function Submit(File) 
{
	SubmitFileName=File;

	if (document.forms['Form'].VerifyPassword)
	{
		if (document.forms['Form'].Password.value!=document.forms['Form'].VerifyPassword.value)
		{
		alert('Your password entries did not match');
		document.forms['Form'].Password.value='';
		document.forms['Form'].VerifyPassword.value='';
		document.forms['Form'].Password.focus();
		return false;
		}
	}

    var Data = new FormData(document.forms['Form']);
	
	document.getElementById('DivSubmit').innerHTML = '<img class=\'preloader-image\' src=\'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB2ZXJzaW9uPSIxLjEiIHN0eWxlPSItLWFuaW1hdGlvbi1zdGF0ZTpydW5uaW5nOyI+CiAgICAgIDxzdHlsZT4KICAgICAgICA6cm9vdCB7CiAgICAgICAgICAtLWFuaW1hdGlvbi1zdGF0ZTogcGF1c2VkOwogICAgICAgIH0KCiAgICAgICAgLyogdXNlciBwaWNrZWQgYSB0aGVtZSB3aGVyZSB0aGUgInJlZ3VsYXIiIHNjaGVtZSBpcyBkYXJrICovCiAgICAgICAgLyogdXNlciBwaWNrZWQgYSB0aGVtZSBhIGxpZ2h0IHNjaGVtZSBhbmQgYWxzbyBlbmFibGVkIGEgZGFyayBzY2hlbWUgKi8KCiAgICAgICAgLyogZGVhbCB3aXRoIGxpZ2h0IHNjaGVtZSBmaXJzdCAqLwogICAgICAgIEBtZWRpYSAocHJlZmVycy1jb2xvci1zY2hlbWU6IGxpZ2h0KSB7CiAgICAgICAgICA6cm9vdCB7CiAgICAgICAgICAgIC0tcHJpbWFyeTogIzIyMjIyMjsKICAgICAgICAgICAgLS1zZWNvbmRhcnk6ICNmZmZmZmY7CiAgICAgICAgICAgIC0tdGVydGlhcnk6ICMyNDY4YzE7CiAgICAgICAgICAgIC0tcXVhdGVybmFyeTogI2U0NTczNTsKICAgICAgICAgICAgLS1oaWdobGlnaHQ6ICNmZmZmNGQ7CiAgICAgICAgICAgIC0tc3VjY2VzczogIzAwOTkwMDsKICAgICAgICAgIH0KICAgICAgICB9CgogICAgICAgIC8qIHRoZW4gZGVhbCB3aXRoIGRhcmsgc2NoZW1lICovCiAgICAgICAgQG1lZGlhIChwcmVmZXJzLWNvbG9yLXNjaGVtZTogZGFyaykgewogICAgICAgICAgOnJvb3QgewogICAgICAgICAgICAtLXByaW1hcnk6ICMyMjIyMjI7CiAgICAgICAgICAgIC0tc2Vjb25kYXJ5OiAjZmZmZmZmOwogICAgICAgICAgICAtLXRlcnRpYXJ5OiAjMjQ2OGMxOwogICAgICAgICAgICAtLXF1YXRlcm5hcnk6ICNlNDU3MzU7CiAgICAgICAgICAgIC0taGlnaGxpZ2h0OiAjZmZmZjRkOwogICAgICAgICAgICAtLXN1Y2Nlc3M6ICMwMDk5MDA7CiAgICAgICAgICB9CiAgICAgICAgfQoKICAgICAgICAvKiB0aGVzZSBzdHlsZXMgbmVlZCB0byBsaXZlIGhlcmUgYmVjYXVzZSB0aGUgU1ZHIGhhcyBhIGRpZmZlcmVudCBzY29wZSAqLwogICAgICAgIC5kb3RzIHsKICAgICAgICAgIGFuaW1hdGlvbi1uYW1lOiBsb2FkZXI7CiAgICAgICAgICBhbmltYXRpb24tdGltaW5nLWZ1bmN0aW9uOiBlYXNlLWluLW91dDsKICAgICAgICAgIGFuaW1hdGlvbi1kdXJhdGlvbjogM3M7CiAgICAgICAgICBhbmltYXRpb24taXRlcmF0aW9uLWNvdW50OiBpbmZpbml0ZTsKICAgICAgICAgIGFuaW1hdGlvbi1wbGF5LXN0YXRlOiB2YXIoLS1hbmltYXRpb24tc3RhdGUpOwogICAgICAgICAgc3Ryb2tlOiAjZmZmOwogICAgICAgICAgc3Ryb2tlLXdpZHRoOiAwLjVweDsKICAgICAgICAgIHRyYW5zZm9ybS1vcmlnaW46IGNlbnRlcjsKICAgICAgICAgIG9wYWNpdHk6IDA7CiAgICAgICAgICByOiBtYXgoMXZ3LCAxMXB4KTsKICAgICAgICAgIGN5OiA1MCU7CiAgICAgICAgICBmaWx0ZXI6IHNhdHVyYXRlKDIpIG9wYWNpdHkoMC44NSk7CiAgICAgICAgfQoKICAgICAgICAuZG90czpmaXJzdC1jaGlsZCB7CiAgICAgICAgICBmaWxsOiB2YXIoLS1xdWF0ZXJuYXJ5KTsKICAgICAgICB9CgogICAgICAgIC5kb3RzOm50aC1jaGlsZCgyKSB7CiAgICAgICAgICBmaWxsOiB2YXIoLS1xdWF0ZXJuYXJ5KTsKICAgICAgICAgIGFuaW1hdGlvbi1kZWxheTogMC4xNXM7CiAgICAgICAgfQoKICAgICAgICAuZG90czpudGgtY2hpbGQoMykgewogICAgICAgICAgZmlsbDogdmFyKC0taGlnaGxpZ2h0KTsKICAgICAgICAgIGFuaW1hdGlvbi1kZWxheTogMC4zczsKICAgICAgICB9CgogICAgICAgIC5kb3RzOm50aC1jaGlsZCg0KSB7CiAgICAgICAgICBmaWxsOiB2YXIoLS10ZXJ0aWFyeSk7CiAgICAgICAgICBhbmltYXRpb24tZGVsYXk6IDAuNDVzOwogICAgICAgIH0KCiAgICAgICAgLmRvdHM6bnRoLWNoaWxkKDUpIHsKICAgICAgICAgIGZpbGw6IHZhcigtLXRlcnRpYXJ5KTsKICAgICAgICAgIGFuaW1hdGlvbi1kZWxheTogMC42czsKICAgICAgICB9CgogICAgICAgIEBrZXlmcmFtZXMgbG9hZGVyIHsKICAgICAgICAgIDAlIHsKICAgICAgICAgICAgb3BhY2l0eTogMDsKICAgICAgICAgICAgdHJhbnNmb3JtOiBzY2FsZSgxKTsKICAgICAgICAgIH0KICAgICAgICAgIDQ1JSB7CiAgICAgICAgICAgIG9wYWNpdHk6IDE7CiAgICAgICAgICAgIHRyYW5zZm9ybTogc2NhbGUoMC43KTsKICAgICAgICAgIH0KICAgICAgICAgIDY1JSB7CiAgICAgICAgICAgIG9wYWNpdHk6IDE7CiAgICAgICAgICAgIHRyYW5zZm9ybTogc2NhbGUoMC43KTsKICAgICAgICAgIH0KICAgICAgICAgIDEwMCUgewogICAgICAgICAgICBvcGFjaXR5OiAwOwogICAgICAgICAgICB0cmFuc2Zvcm06IHNjYWxlKDEpOwogICAgICAgICAgfQogICAgICAgIH0KICAgICAgPC9zdHlsZT4KCiAgICAgIDxnIGNsYXNzPSJjb250YWluZXIiPgogICAgICAgIDxjaXJjbGUgY2xhc3M9ImRvdHMiIGN4PSIzMHZ3Ii8+CiAgICAgICAgPGNpcmNsZSBjbGFzcz0iZG90cyIgY3g9IjQwdnciLz4KICAgICAgICA8Y2lyY2xlIGNsYXNzPSJkb3RzIiBjeD0iNTB2dyIvPgogICAgICAgIDxjaXJjbGUgY2xhc3M9ImRvdHMiIGN4PSI2MHZ3Ii8+CiAgICAgICAgPGNpcmNsZSBjbGFzcz0iZG90cyIgY3g9IjcwdnciLz4KICAgICAgPC9nPgogICAgPC9zdmc+\'>';
	
	http=Ajax();http.abort();
    http.open("POST",File, true);
	http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    http.onreadystatechange = SubmitLoad;
    http.send(new URLSearchParams(Data).toString());
	
	return false;
}

function SubmitLoad() 
{

	if (http.readyState == 1)
	{

	}

    if (http.readyState == 4) 
	{
		var response = http.responseText;
		document.getElementById('Load').innerHTML = response;

		// Scroll to top
        setTimeout(() => {
            var rightArea = document.querySelector('.right-area');
            if (rightArea) {
                rightArea.scrollTop = 0;
            }
            document.getElementById('Load').scrollTop = 0;
        }, 100);
        
		if (SubmitFileName.match("go.php"))
		{
			setTimeout(function(){ Load('home.php'); }, 2000);
		}
		
		setTimeout(CheckProgress, 2000);

    }
}


var ApacheID='';
function Apache(Command,Value,ApacheInpuID)
{
	ApacheID=ApacheInpuID;

	http=Ajax();http.abort();
	http.open("POST", "ajax/apache.php?Lng=$Lng&Command="+Command+"&Value="+Value,true);
	http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	http.onreadystatechange = ApacheLoad;
	http.send('');
}

function ApacheLoad()
{

	if (http.readyState == 1)
	{

	}

	if (http.readyState == 4)
	{
		var response = http.responseText;

		if (response.match('Service Unavailable'))
		{
		alert ('Service Unavailable');
		}
		else if (response.match('!'))
		{
		alert (response);
		}
		else
		{
		document.getElementById(ApacheID).value=response;
		}
	}
}

var NGINXID='';
function NGINX(Command,Value,NGINXInpuID)
{
	NGINXID=NGINXInpuID;

	http=Ajax();http.abort();
	http.open("POST", "ajax/nginx.php?Lng=$Lng&Command="+Command+"&Value="+Value,true);
	http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	http.onreadystatechange = NGINXLoad;
	http.send('');
}

function NGINXLoad()
{

	if (http.readyState == 1)
	{

	}

	if (http.readyState == 4)
	{
		var response = http.responseText;

		if (response.match('Service Unavailable'))
		{
		alert ('Service Unavailable');
		}
		else if (response.match('!'))
		{
		alert (response);
		}
		else
		{
		document.getElementById(NGINXID).value=response;
		}
	}
}

var PHPID='';
function PHP(Command,Value,PHPInputID)
{
PHPID=PHPInputID;

http=Ajax();http.abort();
http.open("POST", "ajax/php.php?Lng=$Lng&Command="+Command+"&Value="+Value,true);
http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
http.onreadystatechange = PHPLoad;
http.send('');
}

function PHPLoad()
{

	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
		var response = http.responseText;
	
		if (response.match('!'))
		{
		alert (response);
		}
		else
		{
		document.getElementById(PHPID).value=response;
		}
	}
}

var ReturnID='';
function Setting(Service,SiteID,Value,InputID)
{
ReturnID=InputID;

http=Ajax();http.abort();
http.open("POST", "ajax/setting.php?Lng=$Lng&Service="+Service+"&SiteID="+SiteID+"&Value="+Value+"&ID="+InputID,true);
http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
http.onreadystatechange = SettingLoad;
http.send('');
}

function SettingLoad()
{

	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
		var response = http.responseText;
	
		if (response.match('!'))
		{
		alert (response);
		}
		else
		{
		document.getElementById(ReturnID).value=response;
		}
	}
}

// Used to Edit Config Table Values (quota.php & postfix.php)
var ReturnID='';
function Config(ID,Value)
{
ReturnID=ID;

http=Ajax();http.abort();
http.open("POST", "ajax/config.php?Lng=$Lng&ID="+ID+"&Value="+Value,true);
http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
http.onreadystatechange = ConfigLoad;
http.send('');
}

function ConfigLoad()
{
	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
		var response = http.responseText;
	
		if (response.match('!'))
		{
		alert (response);
		}
		else
		{
		document.getElementById(ReturnID).value=response;
		}
	}
}

var ReturnModifyID='';
function Modify(SiteID,Value,InputID)
{
ReturnModifyID=InputID;

http=Ajax();http.abort();
http.open("POST", "ajax/modify.php?Lng=$Lng&SiteID="+SiteID+"&Value="+Value+"&ID="+InputID,true);
http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
http.onreadystatechange = ModifyLoad;
http.send('');
}

function ModifyLoad()
{

	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
		var response = http.responseText;
	
		if (response.match('!'))
		{
		alert (response);
		}
		else
		{
		document.getElementById(ReturnModifyID).value=response;
		}
	}
}

var IMAPID='';
function IMAP(IMAPInputID,Value)
{
IMAPID=IMAPInputID;

http=Ajax();http.abort();
http.open("POST", "ajax/imap.php?Lng=$Lng&IMAPID="+IMAPID+"&Value="+Value,true);
http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
http.onreadystatechange = IMAPLoad;
http.send('');
}

function IMAPLoad()
{

	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
		var response = http.responseText;

	
		if (response.match('!'))
		{
		alert (response);
		}
		else
		{
			
			document.getElementById(IMAPID).value=response;
			
			
		}
	}
}

var SMTPID='';
function SMTP(SMTPInputID,Value)
{
SMTPID=SMTPInputID;

http=Ajax();http.abort();
http.open("POST", "ajax/smtp.php?Lng=$Lng&SMTPID="+SMTPID+"&Value="+Value,true);
http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
http.onreadystatechange = SMTPLoad;
http.send('');
}

function SMTPLoad()
{

	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
		var response = http.responseText;

	
		if (response.match('!'))
		{
		alert (response);
		}
		else
		{
			
			document.getElementById(SMTPID).value=response;
			
			
		}
	}
}

function CurrentVersion()
{	
http=Ajax();http.abort();
http.open('POST', 'ajax/multiphp.php?Lng=en&Domain='+document.getElementById('Domain').value,true);
http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
http.onreadystatechange = HandleCurrentVersion;
http.send('');
}

function HandleCurrentVersion()
{

	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
	var response = http.responseText;
	document.getElementById('DivPHPVersion').innerHTML = 'PHP Version<br>'+response;
	}
}

function CurrentTimezone()
{	
http=Ajax();http.abort();
http.open('POST', 'ajax/timezone-fpm.php?Lng=en&Domain='+document.getElementById('Domain').value,true);
http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
http.onreadystatechange = HandleCurrentTimezone;
http.send('');
}

function HandleCurrentTimezone()
{
	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
	var response = http.responseText;
	
	var ResponseArray = response.split('|');
			
	document.getElementById('Timezone').value = ResponseArray[0];
	document.getElementById('DivCurrentTime').innerHTML = ResponseArray[1];
	}
}

function DefaultEmail()
{
http=Ajax();http.abort();
http.open('POST', 'ajax/mail-default.php?Lng=en&Domain='+document.getElementById('Domain').value,true);
http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
http.onreadystatechange = HandleDefaultEmail;
http.send('');
}

function HandleDefaultEmail()
{
	if (http.readyState == 1)
	{
		
	}

	if (http.readyState == 4)
	{
	var response = http.responseText;
	document.getElementById('Email').value = response;
	}
}


function SPF()
{
http=Ajax();http.abort();
http.open('POST', 'ajax/spf.php?Lng=en&Domain='+document.getElementById('Domain').value,true);
http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
http.onreadystatechange = HandleSPF;
http.send('');
}

function HandleSPF()
{

	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
	var response = http.responseText;
	document.getElementById('DivSPF').innerHTML = response;
	}
}
	
function GetDocumentRoot()
{
http=Ajax();http.abort();
http.open('POST', 'ajax/document-root.php?Lng=en&Domain='+document.getElementById('Domain').value,true);
http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
http.onreadystatechange = HandleGetDocumentRoot;
http.send('');
}

function HandleGetDocumentRoot()
{

	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
	var response = http.responseText;
	document.getElementById('DocumentRoot').value = response;
	}
}
			
function GetUsername()
{
http=Ajax();http.abort();
http.open('POST', 'ajax/username.php?Lng=en&Domain='+document.getElementById('Domain').value,true);
http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
http.onreadystatechange = HandleGetUsername;
http.send('');
}

function CheckAll()
{
	var OneRow=1

	N=CheckForm.elements['CheckList[]'].length;

	if (document.forms['CheckForm'].AllCheckList.checked==true)
	{
		for ( var i=0; i < N ; i++ )
		{
			CheckForm.elements['CheckList[]'][i].checked=true;
			eval("R"+i+".style.background='#FF0000';");   	
		
		var OneRow=0;
		}

		if (OneRow==1)
		{
			CheckForm.elements['CheckList[]'].checked=true;
			R0.style.background="#FF0000";   	
		}

	}
	else
	{
	var OneRow=1

		for ( var i=0; i < N ; i++ )
		{
			CheckForm.elements['CheckList[]'][i].checked=false;

				if (i/2==Math.ceil(i/2))
				{
				eval("R"+i+".style.background='#FFFFFF';");
				}
				else
				{
				eval("R"+i+".style.background='#CCCCCC';");
				}

		var OneRow=0;
		}

		if (OneRow==1)
		{
		CheckForm.elements['CheckList[]'].checked=false;
		R0.style.background="#FFFFFF";   	
		}
	}
} 

function ColorRow(RowID,i,DefaultColor)
{
	N=CheckForm.elements['CheckList[]'].length;
	
	if (N>=2)
	{

		if (CheckForm.elements['CheckList[]'][i].checked==true)
		{
		RowID.style.background="#FF0000";   	
		}	
		else
		{
		RowID.style.background=DefaultColor;   	
		}	
	}
	else
	{
					if (CheckForm.elements['CheckList[]'].checked==true)
		{
		RowID.style.background="#FF0000";   	
		}
		else
		{
		RowID.style.background=DefaultColor;   	
		}	
	}

}

var N=0;
function ClamAVAntivirus()
{

	N=0;

	X=Scan('1');
	return false;

}

function Scan(N)
{
http=Ajax();http.abort();
http.open('POST', 'ajax/antivirus.php?Lng=en&Domain='+document.getElementById('Domain').value+'&N='+N,true);
http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
http.onreadystatechange = HandleScan;
http.send('');
}

function HandleScan()
{

	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
	N++;
	
		var response = http.responseText;
	
		if (response=='')
		{
		
			
			Dot=N%6;
			DotString='';
			for (D=0;D<=Dot;D++)
			{
			DotString=DotString+'.';
			}
			
			document.getElementById('DivScan').innerHTML = '<b>Scanning'+DotString+'</b>';
		
		
			setTimeout(function(){ Scan('2'); }, 5000);

		}
		else
		{
		document.getElementById('DivScan').innerHTML = response;
		}
	
	
	}
}

function SwitchReject()
{
	if (document.getElementById('Reject').checked==true)
	{
	document.getElementById('ForwardTo').style.display='none';
	document.getElementById('KeepCopy').style.display='none';
	document.getElementById('RejectMessage').style.display='';
	}
	else
	{
	document.getElementById('ForwardTo').style.display='';
	document.getElementById('KeepCopy').style.display='';
	document.getElementById('RejectMessage').style.display='none';
	}
}

function ShutdownMethod()
{

	if (document.forms['Form'].Shutdown[0].checked==true)
	{
	document.getElementById('TrDelay1').style.display='none';
	document.getElementById('TrScheduleTime1').style.display='none';
	}

	if (document.forms['Form'].Shutdown[1].checked==true)
	{
	document.getElementById('Delay').style.display='';
	document.getElementById('ScheduleTime').style.display='none';
	}

	if (document.forms['Form'].Shutdown[2].checked==true)
	{
	document.getElementById('Delay').style.display='none';
	document.getElementById('ScheduleTime').style.display='';
	}

}

function PackageInfo()
{	
http=Ajax();http.abort();
http.open('POST', 'ajax/package.php?Lng=en&PackageID='+document.getElementById('PackageID').value,true);
http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
http.onreadystatechange = HandlePackageInfo;
http.send('');
}

function HandlePackageInfo()
{
	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
	var response = http.responseText;

	var PackageArray = response.split("|");

	document.forms['Form'].DiskSpace.value=PackageArray[0];
	document.forms['Form'].Bandwidth.value=PackageArray[1];
	document.forms['Form'].Inode.value=PackageArray[2];
	document.forms['Form'].FTPNo.value=PackageArray[3];
	document.forms['Form'].EmailNo.value=PackageArray[4];
	document.forms['Form'].DatabaseNo.value=PackageArray[5];
	document.forms['Form'].SubDomainNo.value=PackageArray[6];
	document.forms['Form'].AliasNo.value=PackageArray[7];
	document.forms['Form'].AddonNo.value=PackageArray[8];

	}
}




function ModifyPackage()
{	
http=Ajax();http.abort();
http.open('POST', 'ajax/modify-package.php?Lng=en&PackageID='+document.getElementById('PackageID').value+'&Domain='+document.getElementById('Domain').value,true);
http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
http.onreadystatechange = HandleModifyPackage;
http.send('');
}

function HandleModifyPackage()
{
	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
	var Domain = http.responseText;
	Load('modify.php?Edit=1&Domain='+Domain);
	}

}

function SetPlan()
{
	var PlanString = document.forms['Form'].Plan.value;
	var PlanArray = PlanString.split("|");
	
	document.forms['Form'].PlanName.value=PlanArray[1];
	document.forms['Form'].DiskType.value=PlanArray[2];
	document.forms['Form'].DiskSpace.value=PlanArray[3];
	document.forms['Form'].Cores.value=PlanArray[4];
	document.forms['Form'].Memory.value=PlanArray[5];
	document.forms['Form'].Price.value=PlanArray[6];
	
}


function BackupDestination()
{

	if (document.forms['Form'].Destination.value=="HOMEDIR" || document.forms['Form'].Destination.value=="URL")
	{
	document.getElementById('RemoteServer').style.display='none';
	document.getElementById('RemoteUser').style.display='none';
	document.getElementById('RemotePassword').style.display='none';
	document.getElementById('RemoteDir').style.display='none';
	}
	else
	{
	document.getElementById('RemoteServer').style.display='';
	document.getElementById('RemoteUser').style.display='';
	document.getElementById('RemotePassword').style.display='';
	document.getElementById('RemoteDir').style.display='';
	}

}

function Switch()
{
	var Username = document.getElementById('SwitchUsername').value;
	
	http=Ajax();http.abort();
	http.open("POST", "ajax/switch.php",true);
	http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	http.onreadystatechange = HandelSwitch;
	http.send('Username='+Username);
		
	return false;

}

function HandelSwitch()
{

	if (http.readyState == 4)
	{
		var response = http.responseText;
		if (response==1)
		{
		location.reload();
		}
	}
}


function AdminEmail()
{
	var Domain = document.forms['Form'].Domain.value;
	
	http=Ajax();http.abort();
	http.open("POST", "ajax/admin-email.php",true);
	http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	http.onreadystatechange = HandelAdminEmail;
	http.send('Domain='+Domain);
		
	return false;

}

function HandelAdminEmail()
{

	if (http.readyState == 4)
	{
		var response = http.responseText;
		document.getElementById('Email').value=response;
		
	}
}

function FTPDirectory()
{
Domain=document.getElementById('Domain').value;

http=Ajax();http.abort();
http.open("POST", "ajax/ftp.php",true);
http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
http.onreadystatechange = HandelFTPDirectory;
http.send('Domain='+Domain);
}

function HandelFTPDirectory()
{

	if (http.readyState == 4)
	{
		var response = http.responseText;
		document.getElementById('Directory').value=response;
	}
}


function Update()
{
	document.getElementById('Update').innerHTML='Please wait...';
	Load('update.php')
}

function GenerateUsername()
{

	var Username = document.forms['Form'].Domain.value;

	if (Username.length <= 32) 
	{
	document.forms['Form'].Username.value=Username; 
	return;
	}
	else
	{
	var UsernameArray = Username.split(".");
	}
	
	if (UsernameArray.length==2)
	{
	Username=UsernameArray[0];
	}
	
	if (UsernameArray.length==3)
	{
	Username=UsernameArray[1];
	}
	
	if (Username.length<=32)
	{
	
		if (Username.match("-"))
		{
			var UsernameArray = Username.split("-");
			
			if (UsernameArray[0].length<=UsernameArray[1].length)
			{
			Username=UsernameArray[0];
			}
			else
			{
			Username=UsernameArray[1];
			}
			
			document.forms['Form'].Username.value=Username;
			return;		
		}
		else
		{
		document.forms['Form'].Username.value=Username;
		return;
		}
		
	}
	else
	{

		if (Username.match("-"))
		{
			var UsernameArray = Username.split("-");
			
			if (UsernameArray[0].length<=UsernameArray[1].length)
			{
			Username=UsernameArray[0];
			}
			else
			{
			Username=UsernameArray[1];
			}
			
			if (Username.length<=32)
			{
			document.forms['Form'].Username.value=Username;
			return;			
			}
			else
			{

				Username=Username.substr(0, 32);
				document.forms['Form'].Username.value=Username;
				return;	

			}
		
		}
		else
		{

			Username=Username.substr(0, 32);
			document.forms['Form'].Username.value=Username;
			return;		

		}
	
	}
}







function Container()
{
http=Ajax();http.abort();
http.open('POST', 'ajax/container.php?Lng=en&ServerIP='+document.getElementById('ServerIP').value,true);
http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
http.onreadystatechange = HandleContainer;
http.send('');
}

function HandleContainer()
{

	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
	var response = http.responseText;
	document.getElementById('ID').value = response;
	
	GetPlan();
	}
}







function GetPlan()
{
http=Ajax();http.abort();
http.open('POST', 'ajax/plan.php?Lng=en&ServerIP='+document.getElementById('ServerIP').value,true);
http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
http.onreadystatechange = HandleGetPlan;
http.send('');
}

function HandleGetPlan()
{

	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
	var response = http.responseText;
	document.getElementById('DivPlan').innerHTML = response;
	}
}

let ProgressInterval=null;
function CheckProgress()
{

	if (document.getElementById('ProgressBar'))
	{
	ProgressInterval=setInterval(Progress, 3000);
	Progress();
	}

}

function Progress()
{

	if (document.forms['ProgressForm'].ProgressFile)
	{
		ProgressFile=document.forms['ProgressForm'].ProgressFile.value;
		
		http=Ajax();http.abort();
		http.open("POST", "ajax/progress.php?ProgressFile="+ProgressFile,true);
		http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		http.onreadystatechange = HandelProgress;
		http.send('');
	}
}

function HandelProgress()
{
	if (http.readyState == 1)
	{
	
	}

	if (http.readyState == 4)
	{
		var response = http.responseText;
		
		if (response.match("|")) 
		{
			var Array = response.split("|");

			if (Array[0]!=0)
			{
			document.getElementById('ProgressBar').style.width=Array[0]+'%';
			document.getElementById('ProgressMessage').innerHTML= Array[1];
			document.getElementById('Complete').innerHTML= Array[0]+'% Complete';
			}
			
			if (Array[0]=="100")
			{
				clearInterval(ProgressInterval);
			}
			
		}
		
	}
	
}

const Copy = str => {
  const el = document.createElement('textarea');
  el.value = str;
  document.body.appendChild(el);
  el.select();
  document.execCommand('copy');
  document.body.removeChild(el);
};







// Toggle function for categories
function toggleCategoryIcon(categoryId) {
    var contentDiv = document.getElementById(categoryId);
    var arrowSpan = document.getElementById('arrow_' + categoryId);
    
    if (!contentDiv || !arrowSpan) return;
    
    if (contentDiv.style.display === 'none' || contentDiv.style.display === '') {
        // Open the category
        contentDiv.style.display = 'block';
        arrowSpan.innerHTML = '▼';
        arrowSpan.style.transform = 'rotate(0deg)';
        saveCategoryState(categoryId, true);
    } else {
        // Close the category
        contentDiv.style.display = 'none';
        arrowSpan.innerHTML = '▶';
        arrowSpan.style.transform = 'rotate(0deg)';
        saveCategoryState(categoryId, false);
    }
}

// Store state in localStorage to remember open/closed categories
function saveCategoryState(categoryId, isOpen) {
    var states = JSON.parse(localStorage.getItem('categoryStates') || '{}');
    states[categoryId] = isOpen;
    localStorage.setItem('categoryStates', JSON.stringify(states));
}

// Load saved states on page load - ALL OPEN BY DEFAULT
document.addEventListener('DOMContentLoaded', function() {
    var savedStates = JSON.parse(localStorage.getItem('categoryStates') || '{}');
    
    // Get all category content divs
    var categories = document.querySelectorAll('.CategoryContent');
    
    categories.forEach(function(category) {
        var categoryId = category.id;
        var arrowSpan = document.getElementById('arrow_' + categoryId);
        
        if (savedStates.hasOwnProperty(categoryId)) {
            // Use saved state if it exists
            if (savedStates[categoryId]) {
                category.style.display = 'block';
                if (arrowSpan) arrowSpan.innerHTML = '▼';
            } else {
                category.style.display = 'none';
                if (arrowSpan) arrowSpan.innerHTML = '▶';
            }
        } else {
            // DEFAULT: ALL CATEGORIES OPEN
            category.style.display = 'block';
            if (arrowSpan) arrowSpan.innerHTML = '▼';
        }
    });
});













// Close all dropdowns when clicking outside
document.addEventListener('click', function(event) {
  // Check if click is outside any dropdown button and dropdown content
  const isButton = event.target.classList && event.target.classList.contains('DropButton');
  const isInsideDropdown = event.target.closest('.DropdownButtonContent');
  
  if (!isButton && !isInsideDropdown) {
    // Close all open dropdowns
    document.querySelectorAll('.DropdownButtonContent.show').forEach(function(dropdown) {
      dropdown.classList.remove('show');
    });
  }
});






// Close all dropdowns when clicking outside
document.addEventListener('click', function(event) {
  // Check if click is outside any dropdown button and dropdown content
  const isButton = event.target.classList && event.target.classList.contains('DropButton');
  const isInsideDropdown = event.target.closest('.DropdownButtonContent');
  
  if (!isButton && !isInsideDropdown) {
    // Close all open dropdowns
    document.querySelectorAll('.DropdownButtonContent.show').forEach(function(dropdown) {
      dropdown.classList.remove('show');
    });
  }
});

// Dropdown toggle function - FIXED: added 'event' parameter
function DropdownButton(buttonId, event) {
  // Get the dropdown element
  const dropdown = document.getElementById(buttonId);
  
  if (!dropdown) return;
  
  // Get the button that was clicked (the event target)
  let button = event.target;
  
  // If event.target is not the button itself (could be span or inner element), find the parent button
  if (!button.classList || !button.classList.contains('DropButton')) {
    button = button.closest('.DropButton');
  }
  
  if (!button) return;
  
  // Close all other dropdowns first
  document.querySelectorAll('.DropdownButtonContent.show').forEach(function(openDropdown) {
    if (openDropdown.id !== buttonId) {
      openDropdown.classList.remove('show');
    }
  });
  
  // Toggle the current dropdown
  dropdown.classList.toggle('show');
  
  // Position the dropdown if it's being shown
  if (dropdown.classList.contains('show')) {
    // Get button position
    const rect = button.getBoundingClientRect();
    
    // Set dropdown position
    dropdown.style.position = 'absolute';
    dropdown.style.top = (rect.bottom + window.scrollY) + 'px';
    dropdown.style.left = (rect.left + window.scrollX) + 'px';
    
    // Check if dropdown goes off-screen to the right
    const dropdownRect = dropdown.getBoundingClientRect();
    if (dropdownRect.right > window.innerWidth) {
      dropdown.style.left = (rect.right - dropdownRect.width + window.scrollX) + 'px';
    }
    
    // Check if dropdown goes off-screen to the left
    if (dropdownRect.left < 0) {
      dropdown.style.left = (rect.left + window.scrollX) + 'px';
    }
    
    // Check if dropdown goes off-screen at the bottom
    if (dropdownRect.bottom > window.innerHeight) {
      dropdown.style.top = (rect.top - dropdownRect.height + window.scrollY) + 'px';
    }
  }
}

// Close dropdown when pressing Escape key
document.addEventListener('keydown', function(event) {
  if (event.key === 'Escape') {
    document.querySelectorAll('.DropdownButtonContent.show').forEach(function(dropdown) {
      dropdown.classList.remove('show');
    });
  }
});































function Folder()
{
    var WWWPath = document.forms['Form'].WWWPath.value;
    document.forms['Form'].Directory.value=WWWPath;
	
	
    http = Ajax();
    http.abort();
    http.open('POST', 'ajax/folder.php?Lng=en&WWWPath=' + encodeURIComponent(WWWPath), true);
    http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    http.onreadystatechange = HandleFolder;
    http.send('');
}


let folderData = [];
let originalFolderData = [];
let currentSelectedPath = '';
let currentWWWPath = '';

// SVG Icons with #FF6A00 color by default
const folderIcons = {
    folder: `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M4 20C4 20.5523 4.44772 21 5 21H19C19.5523 21 20 20.5523 20 20V8C20 7.44772 19.5523 7 19 7H12L10 5H5C4.44772 5 4 5.44772 4 6V20Z" fill="#FF6A00" stroke="#FF6A00" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>`,
    chevron: `<svg width="12" height="12" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M9 18L15 12L9 6" stroke="#FF6A00" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>`
};

// Handle folder response
function HandleFolder() {
    if (http.readyState == 4) {
        var response = http.responseText;
        
        try {
            var data = JSON.parse(response);
            
            if (data.success) {
                originalFolderData = data.tree;
                folderData = JSON.parse(JSON.stringify(data.tree));
                currentWWWPath = data.wwwPath;
                renderFolderTree(folderData);
            } else {
                showFolderError(data.error);
            }
        } catch(e) {
            showFolderError('Error parsing response: ' + e.message);
        }
    }
}

// Load folder tree using fetch
async function loadFolderTree(wwwPath) {
    const container = document.getElementById('folderTreeContainer');
    if (container) {
        container.innerHTML = '<div class="folder-loading">Loading folders...</div>';
    }
    
    try {
        const response = await fetch('ajax/folder.php?Lng=en&WWWPath=' + encodeURIComponent(wwwPath), {
            method: 'GET',
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        });
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        const data = await response.json();
        
        if (data.success) {
            originalFolderData = data.tree;
            folderData = JSON.parse(JSON.stringify(data.tree));
            renderFolderTree(folderData);
        } else {
            showFolderError(data.error || 'Failed to load folders');
        }
    } catch (error) {
        showFolderError('Failed to load folder tree: ' + error.message);
    }
}

// Render folder tree
function renderFolderTree(tree) {
    const container = document.getElementById('folderTreeContainer');
    
    if (!container) {
        console.error('folderTreeContainer element not found');
        return;
    }
    
    if (!tree || tree.length === 0) {
        container.innerHTML = '<div class="folder-empty">No folders found</div>';
        return;
    }
    
    const html = renderFolderList(tree);
    container.innerHTML = `<ul class="folder-tree">${html}</ul>`;
    
    attachFolderEvents();
}

function renderFolderList(folders) {
    if (!folders || folders.length === 0) return '';
    
    let html = '';
    for (let folder of folders) {
        const hasChildren = folder.children && folder.children.length > 0;
        const folderId = 'folder_' + Math.random().toString(36).substr(2, 9);
        const isActive = currentSelectedPath === folder.full_path;
        
        html += `
            <li class="folder-item" data-path="${escapeHtml(folder.full_path)}">
                <div class="folder-label ${isActive ? 'active' : ''}" data-folder-id="${folderId}">
                    ${hasChildren ? `<span class="folder-toggle" data-toggle="${folderId}">${folderIcons.chevron}</span>` : '<span style="width: 18px; display: inline-block;"></span>'}
                    <span class="folder-icon">${folderIcons.folder}</span>
                    <span class="folder-name">${escapeHtml(folder.name)}</span>
                </div>
                ${hasChildren ? `<ul id="${folderId}" class="folder-children" style="display: none;">${renderFolderList(folder.children)}</ul>` : ''}
            </li>
        `;
    }
    
    return html;
}

function attachFolderEvents() {
    // Use event delegation for better performance
    const container = document.getElementById('folderTreeContainer');
    if (!container) return;
    
    // Remove existing listener to avoid duplicates
    container.removeEventListener('click', handleTreeClick);
    container.addEventListener('click', handleTreeClick);
}

function handleTreeClick(e) {
    // Handle toggle clicks
    const toggle = e.target.closest('.folder-toggle');
    if (toggle) {
        e.stopPropagation();
        const targetId = toggle.getAttribute('data-toggle');
        const targetUl = document.getElementById(targetId);
        if (targetUl) {
            const isExpanded = targetUl.style.display !== 'none';
            targetUl.style.display = isExpanded ? 'none' : 'block';
            toggle.classList.toggle('expanded', !isExpanded);
        }
        return;
    }
    
    // Handle folder selection
    const label = e.target.closest('.folder-label');
    if (label && !e.target.closest('.folder-toggle')) {
        const folderItem = label.closest('.folder-item');
        const folderPath = folderItem?.getAttribute('data-path');
        if (folderPath) {
            selectFolder(folderPath, label);
        }
    }
}

function selectFolder(path, labelElement) {
    currentSelectedPath = path;
    
    const directoryInput = document.getElementById('Directory');
    if (directoryInput) {
        directoryInput.value = path;
    }
    
    document.querySelectorAll('.folder-label').forEach(label => {
        label.classList.remove('active');
    });
    
    if (labelElement) {
        labelElement.classList.add('active');
    }
    
    // Trigger custom event for other components
    const event = new CustomEvent('folderSelected', { detail: { path } });
    document.dispatchEvent(event);
}

function showFolderError(message) {
    const container = document.getElementById('folderTreeContainer');
    if (container) {
        container.innerHTML = `<div class="folder-error">⚠️ ${escapeHtml(message)}</div>`;
    } else {
        console.error('Error: ' + message);
    }
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}





function Rclone()
{
	
    // Get the selected value from the dropdown
    var selectedValue = document.querySelector('select[name="Destination"]').value;

    // List of div IDs to hide/show
    var divIds = ['RemoteServer','Key','ApiKey','Token','AppToken','AccessToken','AccessKeyID','SecretAccessKey','Endpoint','Provider','Region','Url','Vendor','Email','Account','ShareName','RemoteUser','RemotePass','MegaUser','MegaPass','OpenDriveUser','OpenDrivePass','PikPakUser','PikPakPass','ProtonDriveUser','ProtonDrivePass','MailruUser','MailruPass','UloztoUser','UloztoPass','WebDAVUser','WebDAVPass','IDriveUser','IDrivePass','Port'];

	for (var i = 0; i < divIds.length; i++) 
	{
		var div = document.getElementById(divIds[i]);
		if (div) 
		{
			div.style.display = 'none';
		}
	}
	
    if (selectedValue === 'local')  
	{
		divIds = [];
	}
	
    if (selectedValue === 'ftp' || selectedValue === 'sftp')  
	{
    var divIds = ['RemoteServer','RemoteUser','RemotePass','Port'];
    }

    if (selectedValue === 's3')  
	{
    var divIds = ['AccessKeyID','SecretAccessKey','Endpoint','Provider','Region'];
    }

    if (selectedValue === 'ulozto')  
	{
    var divIds = ['AppToken','UloztoUser','UloztoPass'];
    }

    if (selectedValue === 'webdav')  
	{
    var divIds = ['Url','Vendor','WebDAVUser','WebDAVPass'];
    }
	
    if (selectedValue === 'idrive')  
	{
    var divIds = ['IDriveUser','IDrivePass'];
    }

    if (selectedValue === 'protondrive')
	{
    var divIds = ['ProtonDriveUser','ProtonDrivePass'];
    }
	
	
    if (selectedValue === 'mailru')
	{
    var divIds = ['MailruUser','MailruPass'];
    }
	
    if (selectedValue === 'mega')
	{
    var divIds = ['MegaUser','MegaPass'];
    }
	
    if (selectedValue === 'opendrive')
	{
    var divIds = ['OpenDriveUser','OpenDrivePass'];
    }
	
    if (selectedValue === 'pikpak')
	{
    var divIds = ['PikPakUser','PikPakPass'];
    }
	
    if (selectedValue === 'fichier')  
	{
    var divIds = ['ApiKey'];
    }
	
    if (selectedValue === 'drime' || selectedValue === 'gofile')  
	{
    var divIds = ['AccessToken'];
    }

    if (selectedValue === 'internxt')  
	{
    var divIds = ['Email','RemotePass'];
    }
	
    if (selectedValue === 'linkbox')  
	{
    var divIds = ['Token','Email','RemotePass'];
    }

    if (selectedValue === 'azureblob')  
	{
    var divIds = ['Account','Key'];
    }
	
    if (selectedValue === 'azurefiles')  
	{
    var divIds = ['Account','ShareName','Key'];
    }
	
	// Show all the divs
	for (var i = 0; i < divIds.length; i++) 
	{
		var div = document.getElementById(divIds[i]);
		if (div) {
			div.style.display = 'block';
		}
	}

}

let nameHandler = null;
let userHandler = null;

function MySQL() 
{

	if (document.forms['Form'].Edit)
	{
		if (document.forms['Form'].Edit.value=='1')
		{
		return;
		}
	}

	if (document.getElementById('WWWPath'))
	{
	Path=document.getElementById('WWWPath').value.split('/');
	Domain=Path[2];
	}
	else
	{
    Domain = document.getElementById('Domain').value;
	}
	
    let Name = Domain.split(".")[0].replace(/-/g, "");
    Name = Name.replace(/^\d+/, "") + "_";
    
    document.getElementById('Name').value = Name;
    document.getElementById('User').value = Name;
    
    const NameInput = document.getElementById('Name');
    const UserInput = document.getElementById('User');
    
    // Remove old listeners if they exist
    if (nameHandler) NameInput.removeEventListener("keydown", nameHandler);
    if (userHandler) UserInput.removeEventListener("keydown", userHandler);
    
    // Create new handlers
    nameHandler = function(event) {
        const oldVal = this.value;
        setTimeout(() => {
            if (this.value.indexOf(Name) !== 0) this.value = oldVal;
        }, 1);
    };
    
    userHandler = function(event) {
        const oldVal = this.value;
        setTimeout(() => {
            if (this.value.indexOf(Name) !== 0) this.value = oldVal;
        }, 1);
    };
    
    // Attach fresh listeners
    NameInput.addEventListener("keydown", nameHandler);
    UserInput.addEventListener("keydown", userHandler);
}








function GeneratePassword(InputID = null, length = 12)
{
    const lowercase = "abcdefghijklmnopqrstuvwxyz";
    const uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const numbers = "0123456789";
    const special = "!@#%^*_+";
    const allChars = lowercase + uppercase + numbers + special;
    
    let password = "";
    
    // Ensure at least one of each type
    password += lowercase[Math.floor(Math.random() * lowercase.length)];
    password += uppercase[Math.floor(Math.random() * uppercase.length)];
    password += numbers[Math.floor(Math.random() * numbers.length)];
    password += special[Math.floor(Math.random() * special.length)];
    
    // Fill remaining characters
    const remainingLength = length - 4;
    
    if (window.crypto && window.crypto.getRandomValues) {
        const randomArray = new Uint32Array(remainingLength);
        window.crypto.getRandomValues(randomArray);
        
        for (let i = 0; i < remainingLength; i++) {
            password += allChars[randomArray[i] % allChars.length];
        }
    } else {
        for (let i = 0; i < remainingLength; i++) {
            password += allChars[Math.floor(Math.random() * allChars.length)];
        }
    }
    
    // Shuffle the password to avoid predictable pattern
    password = password.split('').sort(() => Math.random() - 0.5).join('');
    
    // If InputID is provided, set the password in that input field
    if (InputID) 
    {
        const inputElement = document.getElementById(InputID);
        if (inputElement) 
        {
            inputElement.value = password;
            inputElement.type = 'text';
        } 
        else 
        {
            console.error(`Input element with id "${InputID}" not found`);
        }
        
        if (document.getElementById('VerifyPassword'))
        {
            document.getElementById('VerifyPassword').value = password;
            document.getElementById('VerifyPassword').type = 'text';
        }
    }
    
    return password;
}
     
function Search()
{
	// Main
	DivTags = document.getElementsByTagName('div');
	for(i=0;i<DivTags.length;i++) 
	{
		if(DivTags[i].getAttribute('id') == 'Find')
		{
			var str=DivTags[i].getAttribute('find');

			var SearchRegExp = new RegExp(document.getElementById('Search').value,'i');
			
			if(str.search(SearchRegExp) >= 0)
			{
				DivTags[i].style.display='';
			}
			else
			{
				DivTags[i].style.display='none';
			}
		}
	}

	// Icons
	ATags = document.getElementsByTagName('a');
	for(i=0;i<ATags.length;i++) 
	{
		if(ATags[i].getAttribute('id') == 'Find')
		{
			var str=ATags[i].getAttribute('find');

			var SearchRegExp = new RegExp(document.getElementById('Search').value,'i');
			
			if(str.search(SearchRegExp) >= 0)
			{
				ATags[i].style.display='';
			}
			else
			{
				ATags[i].style.display='none';
			}
		}
	}
}