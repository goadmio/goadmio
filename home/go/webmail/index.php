<?php
session_start();

$Domain = preg_replace("/^www\./","",$_SERVER['SERVER_NAME']);
$Domain = preg_replace("/^go\./","",$Domain);
$Domain = preg_replace("/^webmail\./","",$Domain);

$UserID=$_REQUEST['UserID'];$Open=$_REQUEST['Open'];$HTMLFileName=$_REQUEST['HTMLFileName'];
$Username=$_REQUEST['Username'];$OperatorImage=$_REQUEST['OperatorImage'];$Admin=$_REQUEST['Admin'];$DisableWelcomeMsg=$_REQUEST['DisableWelcomeMsg'];$DeleteCookiesEmailPass=$_REQUEST['DeleteCookiesEmailPass'];$Logout=$_REQUEST['Logout'];$Action=$_REQUEST['Action'];
$CookiesLoginOption=$_REQUEST['CookiesLoginOption'];$MainPage=$_REQUEST['MainPage'];$Ext=$_REQUEST['Ext'];
$FrameTop=$_REQUEST['FrameTop'];$FrameMain=$_REQUEST['FrameMain'];$FrameLeft=$_REQUEST['FrameLeft'];$FrameTop=$_REQUEST['FrameTop'];$FrameLeft=$_REQUEST['FrameLeft'];$FrameMain=$_REQUEST['FrameMain'];$FormLogin=$_REQUEST['FormLogin'];$Page=$_REQUEST['Page'];$FromPage=$_REQUEST['FromPage'];
$Webmail=$_REQUEST['Webmail'];
$Password=$_REQUEST['Password'];

$FormService=$_REQUEST['FormService'];$Service=$_REQUEST['Service'];

$ModuleName=$_REQUEST['ModuleName'];
$Page=$_REQUEST['Page'];$FromPage=$_REQUEST['FromPage'];

$CookiesEmail=$_COOKIE['CookiesEmail'];
$CookiesEmailPass=$_COOKIE['CookiesEmailPass'];

try {$PDO=new PDO("sqlite:/var/lib/sqlite/config.db");$PDO->setAttribute(PDO::ATTR_ERRMODE,PDO::ERRMODE_EXCEPTION);} catch (Exception $E) 
{

	if (stristr($E->getMessage(),"open_basedir"))
	{
	header("Location: https://webmail.$Domain");
	}
	else
	{
	echo $E->getMessage();
	}

	exit;

}


include("/usr/local/goadmio/home/go/include/function/function.php");

include("/usr/local/goadmio/include/config/config.php");

if ($DBName=="")
{
	echo Error("No database selected.");
	exit;
}


include "authenticate.php";


$Result = SQL("select * from Config where ConfigID=1");
foreach ($Result as $Row)
{
	$Version=Version($Row['Version']);
	$ControlScrolling=$Row['ControlScrolling'];
	$GMT=$Row['GMT'];
	
	$CR=$Row['CR'];
	$SSHPassword=$Row['SSHPassword'];
	
	$AdminHomePage=$Row['AdminHomePage'];
	
	if ($AdminHomePage=="")
	{
		$AdminHomePage="home.php?SecretCode=[SecretCode]&Theme=$Theme";
	}
	
	$AdminEmail=$Row['AdminEmail'];
	
}

if ($Theme=="") {$Theme="default";}

$Lng=$_SESSION['SessionLng'];
if ($Lng=="") {$Lng="en";}

$Date=date ("Y-m-d");
$Time=date ("G:i A");

if ($ControlScrolling=="")
{
	$ControlScrolling="no";
}

if ($_SESSION['SessionEmail']!="" and $_REQUEST['Logout']!=1)
{

$T = time();

// Determine if we show the Change Password form
$showChangePassword = isset($_REQUEST['ChangePassword']) && $_REQUEST['ChangePassword'] == 1;

// Prepare user display name
$userDisplay = htmlspecialchars($_SESSION['SessionEmail']);
if (stristr($_SESSION['SessionEmail'], '.')) {
    $userDisplay = '<a class="header-link" href="javascript:Load(\'go.php\')">' . $userDisplay . '</a>';
}

	$Result = SQL("select * from Mail where Email='{$_SESSION['SessionEmail']}' and Pass='{$_SESSION['SessionEmailPass']}'");
	foreach ($Result as $Row)
	{
		$Admin=$Row['Admin'];
		$Success=1;
	}

// Output HTML with dark theme
?><!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>GoAdmio Webmail</title>
    <!-- Google Fonts & Font Awesome -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,400;14..32,500;14..32,600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
	<link rel="stylesheet" href="css/en.css">
	
</head>
<body class=Body>
<div class="dashboard">
    
	<?php
	include "header.php";
	?>


    <!-- Main content -->
    <div class="content-card">
        <?php if ($showChangePassword): ?>
            <!-- Change Password Form -->
            <div class="password-form">
                <form name="Form" method="POST" onsubmit="return ChangePassword(this);" autocomplete="off">
                    <div class="form-group">
                        <label>New Password</label>
                        <input type="password" name="Pass" id="Password" class="input-field"
                               pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}"
                               title="Must contain at least one number, one uppercase, one lowercase, and at least 8 characters"
                               required maxlength="100">
                    </div>
                    <div class="form-group">
                        <label>Verify New Password</label>
                        <input type="password" name="VerifyPass" class="input-field" maxlength="100">
                    </div>
                    <div id="message">
                        <p id="letter" class="invalid">✔️ A <b>lowercase</b> letter</p>
                        <p id="capital" class="invalid">✔️ A <b>capital (uppercase)</b> letter</p>
                        <p id="number" class="invalid">✔️ A <b>number</b></p>
                        <p id="length" class="invalid">✔️ Minimum <b>8 characters</b></p>
                    </div>
                    <div id="DivSubmit">
                        <button type="submit" class="btn-primary">Change Password</button>
                    </div>
                </form>
                <hr>
                <a href="javascript:history.back()" class="back-link"><i class="fas fa-arrow-left"></i> Back</a>
            </div>
        <?php else: ?>
            <!-- Webmail selection grid -->
            <div class="webmail-grid">
                <!-- Roundcube -->
                <div class="webmail-card">
                    <a href="roundcube/login.php?T=<?php echo $T; ?>">
                        <div class="webmail-icon" style="background-image: url('roundcube.svg');"></div>
                        <h3>RoundCube</h3>
                    </a>
                </div>
                <!-- SnappyMail -->
                <div class="webmail-card">
                    <a href="snappymail.php">
                        <div class="webmail-icon" style="background-image: url('snappymail.svg');"></div>
                        <h3>SnappyMail</h3>
                    </a>
                </div>
                <?php if (file_exists("/usr/local/goadmio/home/go/webmail/horde/index.php")): ?>
                <div class="webmail-card">
                    <a href="horde.php">
                        <div class="webmail-icon" style="background-image: url('horde.gif');"></div>
                        <h3>Horde</h3>
                    </a>
                </div>
                <?php endif; ?>
                <?php if (file_exists("/usr/local/goadmio/home/go/webmail/squirrelmail/index.php")): ?>
                <div class="webmail-card">
                    <a href="http://<?php echo $Domain; ?>/webmail/squirrelmail">
                        <div class="webmail-icon" style="background-image: url('squirrelmail.jpg');"></div>
                        <h3>SquirrelMail</h3>
                    </a>
                </div>
                <?php endif; ?>
            </div>
        <?php endif; ?>
    </div>
</div>

<script type="text/javascript" src="ajax.js"></script>
<script>

    function ChangePassword() 
	{
        var Pass = document.forms['Form'].Pass.value;
        var Filter = /^[0-9a-zA-Z\.\_\$\!\@\#\%\^\&\*\+\-\=]+$/;
        if (!Filter.test(Pass)) {
            alert('Password must contain only letters, numbers and underscores');
            document.forms['Form'].Pass.focus();
            return false;
        }
        if (document.forms['Form'].Pass.value != document.forms['Form'].VerifyPass.value) {
            alert('Your password entries did not match');
            document.forms['Form'].Pass.value = '';
            document.forms['Form'].VerifyPass.value = '';
            document.forms['Form'].Pass.focus();
            return false;
        }
		
        document.getElementById('DivSubmit').innerHTML = '<img src="image/ajax/6.gif" border="0">';
		
        Pass = Pass.replace('$', '[DollarSign]');
        Pass = Pass.replace('&', '[AndSign]');
        Pass = Pass.replace('=', '[EqualSign]');
        http = Ajax();
        http.abort();
        http.open('POST', 'password.php', true);
        http.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        http.onreadystatechange = HandelPost;
        http.send('Pass=' + Pass);
        return false;
    }

    function HandelPost() 
	{
        if (http.readyState == 4) 
		{
            var response = http.responseText;
			setTimeout(function() {window.location.href = 'index.php';}, 1000);
			
			
        }
    }
	
</script>
</body>
</html>

<?php


}
else
{
	if ($_REQUEST['Logout']==1)
	{
		unset($_SESSION['SessionEmail']);
		unset($_SESSION['SessionEmailPass']);
	}

	?>
	
	
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Webmail Login | GoAdmio</title>
  <!-- Google Fonts & Font Awesome -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,400;14..32,500;14..32,600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  <link rel="stylesheet" href="css/en.css">
</head>
<body class=BodyLogin>
<div class="login-card">
  <div class="brand-header">
    <div class="brand-icon">
      <i class="fas fa-envelope-open-text"></i>
    </div>
    <h1>Webmail Login</h1>
  </div>

  <div class="form-container">
    <form id="webmailLoginForm" method="post" action="#" onsubmit="return Login();">
      <table class="login-table">
        <!-- Email input row -->
        <tr class="input-row">
          <td>
            <div style="position: relative;">
              <i class="fas fa-envelope input-icon"></i>
              <input type="text" id="EmailUser" name="EmailUser" class="input-field" 
                     placeholder="Email address" autocomplete="username" required>
            </div>
          </td>
        </tr>

        <!-- Password input row -->
        <tr class="input-row">
          <td>
            <div class="password-wrapper">
              <i class="fas fa-key input-icon"></i>
              <input type="password" id="EmailPass" name="EmailPass" class="input-field" 
                     placeholder="Password" autocomplete="current-password" required>
              <button type="button" class="toggle-password" id="togglePwdBtn" aria-label="Show password">
                <i class="far fa-eye-slash"></i>
              </button>
            </div>
          </td>
        </tr>

        <!-- Submit button row -->
        <tr class="button-row">
          <td>
            <button type="submit" class="login-btn">
              <span>Sign in</span> <i class="fas fa-arrow-right-to-bracket"></i>
            </button>
          </td>
        </tr>

        <!-- Status row: DivLogin centered with 30px height -->
        <tr class="status-row">
          <td>
            <div id="DivLogin"></div>
          </td>
        </tr>

        <!-- Round icons for RoundCube and SnappyMail -->
        <tr class="icons-row">
          <td>
            <div class="round-icons">
              <a href="roundcube/" class="icon-circle" id="roundcubeLink" title="Open RoundCube webmail">
                <!-- Roundcube SVG -->
                <svg viewBox="0 0 24 24" role="img" xmlns="http://www.w3.org/2000/svg">
                  <title>Roundcube icon</title>
                  <path d="M19.9 8.6c0 1.2-.3 2.3-.7 3.3l.7-.4 3.4-2L20.6 8c-.3-4.5-4-8-8.6-8S3.7 3.5 3.4 8L.7 9.6l3.1 1.8.9.5c-.5-1-.7-2.1-.7-3.3C4 4.2 7.6.7 11.9.7c4.5 0 8 3.5 8 7.9zM.1 17.3L11.7 24v-7.4L.1 9.9zm12.2-.7V24l11.6-6.7V9.9z"/>
                </svg>
              </a>
              <a href="snappymail/" class="icon-circle" id="snappymailLink" title="Open SnappyMail webmail">
                <!-- SnappyMail SVG -->
                <svg class="snappy-svg" xmlns="http://www.w3.org/2000/svg" version="1.0" viewBox="64 94 384.4 308">
                  <style>
                    path, rect { fill: currentColor; }
                    @media (prefers-color-scheme: dark) {
                      path, rect { fill: currentColor; }
                    }
                  </style>
                  <g transform="matrix(.1 0 0 -.1 0 512)">
                    <path d="M933 3908c-150-150-276-281-279-291-5-16 51-77 272-298l279-279h177c98 0 178 3 178 7s-89 97-197 206c-157 157-195 200-183 207 9 6 257 10 613 10h597v134c0 113-2 135-16 140-9 3-283 6-610 6s-594 3-594 8c0 4 90 97 199 206 110 110 198 203 195 208-3 4-84 8-181 8h-176zm2627 265c0-4 88-96 196-204 115-115 194-201 190-208-5-8-178-11-611-11-540 0-603-2-609-16-3-9-6-67-6-129 0-103 2-115 19-125 13-6 224-10 615-10 328 0 596-3 596-8 0-4-90-97-200-207s-200-203-200-207c0-5 82-8 182-8h182l285 286 285 285-285 285-284 284h-177c-98 0-178-3-178-7"/>
                    <path d="M640 2317V1154l28-27 28-27h3730l27 28 27 28v1156c0 636-4 1159-8 1162-5 3-41-27-80-67l-72-72-2-1030-3-1030H805l-3 1030-2 1030-72 72c-40 40-76 73-80 73-5 0-8-523-8-1163"/>
                    <path d="M1290 2972c0-4 84-92 188-195l187-187h1790l188 188c103 103 187 191 187 195s-75 7-168 7h-168l-69-70-69-70H1764l-69 70-69 70h-168c-93 0-168-3-168-8"/>
                    <rect width="105.704" height="113.393" x="965.825" y="-1995.056" ry="0"/>
                    <rect width="105.704" height="113.393" x="968.171" y="-1775.339" ry="0"/>
                    <rect width="105.704" height="113.393" x="1544.743" y="-1770.834" ry="0"/>
                    <rect width="105.704" height="113.393" x="1201.284" y="-2214.654" ry="0"/>
                    <rect width="105.704" height="113.393" x="1529.886" y="-2211.156" ry="0"/>
                    <rect width="105.704" height="113.393" x="1766.14" y="-2213.186" ry="0"/>
                    <rect width="105.704" height="113.393" x="1767.395" y="-1976.642" ry="0"/>
                    <rect width="105.704" height="113.393" x="2112.529" y="-2219.311" ry="0"/>
                    <rect width="105.704" height="113.393" x="2677.813" y="-2214.965" ry="0"/>
                    <rect width="105.704" height="113.393" x="2672.628" y="-1988.655" ry="0"/>
                    <rect width="105.704" height="113.393" x="2673.453" y="-1762.207" ry="0"/>
                    <rect width="105.704" height="113.393" x="2898.873" y="-2216.276" ry="0"/>
                    <rect width="105.704" height="113.393" x="3249.094" y="-2212.257" ry="0"/>
                    <rect width="105.704" height="113.393" x="3251.061" y="-1984.478" ry="0"/>
                    <rect width="105.704" height="113.393" x="3251.56" y="-1774.923" ry="0"/>
                    <rect width="105.704" height="113.393" x="3470.185" y="-2214.272" ry="0"/>
                    <rect width="105.704" height="113.393" x="3829.944" y="-2215.038" ry="0"/>
                    <rect width="105.704" height="113.393" x="4044.099" y="-2214.53" ry="0"/>
                    <rect width="105.704" height="113.393" x="4041.513" y="-1999.062" ry="0"/>
                    <rect width="105.704" height="113.393" x="4043.404" y="-1785.199" ry="0"/>
                    <rect width="105.704" height="113.393" x="3830.52" y="-1781.447" ry="0"/>
                  </g>
                </svg>
              </a>
            </div>
          </td>
        </tr>
      </table>
    </form>

    <div class="copyright">
      <i class="far fa-copyright"></i> GoAdmio
    </div>
  </div>
</div>

<script>
  // Ajax helper function
  function Ajax() {
    var xhr;
    try {
      xhr = new XMLHttpRequest();
    } catch(e) {
      try {
        xhr = new ActiveXObject("Microsoft.XMLHTTP");
      } catch(e) {
        alert("Your browser does not support AJAX!");
        return false;
      }
    }
    return xhr;
  }

  // Global http object
  var http = null;

  // Login function called on form submit
  function Login() {
    document.getElementById('DivLogin').innerHTML = 'Authenticating...';

    var EmailUser = document.getElementById('EmailUser').value;
    var EmailPass = document.getElementById('EmailPass').value;

    http = Ajax();
    if (http) {
      http.abort();
      http.open("POST", "login.php", true);
      http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
      http.onreadystatechange = HandelLogin;
      http.send('EmailUser=' + encodeURIComponent(EmailUser) + '&EmailPass=' + encodeURIComponent(EmailPass));
    } else {
      document.getElementById('DivLogin').innerHTML = '<span style="color:#FF0000;">AJAX initialization failed.</span>';
      setTimeout(function(){ document.getElementById('DivLogin').innerHTML=''; }, 5000);
    }
    return false; // prevent default form submission
  }

  // Handler for AJAX response
  function HandelLogin() {
    if (http.readyState == 4) {
      var response = http.responseText;

      if (response.match('Success')) {
        document.getElementById('DivLogin').innerHTML = 'Login successful redirecting...';
        setTimeout(function(){ window.location='index.php'; }, 2000);
      } else if (response.match('invalid')) {
        document.getElementById('DivLogin').innerHTML = '<span style="color:#FF0000;">' + response + '</span>';
        setTimeout(function(){ document.getElementById('DivLogin').innerHTML=''; }, 5000);
      } else {
        document.getElementById('DivLogin').innerHTML = response;
        setTimeout(function(){ document.getElementById('DivLogin').innerHTML=''; }, 5000);
      }
    }
  }

  // Password visibility toggle
  var toggleBtn = document.getElementById('togglePwdBtn');
  var passwordInput = document.getElementById('EmailPass');
  if (toggleBtn) {
    toggleBtn.addEventListener('click', function() {
      var type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
      passwordInput.setAttribute('type', type);
      var icon = this.querySelector('i');
      if (type === 'text') {
        icon.classList.remove('fa-eye-slash');
        icon.classList.add('fa-eye');
      } else {
        icon.classList.remove('fa-eye');
        icon.classList.add('fa-eye-slash');
      }
    });
  }

</script>
</body>
</html>

<?php
}

?>