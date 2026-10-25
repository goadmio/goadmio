<script>
function makeLeftAreaResizable() {
    const leftArea = document.querySelector('.left-area');
    const resizer = document.createElement('div');
    
    // Add resizer handle to left area
    resizer.className = 'resizer';
    leftArea.style.position = 'relative';
    leftArea.appendChild(resizer);
    
    let startX, startWidth;
    
    const mouseDownHandler = function(e) {
        startX = e.clientX;
        startWidth = parseInt(document.defaultView.getComputedStyle(leftArea).width, 10);
        
        // Add active class
        resizer.classList.add('active');
        
        // Add event listeners
        document.addEventListener('mousemove', mouseMoveHandler);
        document.addEventListener('mouseup', mouseUpHandler);
        
        // Prevent text selection while dragging
        document.body.style.cursor = 'col-resize';
        document.body.style.userSelect = 'none';
        e.preventDefault();
    };
    
    const mouseMoveHandler = function(e) {
        // Calculate new width
        const dx = e.clientX - startX;
        let newWidth = startWidth + dx;
        
        // Apply min/max constraints
        newWidth = Math.max(200, Math.min(500, newWidth));
        
        // Set new width
        leftArea.style.width = `${newWidth}px`;
        
        // Optional: Save to localStorage
        localStorage.setItem('leftAreaWidth', newWidth);
    };
    
    const mouseUpHandler = function() {
        // Remove active class
        resizer.classList.remove('active');
        
        // Remove event listeners
        document.removeEventListener('mousemove', mouseMoveHandler);
        document.removeEventListener('mouseup', mouseUpHandler);
        
        // Reset cursor
        document.body.style.cursor = '';
        document.body.style.userSelect = '';
    };
    
    resizer.addEventListener('mousedown', mouseDownHandler);
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function() {
    makeLeftAreaResizable();
    
    // Restore saved width if exists
    const savedWidth = localStorage.getItem('leftAreaWidth');
    if (savedWidth) {
        const leftArea = document.querySelector('.left-area');
        const width = Math.max(200, Math.min(500, parseInt(savedWidth, 10)));
        leftArea.style.width = `${width}px`;
    }
});
</script>

<?php

// Start output buffering
ob_start();

// Determine view text
$viewText = ($_SESSION['SessionView'] == "User") ? "Admin" : "User";
$switchViewText = "Switch to $viewText View";

?>
<div class='app-container'>
    <!-- Top Area - 60px height -->
    <div class='top-area'>

		<?php
		
		if ($ControlFile=="control.php")
		{
		
		echo "
		<div class='Slidbar'>
			<div class='slider-toggle' onclick='toggleSidebar()'>
				<svg class='slider-icon' xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' width='24' height='24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>
					<path d='M15 18l-6-6 6-6'/>
				</svg>
			</div>
		</div>
		";
		}

		$LoadPage="home.php";
		if ($_SESSION['SessionType']=="Website" and $_SESSION['SkipContact']!=1)
		{
			$Result = SQL("select * from Site where Domain='{$_SESSION['SessionDomain']}'");
			foreach ($Result as $Row)
			{
				if ($Row['Email']=="" or strlen($Row['Mobile'])<10)
				{
					$LoadPage="go.php";
				}
			}
			
		}



		?>
	
        <div class='logo-area'>
            <img src='image/logo.svg' alt='Logo'>
            <a href='javascript:Load("home.php")' class='logo-text'>GoAdmio</a>
        </div>
		
        
<?php
	require "menu.php";
?>
    </div>

    <!-- Main Content Area -->
    <div class='main-content'>
        <!-- Left Area - Contains control.php menu -->
        <div class='left-area'>
            <?php include "$ControlFile"; ?>
        </div>
        
        <!-- Right Area - Loads pages via AJAX -->
        <div class='right-area'>
            <div id='Load' class='DivLoad'>
                <?php
                // Load initial page
                if ($_REQUEST['Load'] != "") {
                    echo "<script>Load('{$_REQUEST['Load']}');</script>";
                } else {
                    echo "<script>Load('$LoadPage');</script>";
                }
                ?>
            </div>
        </div>
    </div>
</div>
<?php

// End output buffering and flush
ob_end_flush();
?>

