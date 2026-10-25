<?php
// Complete Login Page - No <body> or <head> tags, all inputs/select/button rounded 60px
// Logo: 50x50, Footer: Version 10.1.1 | Hostname: smtp.crmrealty.net | Server IP: 65.109.28.61
// No labels, placeholders only. Hidden SessionTheme sends dark/light value.

// --- Assume existing variables or provide fallbacks ---
$CurrentFileName = $CurrentFileName ?? '';
$_REQUEST['TargetFrame'] = $_REQUEST['TargetFrame'] ?? '';
$CookiesUsername = $CookiesUsername ?? '';
$Domain = $Domain ?? '';
$DemoUsername = $DemoUsername ?? '';
$CookiesPassword = $CookiesPassword ?? '';

// Ensure $LNG array has basic keys
if (!isset($LNG['Username'])) $LNG['Username'] = 'Username';
if (!isset($LNG['Password'])) $LNG['Password'] = 'Password';
if (!isset($LNG['Language'])) $LNG['Language'] = 'Language';
if (!isset($LNG['Login'])) $LNG['Login'] = 'Login';
if (!isset($LNG['Version'])) $LNG['Version'] = 'Version';
if (!isset($LNG['Hostname'])) $LNG['Hostname'] = 'Hostname';

// --- Hostname detection (original logic preserved) ---
$Hostname = @file_get_contents("/etc/hostname");
$Hostname = trim($Hostname);
if ($CookiesUsername == "" && (function_exists('StartsWith') && StartsWith(getcwd(), "/usr/local/goadmio") && !filter_var($Domain, FILTER_VALIDATE_IP))) {
    $CookiesUsername = $Domain;
}

if ($Hostname == $CookiesUsername) {
    $CookiesUsername = "root";
}

if ($CookiesUsername == "" && $IPv4 == $_SERVER['HTTP_HOST']) {
    $CookiesUsername = "root";
}
if (stristr($CookiesUsername, "go.")) {
    $CookiesUsername = preg_replace('/go./', "", $CookiesUsername, 1);
}
if (!empty($DemoUsername)) {
    $CookiesUsername = $DemoUsername;
    $String = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcefghijklmnopqrstuvwxyz";
    $CookiesPassword = substr(str_shuffle($String), 0, 8);
} else {
    $CookiesPassword = isset($CookiesPassword) ? $CookiesPassword : '';
}

// --- Language array building ---
$LANG = array('Code' => array(), 'Name' => array());
$langList = [
    'af'=>'Afrikaans','sq'=>'Albanian','ar'=>'Arabic','hy'=>'Armenian','az'=>'Azerbaijani',
    'eu'=>'Basque','be'=>'Belarusian','bn'=>'Bengali','bs'=>'Bosnian','bg'=>'Bulgarian',
    'ca'=>'Catalan','zh-cn'=>'ChineseSimplified','zh-tw'=>'ChineseTraditional','hr'=>'Croatian',
    'cs'=>'Czech','da'=>'Danish','nl'=>'Dutch','en'=>'English','et'=>'Estonian','tl'=>'Filipino',
    'fi'=>'Finnish','fr'=>'French','gl'=>'Galician','ka'=>'Georgian','de'=>'German','el'=>'Greek',
    'gu'=>'Gujarati','ht'=>'HaitianCreole','ha'=>'Hausa','iw'=>'Hebrew','hi'=>'Hindi','hu'=>'Hungarian',
    'is'=>'Icelandic','id'=>'Indonesian','ga'=>'Irish','it'=>'Italian','ja'=>'Japanese','jw'=>'Javanese',
    'kn'=>'Kannada','kk'=>'Kazakh','km'=>'Khmer','ko'=>'Korean','ky'=>'Kyrgyz','lo'=>'Lao','lv'=>'Latvian',
    'lt'=>'Lithuanian','mk'=>'Macedonian','ms'=>'Malay','ml'=>'Malayalam','mt'=>'Maltese','mi'=>'Maori',
    'mr'=>'Marathi','mn'=>'Mongolian','my'=>'MyanmarBurmese','ne'=>'Nepali','no'=>'Norwegian',
    'fa'=>'Persian','pl'=>'Polish','pt'=>'Portuguese','pa'=>'Punjabi','ro'=>'Romanian','ru'=>'Russian',
    'sr'=>'Serbian','sk'=>'Slovak','sl'=>'Slovenian','es'=>'Spanish','sw'=>'Swahili','sv'=>'Swedish',
    'ta'=>'Tamil','te'=>'Telugu','th'=>'Thai','tr'=>'Turkish','uk'=>'Ukrainian','ur'=>'Urdu',
    'uz'=>'Uzbek','vi'=>'Vietnamese','cy'=>'Welsh','xh'=>'Xhosa','yo'=>'Yoruba','zu'=>'Zulu'
];
foreach ($langList as $code => $name) {
    $LANG['Code'][] = $code;
    $LANG['Name'][] = isset($LNG[$name]) ? $LNG[$name] : $name;
}
array_multisort($LANG['Name'], SORT_ASC, SORT_STRING, $LANG['Code'], SORT_NUMERIC, SORT_DESC);
?>
<style>
    /* RESET to avoid horizontal scroll */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    body {
        margin: 0;
        overflow-x: hidden;
        background: var(--login-bg-page);
    }
    /* LIGHT MODE (default) */
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
        font-family: system-ui, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
        --toggle-bg-off: #cbd5e1;
        --toggle-bg-on: #FF6A00;
        --toggle-knob: #ffffff;
        --login-copy-hover: #eef2ff;
    }

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
    }
    .go-login-wrapper {
        background-color: var(--login-bg-page);
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
        padding: 1rem 1rem 0.5rem 1rem;
        width: 100%;
        max-width: 100vw;
        overflow-x: hidden;
    }
    .login-container {
        max-width: 400px;
        width: 100%;
        background: var(--login-card-bg);
        border-radius: 28px;
        box-shadow: 0 20px 35px -12px rgba(0,0,0,0.1);
        border: 1px solid var(--login-card-border);
        overflow: hidden;
        transition: all 0.2s;
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
    .input-group {
        margin-bottom: 1.5rem;
    }
    /* All inputs, selects, and login button rounded 60px */
    .input-group input, 
    .input-group select,
    .login-btn {
        border-radius: 60px !important;
    }
    .input-group input, .input-group select {
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
    /* Custom white arrow for select (still rounded) */
    .input-group select {
        appearance: none;
        -webkit-appearance: none;
        -moz-appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 14px center;
        background-size: 16px;
        padding-right: 40px;
        filter: drop-shadow(0 0 1px rgba(0,0,0,0.5));
    }
    .input-group select:focus,
    .input-group input:focus {
        border-color: var(--login-input-focus);
        box-shadow: 0 0 0 3px rgba(10,132,255,0.2);
    }
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
        border-radius: 60px; /* keep consistent but not necessary */
    }
    .toggle-password:hover {
        opacity: 1;
        color: var(--login-input-focus);
    }
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
    input:checked + .slider {
        background-color: var(--toggle-bg-on);
    }
    input:checked + .slider:before {
        transform: translateX(24px);
    }
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
    .info-row-below {
        margin-top: 0.5rem;
        text-align: center;
        font-size: 0.75rem;
        color: var(--login-text-secondary);
        display: flex;
        gap: 1rem;
        justify-content: center;
        flex-wrap: wrap;
        max-width: 100%;
        padding: 0 0.5rem 0.5rem 0.5rem;
    }
    .info-row-below span,a {
        cursor: pointer;
        padding: 2px 4px;
        border-radius: 12px;
        transition: background 0.1s;
    }
    .info-row-below span:hover {
        background: var(--login-copy-hover);
    }
    .google-auth-row {
        display: none;
    }
    .google-auth-row.show {
        display: block;
    }
    @media (max-width: 550px) {
        .login-form { padding: 1.5rem; }
        .info-row-below { flex-direction: column; gap: 0.3rem; margin-top: 0.25rem; }
        .login-logo { width: 50px; height: 50px; }
        .input-group select {
            background-position: right 12px center;
            background-size: 14px;
            padding-right: 36px;
        }
    }
</style>

<div class="go-login-wrapper" id="goLoginWrapper">
    <div class="login-container">
        <div class="login-header">
            <img src="image/logo.svg" alt="Logo" class="login-logo">
        </div>

        <div class="login-form">
            <form name="Form" id="Form" method="POST" onsubmit="return Login();" autocomplete="off" action="<?php echo htmlspecialchars($CurrentFileName); ?>">
                <input type="hidden" name="TargetFrame" id="TargetFrame" value="<?php echo htmlspecialchars($_REQUEST['TargetFrame']); ?>">
                <input type="hidden" name="SessionTheme" id="SessionTheme" value="light">

                <div class="input-group">
                    <input type="text" name="Username" id="Username" placeholder="<?php echo htmlspecialchars($LNG['Username']); ?>" value="<?php echo htmlspecialchars($CookiesUsername); ?>" required title="Please Enter Username" onkeyup="CheckAuth(this.value)" onblur="CheckAuth(this.value)" autocomplete="off">
                </div>

                <div class="input-group">
                    <div class="password-wrapper">
                        <input type="password" name="Password" id="Password" placeholder="<?php echo htmlspecialchars($LNG['Password']); ?>" required title="Please Enter Password" value="<?php echo htmlspecialchars($CookiesPassword); ?>" onKeyPress="return CheckCapsLock(event)" autocomplete="off">
                        <button type="button" class="toggle-password" id="togglePasswordBtn" aria-label="Show/Hide Password">👁️</button>
                    </div>
                </div>

                <div class="input-group google-auth-row" id="GoogleAuthRow">
                    <input type="text" name="Code" id="Code" placeholder="Google Auth Code">
                </div>

                <div class="input-group">
                    <select name="SessionLng" id="SessionLng">
                        <option value="" disabled selected><?php echo htmlspecialchars($LNG['Language']); ?></option>
                        <?php
                        for ($E = 0; $E < count($LANG['Code']); $E++) {
                            $selected = ($LANG['Code'][$E] == "en") ? 'selected' : '';
                            echo "<option value='" . htmlspecialchars($LANG['Code'][$E]) . "' $selected>" . htmlspecialchars($LANG['Name'][$E]) . "</option>";
                        }
                        ?>
                    </select>
                </div>

                <div class="toggle-group">
                    <label for="darkModeToggle">Dark Mode</label>
                    <label class="toggle-switch">
                        <input type="checkbox" id="darkModeToggle">
                        <span class="slider"></span>
                    </label>
                </div>

                <button type="submit" class="login-btn"><?php echo htmlspecialchars($LNG['Login']); ?> →</button>
                <div id="DivLogin" class="auth-message"></div>
            </form>
        </div>
    </div>

<?php
	echo "
    <div class=\"info-row-below\">
        <span onclick=\"copyText('$Version')\">{$LNG['Version']}: $Version</span>
        <span onclick=\"copyText('$Hostname')\">{$LNG['Hostname']}: $Hostname</span>
        <span onclick=\"copyText('$IPv4')\">{$LNG['IPv4']}: $IPv4</span>
		<a href='forgot.php'>I forgot my password</a>
    </div>
	";
?>
	
</div>

<script type="text/javascript">
// Dark mode toggle: follows system preference, saves state, updates hidden input
(function() {
    const wrapper = document.getElementById('goLoginWrapper');
    const darkModeToggle = document.getElementById('darkModeToggle');
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
        if (darkModeToggle) darkModeToggle.checked = enabled;
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

    if (darkModeToggle) {
        darkModeToggle.addEventListener('change', function(e) {
            setDarkMode(e.target.checked);
        });
    }

    if (window.matchMedia) {
        const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
        const handleChange = (e) => {
            if (localStorage.getItem(STORAGE_KEY) === null) {
                setDarkMode(e.matches);
            }
        };
        mediaQuery.addEventListener('change', handleChange);
    }
})();

// Show/hide password toggle
(function() {
    const toggleBtn = document.getElementById('togglePasswordBtn');
    const passwordInput = document.getElementById('Password');
    if (toggleBtn && passwordInput) {
        toggleBtn.addEventListener('click', function() {
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            this.textContent = type === 'password' ? '👁️' : '🙈';
        });
    }
})();

// Copy text helper
function copyText(text) {
    navigator.clipboard.writeText(text).then(() => {
        showToast("Copied: " + text);
    }).catch(() => alert("Press Ctrl+C to copy"));
}

// AJAX login
let httpRequest = null;
function Ajax() {
    try { return new XMLHttpRequest(); } catch(e) {}
    try { return new ActiveXObject("Msxml2.XMLHTTP"); } catch(e) {}
    try { return new ActiveXObject("Microsoft.XMLHTTP"); } catch(e) {}
    return null;
}

function Login() {
    const divLogin = document.getElementById('DivLogin');
    if (divLogin) divLogin.innerHTML = 'Authenticating...';
    const form = document.forms['Form'];
    if (!form) return false;
    const formData = new FormData(form);
    const urlParams = new URLSearchParams(formData).toString();
    httpRequest = Ajax();
    if (!httpRequest) return false;
    httpRequest.abort();
    httpRequest.open("POST", "ajax/login.php", true);
    httpRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    httpRequest.onreadystatechange = HandelLogin;
    httpRequest.send(urlParams);
    return false;
}

function HandelLogin() {
    if (httpRequest.readyState == 4) {
        let response = httpRequest.responseText.trim();
        const divLogin = document.getElementById('DivLogin');
        if (!divLogin) return;
        if (response == 'Success') {
            divLogin.innerHTML = '<span style="color:#10b981;">Login successful redirecting...</span>';
            setTimeout(function(){ window.location = 'index.php'; }, 2000);
        } else if (response.match('invalid') || response.match('Invalid')) {
            divLogin.innerHTML = '<span style="color: var(--login-alert);">' + response + '</span>';
        } else {
            divLogin.innerHTML = '<span>' + response + '</span>';
        }
        setTimeout(function(){ if(divLogin) divLogin.innerHTML = ''; }, 5000);
    }
}

function CheckCapsLock(e) {
    const capsWarning = document.getElementById('DivLogin');
    if (!capsWarning) return true;
    const keyCode = e.which ? e.which : e.keyCode;
    if (keyCode >= 65 && keyCode <= 90) {
        if ((e.shiftKey && keyCode >= 65 && keyCode <= 90) || (!e.shiftKey && keyCode >= 97 && keyCode <= 122)) {
            capsWarning.innerHTML = '';
        } else if ((!e.shiftKey && keyCode >= 65 && keyCode <= 90) || (e.shiftKey && keyCode >= 97 && keyCode <= 122)) {
            capsWarning.innerHTML = 'Caps Lock is ON';
        } else {
            capsWarning.innerHTML = '';
        }
    }
    return true;
}

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
    setTimeout(() => toast.style.opacity = '0', 2000);
}

function CheckAuth(username) {
    const googleRow = document.getElementById('GoogleAuthRow');
    if (googleRow && username === 'google2fa') googleRow.classList.add('show');
    else if (googleRow) googleRow.classList.remove('show');
}

window.CheckAuth = CheckAuth;
window.CheckCapsLock = CheckCapsLock;
window.copyText = copyText;
</script>