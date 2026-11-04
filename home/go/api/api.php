<?php
header('Content-Type: text/html; charset=UTF-8');

include("/usr/local/goadmio/home/go/include/function/function.php");
include("/usr/local/goadmio/include/config/config.php");

$Name    = isset($_REQUEST['Name'])    ? trim($_REQUEST['Name'])    : '';
$APIKey  = isset($_REQUEST['APIKey'])  ? trim($_REQUEST['APIKey'])  : '';

$Domain = preg_replace("/^www\./", "", $_SERVER['SERVER_NAME']);
$Domain = preg_replace("/^go\./",  "", $Domain);

$Message     = '';
$MessageType = '';   // 'success' | 'error'
$Output      = '';   // command echo
$ShowForm    = true;
$Options     = [];

// Preload select options (only needed for the form, but cheap enough)
$Result = SQL("select * from API where Name!='' and Command!='' and Command!='all'");
foreach ($Result as $Row) {
    $Options[] = $Row['Name'];
}

if ($APIKey !== '') {

    $ShowForm = false;

    $Len = strlen($APIKey);
    if ($Len !== 16 && $Len !== 50) {
        $Message     = 'Invalid API Key. (' . $Len . ')';
        $MessageType = 'error';
    } else {

        $SSHPassword = '';
        $Result = SQL("select * from Config where ConfigID=1");
        foreach ($Result as $Row) {
            $SSHPassword = $Row['SSHPassword'];
        }

        $Success = 0;
        $Command = '';
        $Result = SQL("select * from API where Name=? and APIKey=?", [$Name, $APIKey]);
        foreach ($Result as $Row) {
            $Success = 1;
            $Command = $Row['Command'];
            $Command = str_ireplace("[Domain]", $Domain, $Command);
        }

        if ($Success !== 1) {
            $Message     = 'Invalid API Key.';
            $MessageType = 'error';
        } elseif ($Command !== '') {
            $Error = SSH("/usr/bin/sudo screen -d -m bash -c '$Command'", $SSHUsername, $SSHPassword);
            $Output      = $Command;
            $Message     = 'Command dispatched successfully.';
            $MessageType = 'success';
        } else {
            $Message     = 'No command configured for this API entry.';
            $MessageType = 'error';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex,nofollow">
<meta name="theme-color" content="#0a0a0a">
<title>API — GoAdmio</title>
<link rel="icon" href="../image/favicon.svg" type="image/svg+xml">

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

<style>
:root{
	--bg:#0a0a0a;
	--surface:#0f0f0f;
	--surface-2:#161616;
	--surface-3:#1d1d1d;
	--border:#242424;
	--border-2:#333;
	--text:#ededed;
	--muted:#9a9a9a;
	--muted-2:#6f6f6f;
	--accent:#FF6A00;
	--accent-hover:#ff8533;
	--accent-soft:rgba(255,106,0,.10);
	--danger:#ff4d4d;
	--danger-soft:rgba(255,77,77,.10);
	--success:#3ddc84;
	--success-soft:rgba(61,220,132,.10);

	--radius-sm:9px;
	--radius:12px;
	--radius-lg:20px;
	--radius-pill:999px;

	--ease:cubic-bezier(.4,0,.2,1);
	--shadow:0 18px 40px -20px rgba(0,0,0,.9);
}

*,*::before,*::after{box-sizing:border-box}
html{scroll-behavior:smooth;-webkit-text-size-adjust:100%}
html,body{margin:0;padding:0;min-height:100%}

body{
	background:var(--bg);
	color:var(--text);
	font-family:"Inter",ui-sans-serif,system-ui,-apple-system,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
	font-size:16px;
	line-height:1.55;
	-webkit-font-smoothing:antialiased;
	-moz-osx-font-smoothing:grayscale;
}

body::before{
	content:"";
	position:fixed;inset:0;z-index:0;pointer-events:none;
	opacity:.035;
	background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='160' height='160'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='2'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
}

a{color:inherit;text-decoration:none}
img{max-width:100%;display:block}
button,input,select{font:inherit}
::selection{background:var(--accent);color:#0a0a0a}

:focus-visible{
	outline:2px solid var(--accent);
	outline-offset:3px;
	border-radius:6px;
}

/* ---- Layout ---- */
.Outer{
	position:relative;
	z-index:1;
	display:flex;
	align-items:center;
	justify-content:center;
	min-height:100vh;
	padding:32px 20px;
	background:
		radial-gradient(900px 460px at 50% -12%, rgba(255,106,0,.10), transparent 68%),
		linear-gradient(180deg, rgba(10,10,10,.96) 0%, #0a0a0a 82%),
		url(../image/bg8.jpg) center/cover no-repeat;
}

.Outer::before{
	content:"";
	position:absolute;inset:0;
	pointer-events:none;
	background-image:
		linear-gradient(to right, rgba(255,255,255,.045) 1px, transparent 1px),
		linear-gradient(to bottom, rgba(255,255,255,.045) 1px, transparent 1px);
	background-size:64px 64px;
	-webkit-mask-image:radial-gradient(ellipse 68% 62% at 50% 38%, #000 15%, transparent 72%);
	mask-image:radial-gradient(ellipse 68% 62% at 50% 38%, #000 15%, transparent 72%);
}

.Inner{
	position:relative;
	z-index:2;
	width:100%;
	max-width:460px;
	padding:34px 30px 30px;
	background:linear-gradient(180deg,var(--surface-2),var(--surface));
	border:1px solid var(--border-2);
	border-radius:var(--radius-lg);
	box-shadow:var(--shadow);
	text-align:center;
}

/* ---- Brand ---- */
.Brand{
	display:inline-flex;
	align-items:center;
	justify-content:center;
	margin-bottom:22px;
}
.Brand img{height:32px;width:auto}

/* ---- Titles ---- */
h1{
	margin:0 0 6px;
	font-size:1.35rem;
	font-weight:800;
	letter-spacing:-.02em;
	line-height:1.2;
	color:#fff;
}
.Sub{
	margin:0 0 26px;
	color:var(--muted);
	font-size:.92rem;
	line-height:1.65;
}

/* ---- Form ---- */
form{padding:0;margin:0}

.Field{
	margin-bottom:14px;
	text-align:left;
}

.Field label{
	display:block;
	margin:0 0 6px;
	color:var(--muted);
	font-size:.8rem;
	font-weight:600;
	letter-spacing:.02em;
}

.Field input[type="text"],
.Field input[type="password"],
.Field select{
	width:100%;
	height:46px;
	padding:0 14px;
	background:var(--surface-3);
	border:1px solid var(--border-2);
	border-radius:var(--radius);
	color:var(--text);
	font-family:inherit;
	font-size:.95rem;
	transition:border-color .18s var(--ease),background .18s var(--ease),box-shadow .18s var(--ease);
}

.Field select{
	appearance:none;
	-webkit-appearance:none;
	-moz-appearance:none;
	padding-right:38px;
	background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%239a9a9a' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E");
	background-repeat:no-repeat;
	background-position:right 14px center;
	cursor:pointer;
}

.Field select option{
	background:var(--surface-3);
	color:var(--text);
}

.Field input::placeholder{color:var(--muted-2)}
.Field input:hover,
.Field select:hover{background:#202020}
.Field input:focus,
.Field select:focus{
	outline:none;
	border-color:var(--accent);
	background:#202020;
	box-shadow:0 0 0 3px var(--accent-soft);
}

/* ---- Buttons ---- */
.Btn{
	display:inline-flex;
	align-items:center;
	justify-content:center;
	gap:8px;
	width:100%;
	height:46px;
	padding:0 18px;
	border-radius:var(--radius-pill);
	border:1px solid transparent;
	background:transparent;
	font-size:.95rem;
	font-weight:700;
	line-height:1;
	cursor:pointer;
	white-space:nowrap;
	transition:background .18s var(--ease),color .18s var(--ease),
	           border-color .18s var(--ease),transform .18s var(--ease),
	           box-shadow .18s var(--ease);
}
.Btn:active{transform:translateY(1px)}

.Btn-primary{
	background:var(--accent);
	color:#0a0a0a;
	border-color:transparent;
	box-shadow:
		inset 0 1px 0 rgba(255,255,255,.35),
		0 8px 24px -10px rgba(255,106,0,.55);
}
.Btn-primary:hover{
	background:var(--accent-hover);
	box-shadow:
		inset 0 1px 0 rgba(255,255,255,.45),
		0 12px 32px -10px rgba(255,106,0,.7);
	transform:translateY(-1px);
}
.Btn-primary svg{transition:transform .2s var(--ease)}
.Btn-primary:hover svg{transform:translateX(3px)}

/* ---- Alerts ---- */
.Alert{
	margin:0 0 18px;
	padding:12px 14px;
	border-radius:var(--radius);
	font-size:.9rem;
	line-height:1.5;
	text-align:left;
	border:1px solid transparent;
}
.Alert-error{
	background:var(--danger-soft);
	border-color:rgba(255,77,77,.35);
	color:#ffb3b3;
}
.Alert-success{
	background:var(--success-soft);
	border-color:rgba(61,220,132,.35);
	color:#a8f0c6;
}

/* ---- Command output ---- */
.Output{
	margin:0 0 18px;
	padding:12px 14px;
	border-radius:var(--radius);
	background:#0c0c0c;
	border:1px solid var(--border-2);
	color:#d6d6d6;
	font-family:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,"Liberation Mono",monospace;
	font-size:.82rem;
	line-height:1.55;
	text-align:left;
	white-space:pre-wrap;
	word-break:break-word;
	overflow-x:auto;
}
.Output::before{
	content:"$";
	margin-right:8px;
	color:var(--accent);
	user-select:none;
}

/* ---- Footer note ---- */
.Note{
	margin-top:24px;
	padding-top:18px;
	border-top:1px solid var(--border);
	color:var(--muted-2);
	font-size:.8rem;
	line-height:1.5;
}

@media (max-width:420px){
	.Inner{padding:28px 22px 24px;border-radius:16px}
	h1{font-size:1.2rem}
}

@media (prefers-reduced-motion:reduce){
	*,*::before,*::after{
		transition-duration:.001ms !important;
		animation-duration:.001ms !important;
	}
}
</style>
</head>
<body>

<div class="Outer">
	<div class="Inner">

		<a href="../" class="Brand" aria-label="GoAdmio — home">
			<img src="../image/logo.svg" alt="GoAdmio" width="132" height="32">
		</a>

		<h1>API Dispatcher</h1>
		<p class="Sub">Select a command and send your API key.</p>

		<?php if ($Message !== ''): ?>
			<div class="Alert Alert-<?php echo htmlspecialchars($MessageType); ?>" role="alert">
				<?php echo htmlspecialchars($Message); ?>
			</div>
		<?php endif; ?>

		<?php if ($Output !== ''): ?>
			<pre class="Output"><?php echo htmlspecialchars($Output); ?></pre>
		<?php endif; ?>

		<?php if ($ShowForm): ?>
		<form method="POST" action="api.php" autocomplete="off">

			<div class="Field">
				<label for="apiName">Command</label>
				<select name="Name" id="apiName" required>
					<?php if (empty($Options)): ?>
						<option value="">— No commands available —</option>
					<?php else: ?>
						<?php foreach ($Options as $Opt): ?>
							<option value="<?php echo htmlspecialchars($Opt); ?>"
								<?php echo ($Opt === $Name) ? 'selected' : ''; ?>>
								<?php echo htmlspecialchars($Opt); ?>
							</option>
						<?php endforeach; ?>
					<?php endif; ?>
				</select>
			</div>

			<div class="Field">
				<label for="apiKey">API Key</label>
				<input
					type="password"
					name="APIKey"
					id="apiKey"
					placeholder="16 or 50 character API key"
					aria-label="API Key"
					required>
			</div>

			<button type="submit" class="Btn Btn-primary">
				<svg width="16" height="16" viewBox="0 0 24 24" fill="none"
				     stroke="currentColor" stroke-width="2.4" stroke-linecap="round"
				     stroke-linejoin="round" aria-hidden="true">
					<line x1="22" y1="2" x2="11" y2="13"/>
					<polygon points="22 2 15 22 11 13 2 9 22 2"/>
				</svg>
				Send
			</button>
		</form>
		<?php endif; ?>

		<p class="Note">API keys are validated per command. Contact your administrator if you need access.</p>

	</div>
</div>

</body>
</html>