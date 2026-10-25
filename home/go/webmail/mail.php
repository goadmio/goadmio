<?php
session_start();

// ----- YOUR EXISTING PHP LOGIC (KEPT INTACT) -----
$Domain = $_SERVER['HTTP_HOST'];
$Domain = str_replace("http://", "", $Domain);
$Domain = str_replace("www.", "", $Domain);
$Domain = str_replace(":2020", "", $Domain);
$Domain = str_replace(":2022", "", $Domain);

$UserID = $_REQUEST['UserID']; $Open = $_REQUEST['Open']; $HTMLFileName = $_REQUEST['HTMLFileName'];
$Username = $_REQUEST['Username']; $OperatorImage = $_REQUEST['OperatorImage']; $Admin = $_REQUEST['Admin'];
$DisableWelcomeMsg = $_REQUEST['DisableWelcomeMsg']; $DeleteCookiesEmailPass = $_REQUEST['DeleteCookiesEmailPass'];
$Logout = $_REQUEST['Logout']; $Action = $_REQUEST['Action'];
$CookiesLoginOption = $_REQUEST['CookiesLoginOption']; $MainPage = $_REQUEST['MainPage']; $Ext = $_REQUEST['Ext'];
$FrameTop = $_REQUEST['FrameTop']; $FrameMain = $_REQUEST['FrameMain']; $FrameLeft = $_REQUEST['FrameLeft'];
$FormLogin = $_REQUEST['FormLogin']; $Page = $_REQUEST['Page']; $FromPage = $_REQUEST['FromPage'];
$Webmail = $_REQUEST['Webmail'];
$Password = $_REQUEST['Password'];

$FormService = $_REQUEST['FormService']; $Service = $_REQUEST['Service'];

$ModuleName = $_REQUEST['ModuleName'];

$CookiesEmailPass = $_COOKIE['CookiesEmailPass'];
$CookiesEmailUser = $_COOKIE['CookiesEmailUser'];

$Domain = $_SERVER['HTTP_HOST'];
$Domain = str_replace("www.", "", $Domain);
$Domain = str_replace(":2020", "", $Domain);

$Edit = $_REQUEST['Edit'];
$Email = trim($_REQUEST['Email']);
$Email = strtolower($Email);
$Password = trim($_REQUEST['Password']);

include("/usr/local/goadmio/home/go/include/function/function.php");
include("/usr/local/goadmio/include/config/config.php");

$Result = SQL("select * from Config where ConfigID=1");
foreach ($Result as $Row) {
    $Version = Version($Row['Version']);
    $ControlScrolling = $Row['ControlScrolling'];
    $GMT = $Row['GMT'];
    $CR = $Row['CR'];
    $SSHPassword = $Row['SSHPassword'];
    $AdminHomePage = $Row['AdminHomePage'];
    if ($AdminHomePage == "") {
        $AdminHomePage = "home.php?SecretCode=[SecretCode]&Theme=$Theme";
    }
    $AdminEmail = $Row['AdminEmail'];
}

if ($Theme == "") { $Theme = "default"; }

$Lng = $_SESSION['SessionLng'];
if ($Lng == "") { $Lng = "en"; }

$Date = date("Y-m-d", mktime(date("G"), date("i") + $GMT, date("s"), date("m"), date("d"), date("Y")));
$Time = date("G:i A", mktime(date("G"), date("i") + $GMT, date("s"), date("m"), date("d"), date("Y")));

if ($ControlScrolling == "") {
    $ControlScrolling = "no";
}

// ---- Authentication check (same as original) ----
$Result = SQL("select * from Mail where Email='{$_SESSION['SessionEmail']}' and Pass='{$_SESSION['SessionEmailPass']}'");
$Success = 0;
foreach ($Result as $Row) 
{
    $Admin = $Row['Admin'];
    $Success = 1;
}

if ($Success != 1) 
{
    if ($Lng == "ar") { echo "<html dir=rtl>"; }
    echo Error("Invalid username or password");
    session_unset();
    session_destroy();
    unset($_SESSION['SessionEmail'], $_SESSION['SessionUserID'], $_SESSION['SessionEmailPass'], $_SESSION['SessionUserGroup'], $_SESSION['SessionFullName'], $_SESSION['SessionRegisterDate'], $_SESSION['SessionLastVisitDate'], $_SESSION['SessionLastVisitTime'], $_SESSION['SessionUserType'], $_SESSION['SessionCountryID']);
    setcookie("CookiesUserID", "", time() - 3600);
    setcookie("CookiesUserGroup", "", time() - 3600);
    setcookie("CookiesEmailUser", "", time() - 3600);
    setcookie("CookiesEmailPass", "", time() - 3600);
    setcookie("CookiesUserType", "", time() - 3600);
    echo "<META HTTP-EQUIV='Refresh' Content='3;URL=index.php'>";
    exit;
}

// ---- Prepare user display ----
if (stristr($_SESSION['SessionEmail'], ".")) 
{
    $U = "<a class=\"header-link\" href=\"javascript:Load('blackhost.php')\">" . htmlspecialchars($_SESSION['SessionEmail']) . "</a>";
} else {
    $U = htmlspecialchars($_SESSION['SessionEmail']);
}

// ---- Pagination and sorting (original) ----
$PageNo = 20;
$SortBy = $_REQUEST['SortBy'];
$Direction = $_REQUEST['Direction'];
if ($SortBy == "") $SortBy = "Email";
if ($Direction == "") $Direction = "ASC";
if ($Page == "") $Page = 1;
$FromRecord = ($Page - 1) * $PageNo;

// --------------------------------------------------------------
// NEW HTML OUTPUT WITH DARK THEME (matching login page design)
// --------------------------------------------------------------
?><!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>Email Accounts | GoAdmio Webmail</title>
    <!-- Google Fonts & Font Awesome -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,400;14..32,500;14..32,600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
	<link rel="stylesheet" href="css/en.css">

</head>
<body class=Body>
<div class="dashboard">



	<?php
	
	include "header.php";

		if ($_REQUEST['Delete'] == 1) 
		{
			$Domain = $_SESSION['SessionEmailDomain'];
			
			if ($Email!="" AND $Domain!="")
			{
			$Error = SSH("/usr/bin/sudo /go/mail --email $Email --domain $Domain --action delete", $SSHUsername, $SSHPassword);
			echo Error("$Error");
			}
			
			echo "<br>";
		}

		if ($_POST['Edit'] == 1)
		{
			$Domain = $_SESSION['SessionEmailDomain'];
			$User = trim($_REQUEST['User']);
			$Pass = trim($_REQUEST['Pass']);
			$Email = "$User@$Domain";
			
			if ($Email!="" AND $Pass!="" AND $Domain!="")
			{
			$Error = SSH("/usr/bin/sudo /go/mail --email $Email --pass $Pass --domain $Domain --action edit", $SSHUsername, $SSHPassword);
			echo Error("$Error");
			}
			
			echo "<br>";
		} elseif ($_REQUEST['User'] != "") 
		{
			$Domain = $_SESSION['SessionEmailDomain'];
			$User = trim($_REQUEST['User']);
			$Pass = trim($_REQUEST['Pass']);
			$Email = "$User@$Domain";

			$Sql = "select Email from Mail where Email='$Email'";
			$Result = SQL($Sql);
			foreach ($Result as $Row) 
			{
				echo Error("Email $Email already exists.");
				echo "<br>";

				exit;
			}

			if ($Email!="" AND $Pass!="" AND $Domain!="")
			{
			$TimeStamp=time();
			$Reject=0;
			$KeepCopy=0;
			$Suspend=0;
			$Admin=0;
			$Error = SSH ("/usr/bin/sudo /go/mail --email '$Email' --pass '$Pass' --forwardto '$ForwardTo' --reject '$Reject' --rejectmessage '$RejectMessage' --keepcopy '$KeepCopy' --domain '$Domain' --defaultaddress '$DefaultAddress' --suspend '$Suspend' --admin '$Admin' --description '$Description' --timestamp '$TimeStamp' --action add",$_SESSION['SessionSSHUsername'],$_SESSION['SessionSSHPassword']);
			echo Error("$Error");
			}
			
			echo "<br>";
		}

$X = 0;
$Result = SQL("select * from Mail where Trash=0 and Username='{$_SESSION['SessionWebsiteUsername']}' order by $SortBy $Direction");
$RowsNo = count($Result);
?>
	


    <div class="content-card">
        <?php
        // ---- Show create/edit form if needed ----
        if ($_GET['Edit'] == 1 || $_GET['Create']==1) 
		{
            // This is the create/edit form
            $isEdit = ($_REQUEST['Edit'] == 1);
            $emailParts = explode("@", $Email);
            $user = $emailParts[0] ?? '';
        ?>
        <div class="form-group">
            <h2 style="color:#eef2ff; margin-bottom:1rem;"><?php echo $isEdit ? 'Modify an Email' : 'Create an Email'; ?></h2>
            <form name="Form" method="POST" action="mail.php" onsubmit="return validateEmailForm();">
                <input type="hidden" name="Edit" value="<?php echo $isEdit ? 1 : 0; ?>">
                <div class="form-group">
                    <label>Username</label>
                    <input type="text" name="User" value="<?php echo htmlspecialchars($user); ?>" <?php echo $isEdit ? 'readonly' : ''; ?> class="input-field" maxlength="100" required>
                    <span style="color:#aaa;"> @ <?php echo htmlspecialchars($_SESSION['SessionEmailDomain']); ?></span>
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" name="Pass" id="Password" class="input-field"
                           pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}"
                           title="Must contain at least one number, one uppercase, one lowercase, and at least 8 characters"
                           required maxlength="100">
                </div>
                <div id="message">
                    <p id="letter" class="invalid">✔️ A <b>lowercase</b> letter</p>
                    <p id="capital" class="invalid">✔️ A <b>capital (uppercase)</b> letter</p>
                    <p id="number" class="invalid">✔️ A <b>number</b></p>
                    <p id="length" class="invalid">✔️ Minimum <b>8 characters</b></p>
                </div>
                <div id="DivSubmit">
                    <button type="submit" class="btn-primary"><?php echo $isEdit ? 'Change Password' : 'Create'; ?></button>
                </div>
            </form>
            <hr>
            <a href="mail.php" class="back-link"><i class="fas fa-arrow-left"></i> Back to Accounts</a>
        </div>
        <?php
        } else {
            // ---- Show accounts list ----
        ?>
        <h2 style="color:#eef2ff; margin-bottom:1rem;">Email Accounts</h2>
        <table class="accounts-table">
            <thead>
                <tr>
                    <th><a href="?SortBy=Email" style="color:#9bb8da;">Email</a></th>
                    <th><a href="?SortBy=TimeStamp" style="color:#9bb8da;">Created Date</a></th>
                    <th style="text-align:right;">Actions</th>
                </tr>
            </thead>
            <tbody>
            <?php
            foreach ($Result as $Row) 
			{
                $serial++;
                $createdDate = ($Row['TimeStamp'] >= 1) ? date("D j M Y g:i a", $Row['TimeStamp']) : '';
                ?>
                <tr>

                    <td><?php echo htmlspecialchars($Row['Email']); ?></td>
                    <td><?php echo htmlspecialchars($createdDate); ?></td>
                    <td style="text-align:right;">
                        <a href="mail.php?Edit=1&Domain=<?php echo urlencode($Row['Domain']); ?>&Email=<?php echo urlencode($Row['Email']); ?>&Page=<?php echo $Page; ?>" class="action-link">Change Password</a>
                        <a href="mail.php?Delete=1&Step=1&Domain=<?php echo urlencode($Row['Domain']); ?>&Email=<?php echo urlencode($Row['Email']); ?>&Page=<?php echo $Page; ?>" class="action-link" style="color:#f66;" onclick="return confirm('Delete this email account?');">Delete</a>
						
						<?php 
						echo "
						<a href=\"roundcube.php?MailID={$Row['MailID']}\" target='_blank' class='action-link'>Roundcube</a>
						";
						?>
						
                    </td>
                </tr>
            <?php
            }

            ?>
            </tbody>
            <tfoot>
                <tr>
                    <th colspan="4" style="text-align:left; font-weight:normal; padding-top:1rem;">
                        Showing <?php echo count($Result); ?> of <?php echo $RowsNo; ?> records.
                    </th>
                </tr>
            </tfoot>
        </table>
        <div style="margin-top:1rem;">
            <a href="mail.php?Create=1" class="btn-primary" style="display:inline-block; width:auto; padding:0.6rem 1.2rem;">Create New Email</a>
        </div>
        <?php } ?>
    </div>
</div>

<script>

    function validateEmailForm() {
        var pass = document.forms['Form'].Pass.value;
        if (pass === "") {
            alert("Please enter a password.");
            document.forms['Form'].Pass.focus();
            return false;
        }
        var filter = /^[0-9a-zA-Z\.\_\$\!\@\#\%\^\&\*\+\-\=]+$/;
        if (!filter.test(pass)) {
            alert('Password must contain only letters, numbers and underscores');
            document.forms['Form'].Pass.focus();
            return false;
        }
        return true;
    }
</script>
</body>
</html>