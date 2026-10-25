<?php

include("/usr/local/goadmio/home/go/include/function/function.php");
include("/usr/local/goadmio/home/go/include/function/sendmail.php");
include("/usr/local/goadmio/include/config/config.php");
include("/usr/local/goadmio/include/config/smtp.php");

// Handle form submission
$showSuccess = false;
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['Email'])) 
{

	$Domain=str_replace(["www.","webmail.","go."],"",$_SERVER['HTTP_HOST']);
	
	$Password=RandomPassword(16);
	$OTP=sprintf("%06s",mt_rand(0,999999));
	$OTP=md5("$OTP|$Password");
	
	SQL("UPDATE Site SET OTP='$OTP' WHERE Domain='$Domain';");

	$URL = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http") . "://" . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];
	$URL = str_replace("/forgot.php","",$URL);

	$Email=$_POST['Email'];
	$Mobile=$Email;
	
	$Sql = "select * FROM Site where Domain='$Domain' and (Email='$Email' OR Mobile='$Mobile')";
	$Result = SQL($Sql);
	foreach ($Result as $Row)
	{
		
		$Message="
		<table>
		<td align='center'>
		<img src='$URL/image/logo.svg' width=48 height=48>
		<br>
		Don't worry, it happens!
		<br>
		To create a new password, just follow this link:<br>
		<a href='$URL/reset.php?OTP=$OTP'>Create a new password</a>
		<br>
		<br>
		Link doesn't work? Copy the following link to your browser address bar:
		<br>
		$URL/reset.php?OTP=$OTP
		</td>
		</table>
		";
		
		$Error=SendMail($Row['Email'],"GoAdmio - Forgot your password?",$Message,"GoAdmio","$SMTPUser");

		if (!stristr($Error,"successfully"))
		{
			echo $Error;
		}

	

	}
	
    // In a real application, you would send the email here
    // For demo, we just set the success flag
    $showSuccess = true;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <title>GoAdmio · Reset password</title>
  <link rel="shortcut icon" href="image/favicon.png" type="image/x-icon" />
  <link rel="apple-touch-icon" sizes="180x180" href="image/apple-touch-icon-180x180.png" />
  <style>
    /* ----- RESET & BASE ----- */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      margin: 0;
      overflow-x: hidden;
      background: var(--login-bg-page);
      font-family: system-ui, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
    }

    /* ----- LIGHT MODE (default) ----- */
    .go-login-wrapper {
      --login-bg-page: #f0f2f5;
      --login-card-bg: #ffffff;
      --login-card-border: #e0e4e8;
      --login-text-primary: #1e2a3e;
      --login-text-secondary: #4a5568;
      --login-label: #2c3e50;
      --login-input-bg: #ffffff;
      --login-input-border: #cbd5e1;
      --login-input-focus: #3b82f6;
      --login-input-text: #0f172a;
      --login-btn-bg: #2563eb;
      --login-btn-hover: #1d4ed8;
      --login-alert: #dc2626;
      --login-border-light: #e2e8f0;
      --toggle-bg-off: #cbd5e1;
      --toggle-bg-on: #FF6A00;
      --toggle-knob: #ffffff;
      --login-copy-hover: #eef2ff;
      --login-link-color: #2563eb;
      --hint-text: #4a5568;
      --success-color: #10b981;
    }

    /* ----- DARK MODE ----- */
    .go-login-wrapper.dark {
      --login-bg-page: #000000;
      --login-card-bg: #1C1C1E;
      --login-card-border: #48484A;
      --login-text-primary: #FFFFFF;
      --login-text-secondary: #8E8E93;
      --login-label: #FFFFFF;
      --login-input-bg: #2C2C2E;
      --login-input-border: #48484A;
      --login-input-focus: #0A84FF;
      --login-input-text: #FFFFFF;
      --login-btn-bg: #0A84FF;
      --login-btn-hover: #0A84FF;
      --login-alert: #FF453A;
      --login-border-light: #3A3A3C;
      --toggle-bg-off: #636366;
      --toggle-bg-on: #FF6A00;
      --toggle-knob: #FFFFFF;
      --login-copy-hover: #3A3A3C;
      --login-link-color: #0A84FF;
      --hint-text: #8E8E93;
      --success-color: #34C759;
    }

    .go-login-wrapper {
      background-color: var(--login-bg-page);
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      padding: 1rem;
      width: 100%;
      max-width: 100vw;
      transition: background 0.2s;
    }

    /* ----- CARD ----- */
    .login-container {
      max-width: 400px;
      width: 100%;
      background: var(--login-card-bg);
      border-radius: 28px;
      box-shadow: 0 20px 35px -12px rgba(0, 0, 0, 0.1);
      border: 1px solid var(--login-card-border);
      overflow: hidden;
      transition: background 0.2s, border 0.2s;
    }

    .login-header {
      background: var(--login-card-bg);
      padding: 1.5rem 2rem 0.8rem 2rem;
      border-bottom: 1px solid var(--login-border-light);
      text-align: center;
    }
    .login-logo {
      width: 50px;
      height: 50px;
      object-fit: contain;
      margin: 0 auto;
      display: inline-block;
    }

    .login-form {
      padding: 1.8rem 2rem 1.5rem;
    }

    /* ----- ROUNDED INPUTS + BUTTON ----- */
    .input-group input,
    .login-btn {
      border-radius: 60px !important;
    }

    .input-group input {
      width: 100%;
      padding: 12px 14px;
      font-size: 0.95rem;
      background-color: var(--login-input-bg);
      border: 1px solid var(--login-input-border);
      color: var(--login-input-text);
      outline: none;
      transition: 0.2s;
      font-family: inherit;
      box-sizing: border-box;
    }

    .input-group input:focus {
      border-color: var(--login-input-focus);
      box-shadow: 0 0 0 3px rgba(10, 132, 255, 0.2);
    }

    .input-group {
      margin-bottom: 1.5rem;
    }

    /* toggle group (dark mode) */
    .toggle-group {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 1.5rem;
    }
    .toggle-group label {
      font-size: 0.9rem;
      font-weight: 500;
      color: var(--login-label);
      margin: 0;
      cursor: pointer;
    }
    .toggle-switch {
      position: relative;
      display: inline-block;
      width: 52px;
      height: 28px;
      margin-left: 12px;
    }
    .toggle-switch input {
      opacity: 0;
      width: 0;
      height: 0;
    }
    .slider {
      position: absolute;
      cursor: pointer;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background-color: var(--toggle-bg-off);
      transition: 0.2s;
      border-radius: 34px;
    }
    .slider:before {
      position: absolute;
      content: "";
      height: 22px;
      width: 22px;
      left: 3px;
      bottom: 3px;
      background-color: var(--toggle-knob);
      transition: 0.2s;
      border-radius: 50%;
    }
    input:checked+.slider {
      background-color: var(--toggle-bg-on);
    }
    input:checked+.slider:before {
      transform: translateX(24px);
    }

    /* primary button */
    .login-btn {
      background: var(--login-btn-bg);
      color: white;
      border: none;
      width: 100%;
      padding: 12px;
      font-size: 1rem;
      font-weight: 600;
      cursor: pointer;
      transition: 0.2s;
      margin-top: 8px;
      font-family: inherit;
    }
    .login-btn:hover {
      background: var(--login-btn-hover);
      transform: scale(0.98);
      opacity: 0.9;
    }

    .auth-message {
      text-align: center;
      margin-top: 12px;
      font-size: 0.85rem;
      min-height: 20px;
      color: var(--login-alert);
      font-weight: 500;
    }
    .auth-message.success {
      color: var(--success-color);
    }

    /* back link */
    .back-link {
      text-align: center;
      margin-top: 1rem;
      font-size: 0.85rem;
    }
    .back-link a {
      color: var(--login-link-color);
      text-decoration: none;
      font-weight: 500;
      border-bottom: 1px dotted transparent;
      transition: border-color 0.2s;
      cursor: pointer;
    }
    .back-link a:hover {
      border-bottom-color: var(--login-link-color);
    }

    /* responsive */
    @media (max-width: 550px) {
      .login-form {
        padding: 1.5rem;
      }
      .login-logo {
        width: 50px;
        height: 50px;
      }
    }

    /* instruction text above input */
    .reset-instruction {
      font-size: 0.9rem;
      color: var(--hint-text);
      text-align: center;
      margin-bottom: 1.2rem;
      line-height: 1.4;
      padding: 0 0.2rem;
    }

    /* success state - hide form, show message */
    .success-container {
      display: none;
      text-align: center;
      padding: 1.5rem 0.5rem;
    }
    .success-container.show {
      display: block;
    }
    .success-icon {
      font-size: 3.5rem;
      margin-bottom: 0.75rem;
      display: block;
    }
    .success-title {
      font-size: 1.25rem;
      font-weight: 600;
      color: var(--login-text-primary);
      margin-bottom: 0.5rem;
    }
    .success-message {
      font-size: 1rem;
      color: var(--login-text-secondary);
      line-height: 1.5;
    }
    .success-message strong {
      color: var(--login-text-primary);
      font-weight: 600;
    }
    .success-actions {
      margin-top: 1.5rem;
    }
    .success-actions .login-btn {
      display: inline-block;
      width: auto;
      padding: 10px 28px;
      text-decoration: none;
      color: white;
      background: var(--login-btn-bg);
      border-radius: 60px;
      font-weight: 600;
      transition: 0.2s;
      border: none;
      font-size: 0.95rem;
      cursor: pointer;
    }
    .success-actions .login-btn:hover {
      background: var(--login-btn-hover);
      transform: scale(0.98);
      opacity: 0.9;
    }
  </style>
</head>
<body>

<div class="go-login-wrapper" id="goLoginWrapper">
  <div class="login-container">
    <div class="login-header">
      <img src="image/logo.svg" alt="Logo" class="login-logo" onerror="this.style.display='none'" />
    </div>

    <div class="login-form">
      <?php if ($showSuccess): ?>
        <!-- SUCCESS STATE -->
        <div class="success-container show" id="successContainer">
          <span class="success-icon">📧</span>
          <div class="success-title">Check your inbox</div>
          <div class="success-message">
            An email with instructions for creating a new password has been sent to 
            <strong><?php echo htmlspecialchars($_POST['Email'] ?? ''); ?></strong>
          </div>
          <div class="success-actions">
            <a href="index.php" class="login-btn" style="display:inline-block; text-decoration:none;">← Back</a>
          </div>
        </div>
      <?php endif; ?>

      <!-- REQUEST FORM (hidden on success) -->
      <form name="RequestForm" id="RequestForm" method="POST" action="" autocomplete="off" <?php echo $showSuccess ? 'style="display:none;"' : ''; ?>>
        <input type="hidden" name="TargetFrame" id="TargetFrame" value="" />
        <input type="hidden" name="SessionTheme" id="SessionTheme" value="light" />

        <div class="reset-instruction">
          Enter your email or mobile number and we’ll send you a link to reset your password
        </div>

        <div class="input-group">
          <input type="text" name="Email" id="Email" placeholder="Email or mobile number" required title="Enter your email or mobile" autocomplete="username" value="<?php echo isset($_POST['Email']) ? htmlspecialchars($_POST['Email']) : ''; ?>" />
        </div>

        <button type="submit" class="login-btn" id="sendOtpBtn">Send Link →</button>
        <div id="DivRequestMessage" class="auth-message"></div>

        <div class="back-link">
          <a href="index.php">← Back to login</a>
        </div>
      </form>

      <!-- hidden reset form (kept for potential future use) -->
      <form name="ResetForm" id="ResetForm" method="POST" onsubmit="return false;" autocomplete="off" style="display: none;">
        <input type="hidden" name="TargetFrame" value="" />
        <input type="hidden" name="SessionTheme" id="SessionThemeReset" value="light" />
        <div class="input-group">
          <input type="password" name="NewPassword" id="NewPassword" placeholder="New password" />
        </div>
        <div class="input-group">
          <input type="password" name="ConfirmPassword" id="ConfirmPassword" placeholder="Confirm new password" />
        </div>
        <button type="submit" class="login-btn">Reset password →</button>
        <div id="DivResetMessage" class="auth-message"></div>
      </form>

    </div>
  </div>
</div>

<script>
  (function() {
    const wrapper = document.getElementById('goLoginWrapper');
    const themeInput = document.getElementById('SessionTheme');
    const STORAGE_KEY = 'GoAdmioDarkMode';

    // Dark mode
    function setDarkMode(enabled) {
      if (enabled) {
        wrapper.classList.add('dark');
        if (themeInput) themeInput.value = 'dark';
      } else {
        wrapper.classList.remove('dark');
        if (themeInput) themeInput.value = 'light';
      }
      localStorage.setItem(STORAGE_KEY, enabled ? 'true' : 'false');
    }

    let saved = localStorage.getItem(STORAGE_KEY);
    let initialDark = false;
    if (saved !== null) {
      initialDark = saved === 'true';
    } else {
      initialDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    }
    setDarkMode(initialDark);

    if (window.matchMedia) {
      const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
      const handleChange = function(e) {
        if (localStorage.getItem(STORAGE_KEY) === null) {
          setDarkMode(e.matches);
        }
      };
      mediaQuery.addEventListener('change', handleChange);
    }

    // If there's a success message, we don't need to do anything else
    <?php if (!$showSuccess): ?>
    // Simple client-side validation (optional)
    const form = document.getElementById('RequestForm');
    const emailInput = document.getElementById('Email');
    const msgDiv = document.getElementById('DivRequestMessage');

    form.addEventListener('submit', function(e) {
      const val = emailInput.value.trim();
      if (!val) {
        e.preventDefault();
        msgDiv.innerHTML = '<span style="color: var(--login-alert);">Please enter your email or mobile</span>';
        return false;
      }
      // Allow submission - PHP will handle the success message
      return true;
    });
    <?php endif; ?>
  })();
</script>
</body>
</html>