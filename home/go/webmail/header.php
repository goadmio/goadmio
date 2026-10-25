<!-- Header -->
<div class="header-card">
	<div class="logo-area">
		<a href="index.php">
			<img src="logo.svg">
		</a>
	</div>
	<div class="user-area">
		<span>Welcome <?php echo $_SESSION['SessionEmail']; ?></span>
		
		<?php if (basename($_SERVER['SCRIPT_NAME']) === 'mail.php'): ?>
			<a href="index.php"> Home</a>
		<?php endif; ?>

		<a href="index.php?ChangePassword=1"> Change Password</a>

		<?php if ($Admin == 1): ?>
			<a href="mail.php"> Email Accounts</a>
		<?php endif; ?>
		<a href="index.php?Logout=1" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
	</div>
</div>
