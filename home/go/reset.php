<!DOCTYPE html>

<?php

include("/usr/local/goadmio/home/go/include/function/function.php");
include("/usr/local/goadmio/home/go/include/function/sendmail.php");
include("/usr/local/goadmio/include/config/config.php");
include("/usr/local/goadmio/include/config/smtp.php");

$Domain=str_replace(["www.","webmail.","go."],"",$_SERVER['HTTP_HOST']);
$OTP=$_REQUEST['OTP'];

$Sql = "select * from Config where ConfigID=1";
$Result = SQL($Sql);
foreach ($Result as $Row)
{
	$SSHPassword=$Row['SSHPassword'];
}

// Check if form was submitted
$formSubmitted = isset($_POST['NewPassword']) && isset($_POST['ConfirmPassword']);
$successMessage = '';
$errorMessage = '';
$passwordChanged = false;

if ($formSubmitted) 
{
    $Password = $_POST['NewPassword'];
	
    $newPassword = $_POST['NewPassword'];
    $confirmPassword = $_POST['ConfirmPassword'];
    $OTP = $_POST['OTP'] ?? '';
    
    if (strlen($newPassword) < 4) {
        $errorMessage = 'Password must be at least 4 characters';
    } elseif ($newPassword !== $confirmPassword) {
        $errorMessage = 'Passwords do not match';
    } 
	else 
	{
	
		if (strlen($OTP)>=6)
		{
		
			$Sql = "select * FROM Site where Domain='$Domain' and OTP='$OTP'";
			$Result = SQL($Sql);
			foreach ($Result as $Row)
			{
				$Error=SSH ("/usr/bin/sudo /go/password $Domain $Password",$SSHUsername,$SSHPassword);
				$passwordChanged = true;
				$successMessage = "$Error";
				
				$Password=RandomPassword(16);
				$OTP=sprintf("%06s",mt_rand(0,999999));
				$OTP=md5("$OTP|$Password");

				
				SQL("UPDATE Site SET OTP='$OTP' WHERE Domain='$Domain';");
			}

		}

    }
}

?>

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
            --login-success: #10b981;
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
            --login-success: #30d158;
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

        /* Hidden state for inputs */
        .input-group.hidden {
            display: none;
        }

        /* password wrapper (for toggle) */
        .password-wrapper {
            position: relative;
            width: 100%;
        }
        .password-wrapper input {
            padding-right: 45px;
            border-radius: 60px !important;
        }
        .toggle-password {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            font-size: 1.2rem;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--login-text-secondary);
            transition: color 0.2s;
            opacity: 0.7;
            border-radius: 60px;
        }
        .toggle-password:hover {
            opacity: 1;
            color: var(--login-input-focus);
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

        /* Hide toggle group on success */
        .toggle-group.hidden {
            display: none;
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
        
        .login-btn.hidden {
            display: none;
        }

        .auth-message {
            text-align: center;
            margin-top: 12px;
            font-size: 0.85rem;
            min-height: 20px;
            font-weight: 500;
        }
        
        .auth-message.success {
            color: var(--login-success);
            font-size: 1.1rem;
            padding: 20px 0;
        }
        
        .auth-message.error {
            color: var(--login-alert);
        }

        /* Success container */
        .success-container {
            text-align: center;
            padding: 20px 0 10px 0;
        }
        
        .success-icon {
            font-size: 4rem;
            margin-bottom: 15px;
            display: block;
        }
        
        .success-text {
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--login-success);
            margin-bottom: 8px;
        }
        
        .success-subtext {
            font-size: 0.9rem;
            color: var(--login-text-secondary);
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

        /* hidden google auth row (kept for consistency) */
        .google-auth-row {
            display: none;
        }
        .google-auth-row.show {
            display: block;
        }

        /* remove info row completely */
        .info-row-below {
            display: none;
        }
    </style>
</head>
<body>

    <div class="go-login-wrapper" id="goLoginWrapper">
        <div class="login-container">
            <div class="login-header">
                <!-- logo – same as login panel -->
                <img src="image/logo.svg" alt="Logo" class="login-logo" onerror="this.style.display='none'" />
            </div>

            <div class="login-form">
                <?php if ($passwordChanged): ?>
                    <!-- Success Message - Hide all inputs -->
                    <div class="success-container">
                        <span class="success-icon">🔐</span>
                        <div class="success-text">✅ Password has been changed successfully</div>
                        <div class="success-subtext">Your password has been updated. You can now login with your new password.</div>
                    </div>
                    
                    <!-- Hidden inputs (keep hidden fields) -->
                    <input type="hidden" name="OTP" id="OTP" value="<?php echo htmlspecialchars($OTP); ?>" />
                    <input type="hidden" name="TargetFrame" id="TargetFrame" value="" />
                    <input type="hidden" name="SessionTheme" id="SessionTheme" value="light" />
                    
                    <!-- Back to login button -->
                    <div style="margin-top: 20px;">
                        <a href="index.php" style="display: block; text-align: center; color: var(--login-link-color); text-decoration: none; font-weight: 500; padding: 12px; border: 1px solid var(--login-link-color); border-radius: 60px; transition: 0.2s;">← Back to Login</a>
                    </div>
                    
                <?php else: ?>
                    <!-- Reset / forget password form -->
                    <form name="ResetForm" id="ResetForm" method="POST" action="" autocomplete="off">
                        <?php
                        echo "
                        <input type=\"hidden\" name=\"OTP\" id=\"OTP\" value=\"$OTP\" />
                        ";
                        ?>
                        
                        <input type="hidden" name="TargetFrame" id="TargetFrame" value="" />
                        <input type="hidden" name="SessionTheme" id="SessionTheme" value="light" />

                        <!-- New password (with toggle) -->
                        <div class="input-group">
                            <div class="password-wrapper">
                                <input type="password" name="NewPassword" id="NewPassword" placeholder="New password" required title="Enter new password" autocomplete="new-password" />
                                <button type="button" class="toggle-password" id="toggleNewPassword" aria-label="Show/Hide password">👁️</button>
                            </div>
                        </div>

                        <!-- Confirm password -->
                        <div class="input-group">
                            <div class="password-wrapper">
                                <input type="password" name="ConfirmPassword" id="ConfirmPassword" placeholder="Confirm new password" required title="Re-enter new password" autocomplete="new-password" />
                                <button type="button" class="toggle-password" id="toggleConfirmPassword" aria-label="Show/Hide password">👁️</button>
                            </div>
                        </div>

                        <!-- Dark mode toggle (same as login) -->
                        <div class="toggle-group">
                            <label for="darkModeToggleReset">Dark Mode</label>
                            <label class="toggle-switch">
                                <input type="checkbox" id="darkModeToggleReset" />
                                <span class="slider"></span>
                            </label>
                        </div>

                        <button type="submit" class="login-btn">Reset password →</button>
                        
                        <?php if ($errorMessage): ?>
                            <div id="DivResetMessage" class="auth-message error">
                                <span><?php echo htmlspecialchars($errorMessage); ?></span>
                            </div>
                        <?php else: ?>
                            <div id="DivResetMessage" class="auth-message"></div>
                        <?php endif; ?>

                        <!-- extra link: back to login -->
                        <div class="back-link">
                            <a href="index.php">← Back to login</a>
                        </div>
                    </form>
                <?php endif; ?>
            </div>
        </div>

        <!-- info row removed as requested -->
    </div>

    <script>
        (function() {
            // ----- DARK MODE (sync with login panel) -----
            const wrapper = document.getElementById('goLoginWrapper');
            const darkToggle = document.getElementById('darkModeToggleReset');
            const themeInput = document.getElementById('SessionTheme');
            const STORAGE_KEY = 'GoAdmioDarkMode';

            function setDarkMode(enabled) {
                if (enabled) {
                    wrapper.classList.add('dark');
                    if (themeInput) themeInput.value = 'dark';
                } else {
                    wrapper.classList.remove('dark');
                    if (themeInput) themeInput.value = 'light';
                }
                if (darkToggle) darkToggle.checked = enabled;
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

            if (darkToggle) {
                darkToggle.addEventListener('change', function(e) {
                    setDarkMode(e.target.checked);
                });
            }

            if (window.matchMedia) {
                const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
                const handleChange = function(e) {
                    if (localStorage.getItem(STORAGE_KEY) === null) {
                        setDarkMode(e.matches);
                    }
                };
                mediaQuery.addEventListener('change', handleChange);
            }

            // ----- PASSWORD TOGGLE (two fields) -----
            function setupToggle(btnId, inputId) {
                const btn = document.getElementById(btnId);
                const input = document.getElementById(inputId);
                if (btn && input) {
                    btn.addEventListener('click', function() {
                        const type = input.getAttribute('type') === 'password' ? 'text' : 'password';
                        input.setAttribute('type', type);
                        this.textContent = type === 'password' ? '👁️' : '🙈';
                    });
                }
            }
            setupToggle('toggleNewPassword', 'NewPassword');
            setupToggle('toggleConfirmPassword', 'ConfirmPassword');

            // ----- TOAST HELPER (kept for consistency) -----
            function showToast(msg) {
                let toast = document.getElementById('dynamicToast');
                if (!toast) {
                    toast = document.createElement('div');
                    toast.id = 'dynamicToast';
                    toast.style.position = 'fixed';
                    toast.style.bottom = '20px';
                    toast.style.left = '50%';
                    toast.style.transform = 'translateX(-50%)';
                    toast.style.backgroundColor = 'var(--login-btn-bg)';
                    toast.style.color = 'white';
                    toast.style.padding = '8px 20px';
                    toast.style.borderRadius = '40px';
                    toast.style.fontSize = '13px';
                    toast.style.zIndex = '9999';
                    toast.style.fontWeight = '500';
                    toast.style.pointerEvents = 'none';
                    document.body.appendChild(toast);
                }
                toast.innerHTML = msg;
                toast.style.opacity = '1';
                setTimeout(function() { toast.style.opacity = '0'; }, 2000);
            }

            // expose copyText for any potential use (though info row removed)
            window.copyText = function(text) {
                navigator.clipboard.writeText(text).then(function() {
                    showToast("Copied: " + text);
                }).catch(function() {
                    alert("Press Ctrl+C to copy");
                });
            };

            // stubs for compatibility
            window.CheckCapsLock = function(e) { return true; };
            window.CheckAuth = function() {};
        })();
    </script>
</body>
</html>