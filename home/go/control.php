<?php

$IconControlID=0;

if ($_SESSION['SessionType']=="Root")
{
    $ServiceSql="Service!=4";
}
elseif ($_SESSION['SessionType']=="Reseller")
{
    $ServiceSql="Service in (2,3)";
}
elseif ($_SESSION['SessionType']=="Website")
{
    $ServiceSql="Service>=3";
}

// Start the left area structure without search inside nav
echo "
<div class='left-area-inner'>

    <div class='Search'>
        <input type='text' name='MenuSearch' id='MenuSearch' placeholder='Search menu...' autocomplete='off' accesskey='f'>
    </div>
	

    <div class='nav-wrapper'>
        <nav class='DivControl' aria-label='Control Panel Navigation'>
";

$Sub=0;
$SubTimes=0;
$MenuItemsOpen = false;
$SectionCounter = 0;

if ($IconControlID=="" or $IconControlID=="0")
{
    $Sql = "select * from Control where $ServiceSql and Type!=0 ORDER BY Sort";
}
else
{
    $Sql = "select * from Control where $ServiceSql and Type!=0 and ControlID in ($IconControlID)  ORDER BY Sort";
}
$Result = SQL($Sql);
foreach ($Result as $Row)
{
    $SubControl=$Row['SubControl'];
    $ControlID=$Row['ControlID'];
    $ControlTarget=$Row['ControlTarget'];
    
    if ($SubControl==1)
    {
        $Sub++;        
        if ($Sub==1)
        {            
            $CollapsePlusNo=10000+$Sub+$SubTimes;
            $SubPlusCode="<img id=CollapsePlusImage$CollapsePlusNo onclick=\"Plus('CollapsePlus$CollapsePlusNo',$CollapsePlusNo,CollapsePlusImage$CollapsePlusNo)\" src='media/image/admin/$Theme/bulet-plus.gif' style='cursor:pointer' > ";
        }
        else
        {
            $SubPlusCode="";
        }
    }
    else
    {
        $Sub=0;
        $SubTimes++;
    }
    
    $ControlText=$LNG[$Row['Control']];
    $ControlFind = $ControlText . " " . $LNG[$Row['ControlMenu']] . " " . $Row['SubFiles'];
    $ControlFind = trim(preg_replace('/\s+/', ' ', $ControlFind));
    
    $ControlMenuText=$LNG[$Row['ControlMenu']];
    $ControlMenuImage=$Row['ControlMenuImage'];
    $ControlMenuImage=str_replace(".png",".svg",$ControlMenuImage);
    
    $ControlUrl=$Row['ControlUrl'];
    $ControlTarget=$Row['ControlTarget'];
    
    $ControlUrl=str_replace("[T]",time(),$ControlUrl);
    $ControlUrl=str_replace("[ControlID]",$ControlID,$ControlUrl);
    
    $ControlUrlArray=explode("?",$ControlUrl);
    $ControlFile=$ControlUrlArray[0];
    
    if ($LastControlMenu != $ControlMenuText)
    {
        // Close previous menu section if open
        if ($MenuItemsOpen) {
            echo "              </ul>\n";
            echo "          </div>\n";
            $MenuItemsOpen = false;
        }
        
        $ControlTitle="";
        $MenuControlFind="";
        
        $ResultQ = SQL("SELECT * FROM Control where ControlMenu='{$Row['ControlMenu']}' ORDER BY Sort");
        foreach ($ResultQ as $RowQ)
        {
            $BControlFind = $LNG[$RowQ['Control']] . " " . $LNG[$RowQ['ControlMenu']] . " " . $RowQ['SubFiles'];
            $BControlFind = trim(preg_replace('/\s+/', ' ', $BControlFind));
            $MenuControlFind .= "-" . $BControlFind . "-";
        }
        
        if ($_SESSION['SessionTheme']=="light")
        {
            $ColorMenuB="#E0E0E0";
        }
        else
        {
            $ColorMenuB="#23232E";
        }
        
        $CollapseControlMenu = preg_replace('/[^a-zA-Z0-9]/', '', $ControlMenuText);
        $CNO++;
        $SectionCounter++;
        
        // Start new menu section with arrow on LEFT side
        echo "
        <div class='MenuSection' id='MenuSection_$SectionCounter' data-menu-section='{$CollapseControlMenu}'>
            <h2 class='MenuB' data-divid='Find' data-find='$MenuControlFind' data-menu-id='menu_$SectionCounter'>
                <span class='menu-arrow'>▶</span>
                <span class='menu-title'>$ControlMenuText</span>
            </h2>
            <ul class='MenuItems' id='MenuItems_$SectionCounter' role='list'>
        ";
        $MenuItemsOpen = true;
    }
        
    if (stristr("|{$_SESSION['SessionControlFile']}|","|$ControlFile|") or $_SESSION['SessionControlFile']=="")
    {  
        if ($ControlText != "")
        {
            if ($ControlTarget == "")
            {
                echo "                  <li role='listitem' class='MenuItem'>
                        <div 
                            data-divid='Find'
                            data-name='Collapse{$CollapseControlMenu}'
                            id='C{$ControlID}' 
                            data-find='$ControlFind'
                            class='Menu' 
                            onclick='Load(\"$ControlUrl\",\"$ControlID\")'>
                            $ControlText
                        </div>
                    </li>\n";
            }
            else
            {
                echo "                  <li role='listitem' class='MenuItem'>
                        <div 
                            data-divid='Find'
                            data-name='Collapse{$CollapseControlMenu}'
                            id='C{$ControlID}' 
                            data-find='$ControlFind'
                            class='Menu' 
                            onclick=\"window.open('$ControlUrl')\">
                            $ControlText
                        </div>
                    </li>\n";
            }
        }
    }
    
    $LastControlMenu = $ControlMenuText;
}

// Close the last menu section if open
if ($MenuItemsOpen) {
    echo "              </ul>\n";
    echo "          </div>\n";
}

echo "
        </nav>
    </div>
</div>
";

?>

<script>
// Sidebar toggle functionality - OPTIMIZED for centered arrow (40px collapsed width)
var isSidebarCollapsed = false;
var collapsedWidth = '40px'; // Best value for perfectly centered arrow

function toggleSidebar() {
    var leftAreaInner = document.querySelector('.left-area-inner');
    var leftArea = document.querySelector('.left-area');
    var rightArea = document.querySelector('.right-area');
    var mainContent = document.querySelector('.main-content');
    var sliderToggle = document.querySelector('.slider-toggle');
    var sliderIcon = document.querySelector('.slider-icon');
    var sliderText = document.querySelector('.slider-text');
    
    if (!isSidebarCollapsed) {
        // Collapse sidebar with optimal width for centered arrow
        if (leftAreaInner) {
            leftAreaInner.style.width = collapsedWidth;
            leftAreaInner.style.minWidth = collapsedWidth;
        }
        if (leftArea) {
            leftArea.style.width = collapsedWidth;
            leftArea.style.minWidth = collapsedWidth;
        }
		
        // Add collapsed class to slider toggle for CSS handling
        if (sliderToggle) {
            sliderToggle.classList.add('collapsed');
        }
        
        // Use CSS class instead of inline style for rotation
        if (sliderIcon) {
            sliderIcon.style.transform = '';
        }
        
        if (sliderText) {
            sliderText.textContent = 'Expand Menu';
        }
        isSidebarCollapsed = true;
        
        // Add a CSS class to the body
        document.body.classList.add('sidebar-collapsed');
        
        // Hide menu text for all items - preserve padding to prevent jumping
        var menuItems = document.querySelectorAll('.Menu, .Menu.active, .MenuItem .Menu, div.Menu');
        menuItems.forEach(function(item) {
            // Store original padding to restore later
            if (!item.getAttribute('data-original-padding')) {
                item.setAttribute('data-original-padding', item.style.padding || '8px 16px 8px 32px');
            }
            item.style.fontSize = '0';
            item.style.padding = '8px 0';
            item.style.textAlign = 'center';
            item.style.color = 'transparent';
            item.style.lineHeight = '0';
            
            // Hide all child spans but keep icons visible
            var spans = item.querySelectorAll('span');
            spans.forEach(function(span) {
                span.style.display = 'none';
            });
        });
        
        // Hide menu titles
        var menuTitles = document.querySelectorAll('.menu-title');
        menuTitles.forEach(function(title) {
            title.style.display = 'none';
        });
        
        // Center arrows
        var menuArrows = document.querySelectorAll('.menu-arrow');
        menuArrows.forEach(function(arrow) {
            arrow.style.margin = '0 auto';
        });
        
        // Hide search when collapsed
        var searchDiv = document.querySelector('.Search');
        if (searchDiv) searchDiv.style.display = 'none';
        
    } else {
        // Expand sidebar
        if (leftAreaInner) {
            leftAreaInner.style.width = '';
            leftAreaInner.style.minWidth = '';
        }
        if (leftArea) {
            leftArea.style.width = '';
            leftArea.style.minWidth = '';
        }

        
        // Remove collapsed class from slider toggle
        if (sliderToggle) {
            sliderToggle.classList.remove('collapsed');
        }
        
        // Clear inline styles
        if (sliderIcon) {
            sliderIcon.style.transform = '';
        }
        
        if (sliderText) {
            sliderText.textContent = 'Collapse Menu';
        }
        isSidebarCollapsed = false;
        
        // Remove body class
        document.body.classList.remove('sidebar-collapsed');
        
        // Restore ALL menu text
        var menuItems = document.querySelectorAll('.Menu, .Menu.active, .MenuItem .Menu, div.Menu');
        menuItems.forEach(function(item) {
            item.style.fontSize = '';
            item.style.padding = '';
            item.style.textAlign = '';
            item.style.color = '';
            item.style.lineHeight = '';
            item.style.textIndent = '';
            
            // Restore all spans
            var spans = item.querySelectorAll('span');
            spans.forEach(function(span) {
                span.style.display = '';
            });
        });
        
        var menuTitles = document.querySelectorAll('.menu-title');
        menuTitles.forEach(function(title) {
            title.style.display = '';
        });
        
        var menuArrows = document.querySelectorAll('.menu-arrow');
        menuArrows.forEach(function(arrow) {
            arrow.style.margin = '';
        });
        
        // Show search when expanded
        var searchDiv = document.querySelector('.Search');
        if (searchDiv) searchDiv.style.display = '';
    }
    
    // Save state to localStorage
    localStorage.setItem('sidebarCollapsed', isSidebarCollapsed);
    localStorage.setItem('sidebarWidth', collapsedWidth);
}

// Restore sidebar state on page load
document.addEventListener('DOMContentLoaded', function() {
    var savedState = localStorage.getItem('sidebarCollapsed');
    var savedWidth = localStorage.getItem('sidebarWidth');
    
    // Restore saved width if exists
    if (savedWidth && (savedWidth === '40px' || savedWidth === '45px' || savedWidth === '50px')) {
        collapsedWidth = savedWidth;
    }
    
    if (savedState === 'true') {
        toggleSidebar();
    }
    
    // Menu toggle functionality for arrows
    var menuHeaders = document.querySelectorAll('.MenuB');
    
    menuHeaders.forEach(function(header, index) {
        var menuItems = header.nextElementSibling;
        var arrow = header.querySelector('.menu-arrow');
        
        if (menuItems && menuItems.classList && menuItems.classList.contains('MenuItems')) {
            header.style.cursor = 'pointer';
            header.addEventListener('click', function(e) {
                e.stopPropagation();
                toggleMenu(this);
            });
            
            // Check if menu items should be open by default
            var isOpen = localStorage.getItem('menu_' + index);
            if (isOpen === null || isOpen === 'true') {
                menuItems.classList.add('open');
                menuItems.classList.remove('closed');
                if (arrow) {
                    arrow.classList.add('rotated');
                }
            } else {
                menuItems.classList.add('closed');
                menuItems.classList.remove('open');
                if (arrow) {
                    arrow.classList.remove('rotated');
                }
            }
        }
    });
    
    // Restore active menu item from localStorage
    var savedActiveMenu = localStorage.getItem('activeMenuId');
    if (savedActiveMenu) {
        var activeElement = document.getElementById(savedActiveMenu);
        if (activeElement) {
            setActiveMenuItem(null, activeElement);
        }
    }
});

// Toggle menu function with localStorage persistence
function toggleMenu(headerElement) {
    var menuItems = headerElement.nextElementSibling;
    var arrow = headerElement.querySelector('.menu-arrow');
    var menuHeaders = document.querySelectorAll('.MenuB');
    var index = Array.from(menuHeaders).indexOf(headerElement);
    
    if (!menuItems) return;
    
    if (menuItems.classList.contains('closed')) {
        menuItems.classList.remove('closed');
        menuItems.classList.add('open');
        if (arrow) arrow.classList.add('rotated');
        localStorage.setItem('menu_' + index, 'true');
    } else {
        menuItems.classList.add('closed');
        menuItems.classList.remove('open');
        if (arrow) arrow.classList.remove('rotated');
        localStorage.setItem('menu_' + index, 'false');
    }
}

// Search functionality - IMPROVED
document.addEventListener('DOMContentLoaded', function() {
    var searchInput = document.getElementById('MenuSearch');
    if (searchInput) {
        searchInput.addEventListener('keyup', function() {
            var searchTerm = this.value.toLowerCase().trim();
            var menuSections = document.querySelectorAll('.MenuSection');
            var noResultsMsg = document.getElementById('noResultsMsg');
            var foundAny = false;
            
            // If search is empty, show everything and return
            if (searchTerm === '') {
                menuSections.forEach(function(section) {
                    section.style.display = '';
                    var menuItems = section.querySelectorAll('.MenuItem');
                    menuItems.forEach(function(item) {
                        item.style.display = '';
                    });
                });
                if (noResultsMsg) noResultsMsg.style.display = 'none';
                return;
            }
            
            menuSections.forEach(function(section) {
                var menuB = section.querySelector('.MenuB');
                var menuItems = section.querySelectorAll('.Menu');
                var sectionVisible = false;
                
                // Check section header
                if (menuB) {
                    var menuBText = menuB.innerText.toLowerCase();
                    if (menuBText.indexOf(searchTerm) > -1) {
                        sectionVisible = true;
                        foundAny = true;
                        var parentMenuItems = section.querySelector('.MenuItems');
                        if (parentMenuItems) {
                            parentMenuItems.classList.add('open');
                            parentMenuItems.classList.remove('closed');
                            var arrow = menuB.querySelector('.menu-arrow');
                            if (arrow) arrow.classList.add('rotated');
                        }
                    }
                }
                
                // Check menu items
                menuItems.forEach(function(item) {
                    var itemText = item.innerText.toLowerCase();
                    var listItem = item.closest('.MenuItem');
                    
                    if (itemText.indexOf(searchTerm) > -1) {
                        if (listItem) listItem.style.display = '';
                        sectionVisible = true;
                        foundAny = true;
                        // Expand parent section
                        var parentMenuItems = section.querySelector('.MenuItems');
                        if (parentMenuItems) {
                            parentMenuItems.classList.add('open');
                            parentMenuItems.classList.remove('closed');
                            var arrow = menuB.querySelector('.menu-arrow');
                            if (arrow) arrow.classList.add('rotated');
                        }
                    } else {
                        if (listItem) listItem.style.display = 'none';
                    }
                });
                
                // Show/hide section based on visibility
                section.style.display = sectionVisible ? '' : 'none';
            });
            
            // Show or update no results message
            if (!foundAny) {
                if (!noResultsMsg) {
                    var navWrapper = document.querySelector('.nav-wrapper');
                    if (navWrapper) {
                        var msgDiv = document.createElement('div');
                        msgDiv.id = 'noResultsMsg';
                        msgDiv.className = 'no-results-msg';
                        msgDiv.innerHTML = 'No menu items found for "' + searchTerm + '"';
                        navWrapper.appendChild(msgDiv);
                    }
                } else {
                    noResultsMsg.style.display = 'block';
                    noResultsMsg.innerHTML = 'No menu items found for "' + searchTerm + '"';
                }
            } else if (noResultsMsg) {
                noResultsMsg.style.display = 'none';
            }
        });
        
        // Add clear button functionality with Escape key
        searchInput.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                this.value = '';
                this.dispatchEvent(new Event('keyup'));
                this.blur();
            }
        });
        
        // Add focus highlight
        searchInput.addEventListener('focus', function() {
            this.parentElement.classList.add('search-focused');
        });
        
        searchInput.addEventListener('blur', function() {
            this.parentElement.classList.remove('search-focused');
        });
    }
});

// Function to set active menu item without jumping
function setActiveMenuItem(controlId, element) {
    // Remove active class from all menu items
    document.querySelectorAll('.Menu').forEach(function(item) {
        item.classList.remove('active');
        // Remove any inline styles that might cause jumping
        item.style.transform = '';
        item.style.marginLeft = '';
        item.style.padding = '';
    });
    
    // Add active class to selected item
    var activeItem = element || document.getElementById('C' + controlId);
    if (activeItem) {
        activeItem.classList.add('active');
        // Ensure no transform on active item
        activeItem.style.transform = 'none';
        // Save to localStorage
        localStorage.setItem('activeMenuId', activeItem.id);
    }
}

// Handle menu clicks without jumping - FIXED to work with PageLoad function
document.addEventListener('DOMContentLoaded', function() {
    // Add click handlers to all menu items
    var allMenus = document.querySelectorAll('.Menu');
    allMenus.forEach(function(menu) {
        // Remove any existing listeners to prevent duplicates
        menu.removeEventListener('click', menu._handler);
        
        // Create new handler
        menu._handler = function(e) {
            // Prevent event bubbling
            e.stopPropagation();
            
            // Remove active class from all
            allMenus.forEach(function(m) {
                m.classList.remove('active');
                m.style.transform = '';
            });
            
            // Add active class to clicked item
            this.classList.add('active');
            this.style.transform = 'none';
            
            // Save to localStorage
            localStorage.setItem('activeMenuId', this.id);
            
            // If there's an onclick attribute, let it execute
            // Don't prevent default behavior
        };
        
        menu.addEventListener('click', menu._handler);
    });
});

// Function to manually set active menu from PageLoad function
window.setActiveMenu = function(elementId) {
    // Remove active class from all menu items
    document.querySelectorAll('.Menu').forEach(function(item) {
        item.classList.remove('active');
        item.style.transform = '';
    });
    
    // Add active class to specified element
    var activeItem = document.getElementById(elementId);
    if (activeItem) {
        activeItem.classList.add('active');
        activeItem.style.transform = 'none';
        localStorage.setItem('activeMenuId', elementId);
    }
};

// Renamed Load function to PageLoad to avoid conflicts
window.PageLoad = function(url, controlId) {
    // Set active menu before loading
    if (controlId) {
        setActiveMenuItem(controlId, null);
    }
    
    // Load the content
    var loadDiv = document.getElementById('Load');
    if (loadDiv) {
        // Show loading indicator
        loadDiv.innerHTML = '<div class="loading"></div>';
        
        // Fetch the content
        fetch(url)
            .then(response => response.text())
            .then(data => {
                loadDiv.innerHTML = data;
            })
            .catch(error => {
                loadDiv.innerHTML = '<div class="error">Error loading content: ' + error + '</div>';
            });
    }
};

// Also keep the original Load function if it exists and wrap it
if (typeof window.originalLoadFunction === 'undefined' && typeof window.Load === 'function') {
    window.originalLoadFunction = window.Load;
    window.Load = function(url, controlId) {
        // Set active menu before loading
        if (controlId) {
            setActiveMenuItem(controlId, null);
        }
        // Call original Load function
        window.originalLoadFunction(url, controlId);
    };
}

// Optional: Add resize handler to maintain proper state on window resize
var resizeTimeout;
window.addEventListener('resize', function() {
    clearTimeout(resizeTimeout);
    resizeTimeout = setTimeout(function() {
        var leftAreaInner = document.querySelector('.left-area-inner');
        // Optional: Auto-collapse on mobile (uncomment if needed)
        // if (window.innerWidth <= 768 && !isSidebarCollapsed) {
        //     toggleSidebar();
        // } else if (window.innerWidth > 768 && isSidebarCollapsed) {
        //     toggleSidebar();
        // }
    }, 250);
});

// Keyboard shortcut (Alt + S) to toggle sidebar
document.addEventListener('keydown', function(e) {
    if (e.altKey && e.key === 's') {
        e.preventDefault();
        toggleSidebar();
    }
});

// Ensure the slider icon stays centered on page load
window.addEventListener('load', function() {
    var sliderToggle = document.querySelector('.slider-toggle');
    if (sliderToggle && isSidebarCollapsed) {
        sliderToggle.classList.add('collapsed');
    }
    
    // Fix for any inline styles that might break centering
    var sliderIcon = document.querySelector('.slider-icon');
    if (sliderIcon) {
        sliderIcon.style.transform = '';
    }
    
    // Ensure no menu items have transform on load
    document.querySelectorAll('.Menu.active').forEach(function(item) {
        item.style.transform = 'none';
    });
});

// Optional: Function to change collapsed width dynamically
function setSidebarWidth(width) {
    var validWidths = ['40px', '45px', '50px'];
    if (validWidths.includes(width)) {
        collapsedWidth = width;
        localStorage.setItem('sidebarWidth', width);
        if (isSidebarCollapsed) {
            // Re-collapse with new width
            toggleSidebar();
            toggleSidebar();
        }
        return true;
    }
    return false;
}

// Optional: Double-click on sidebar to toggle
document.addEventListener('DOMContentLoaded', function() {
    var leftArea = document.querySelector('.left-area');
    if (leftArea) {
        leftArea.addEventListener('dblclick', function(e) {
            // Only toggle if double-clicking on empty area
            if (e.target === leftArea || e.target.classList.contains('left-area-inner')) {
                toggleSidebar();
            }
        });
    }
});
</script>