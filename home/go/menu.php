<div class='user-info'>
    <?php
    // Domain switcher functionality
    if ($_SESSION['SessionSwitchUsername'] != "") 
	{
		if ($_SESSION['SessionType']=="Root")
		{
        $Sql = "select * from Site where Trash=0 and UserID>=1";
		}
		else
		{
		$Sql = "select * from Site where Trash=0 and UserID='{$_SESSION['SessionUserID']}'";
		}
        $Result = SQL($Sql);
        foreach ($Result as $Row) 
		{
            $Account['Domain'][] = $Row['Domain'];
            $Account['Username'][] = $Row['Username'];
        }
        
        if (is_array($Account['Domain'])) 
		{
            array_multisort($Account['Domain'], SORT_ASC, SORT_STRING, $Account['Username'], SORT_ASC, SORT_STRING);
            ?>
            <div class='custom-select-wrapper'>
                <select name='SwitchUsername' id='SwitchUsername' class='custom-select' onchange='Switch()'>
                    <option value='<?php echo $_SESSION['SessionSwitchUsername']; ?>' selected><?php echo $_SESSION['SessionSwitchUsername']; ?></option>
                    <?php for ($E = 0; $E < count($Account['Domain']); $E++): ?>
                        <?php if ($Account['Username'][$E] == $_SESSION['SessionUsername']): ?>
                            <option value='<?php echo $Account['Username'][$E]; ?>' selected><?php echo $Account['Domain'][$E]; ?></option>
                        <?php else: ?>
                            <option value='<?php echo $Account['Username'][$E]; ?>'><?php echo $Account['Domain'][$E]; ?></option>
                        <?php endif; ?>
                    <?php endfor; ?>
                </select>
            </div>
            <?php
        }
    }
    ?>
    <div class='separator'></div>
    
    <!-- User Dropdown Menu - Circle Profile Icon (No Arrow) -->
    <div class='user-dropdown'>
        <div class='dropdown-trigger'>
            <svg class='dropdown-icon' xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' width='24' height='24' fill='none' stroke='#FF6A00' stroke-width='1.8' stroke-linecap='round' stroke-linejoin='round'>
                <path d='M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2' />
                <circle cx='12' cy='7' r='4' />
            </svg>
        </div>
        <div class='dropdown-menu'>
            <!-- Switch View - Most frequent action at TOP -->
            <div class='dropdown-item' onclick="window.location.href='index.php?View=<?php echo $viewText; ?>'">
                <svg class='dropdown-item-icon' xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' width='20' height='20' fill='none' stroke='#FF6A00' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>
                    <path d='M12 4v16M4 12l8-8 8 8'/>
                </svg>
                <span><?php echo $switchViewText; ?></span>
            </div>
            
            <div class='dropdown-divider'></div>
            
            <!-- Admin Tools - Only for Root Session Type -->
            <?php if ($_SESSION['SessionUsername'] == "root"): ?>
            <!-- Change Log -->
            <div class='dropdown-item' onclick="Load('change-log.php')">
                <svg class='dropdown-item-icon' xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' width='20' height='20' fill='none' stroke='#FF6A00' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>
                    <path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/>
                    <polyline points='14 2 14 8 20 8'/>
                    <line x1='16' y1='13' x2='8' y2='13'/>
                    <line x1='16' y1='17' x2='8' y2='17'/>
                    <polyline points='10 9 9 9 8 9'/>
                </svg>
                <span>Change Log</span>
            </div>
            
            <!-- Commands -->
            <div class='dropdown-item' onclick="window.open('https://www.goadmio.com/command.php', '_blank')">
                <svg class='dropdown-item-icon' xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' width='20' height='20' fill='none' stroke='#FF6A00' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>
                    <path d='M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6'/>
                    <polyline points='15 3 21 3 21 9'/>
                    <line x1='10' y1='14' x2='21' y2='3'/>
                </svg>
                <span>Commands</span>
            </div>
            
            <!-- Upgrade to Latest Version -->
            <div class='dropdown-item' onclick="Load('upgrade.php')">
                <svg class='dropdown-item-icon' xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' width='20' height='20' fill='none' stroke='#FF6A00' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>
                    <path d='M12 8v8m-4-4l4 4 4-4'/>
                    <path d='M5 12a7 7 0 1 0 14 0 7 7 0 1 0-14 0z'/>
                </svg>
                <span><?php echo $LNG['UpgradeToLatestVersion']; ?></span>
            </div>
            
            <div class='dropdown-divider'></div>
            <?php endif; ?>
            
            <!-- Contact Information - Only for Website Session Type -->
            <?php if ($_SESSION['SessionType'] == "Website" and $_SESSION['SessionUsername'] != "root"): ?>
            <div class='dropdown-item' onclick="Load('go.php'); addNewItem('ContactInformation');">
                <svg class='dropdown-item-icon' xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' width='20' height='20' fill='none' stroke='#FF6A00' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>
                    <path d='M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z'/>
                    <circle cx='12' cy='10' r='3'/>
                </svg>
                <span><?php echo $LNG['ContactInformation']; ?></span>
            </div>
            <div class='dropdown-divider'></div>
            <?php endif; ?>
            
            <!-- Logout - Always at BOTTOM -->
            <div class='dropdown-item' onclick="Load('logout.php')">
                <svg class='dropdown-item-icon' xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' width='20' height='20' fill='none' stroke='#FF6A00' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>
                    <path d='M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4'/>
                    <polyline points='16 17 21 12 16 7'/>
                    <line x1='21' y1='12' x2='9' y2='12'/>
                </svg>
                <span>Logout</span>
            </div>
        </div>
    </div>
</div>