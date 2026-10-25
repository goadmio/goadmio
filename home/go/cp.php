<?php
echo "
<div class='SearchContainer'>
    <input type='text' name=Search id=Search onkeyup='Search()' placeholder='Search' class='SearchInput'>
</div>
";

$X=0;
$Result = SQL("select * from Control where $ServiceSql order by $SortBy");
$categoryCount = 0;
$lastControlMenu = null;

foreach ($Result as $Row)
{
    $X++;
    $ControlID=$Row['ControlID'];
    
    $ControlMenu=$LNG[$Row['ControlMenu']];
    $ControlMenuImage=$Row['ControlMenuImage'];

    $Control=$LNG[$Row['Control']];
    $ControlImage=$Row['ControlImage'];

    $ControlUrl=$Row['ControlUrl'];
    $ControlUrl=str_replace("[Service]",$Service,$ControlUrl);
    $ControlUrl=str_replace("[ServiceControl]",$ServiceControl,$ControlUrl);
    $ControlUrl=str_replace("[ModuleName]",$ModuleName,$ControlUrl);
    $ControlUrl=str_replace("[CTabNo]",$CTabNo,$ControlUrl);
    $ControlUrl=str_replace("[ControlID]",$ControlID,$ControlUrl);
    
    $ControlUrlArray=explode("?",$Row['ControlUrl']);
    $ControlFile=$ControlUrlArray[0];

    $ControlTarget=$Row['ControlTarget'];
    
    $ControlText=$LNG[$Row['Control']];
    $ControlFind="$ControlText {$LNG[$Row['ControlMenu']]} {$Row['SubFiles']}";

    if ($lastControlMenu != $ControlMenu)
    {
        if ($categoryCount > 0)
        {
            // Close previous category content
            echo "
                    </div>
                </div>
            </div>
            ";
        }
        
        $categoryCount++;
        $MenuControlFind = "";
        $categoryId = "cat_" . preg_replace('/[^a-zA-Z0-9]/', '_', $ControlMenu) . "_" . $categoryCount;

        $ResultQ = SQL("select * from Control where $ServiceSql and ControlMenu='{$Row['ControlMenu']}' ORDER BY $SortBy");
        foreach ($ResultQ as $RowQ)
        {
            $BControlFind="{$LNG[$RowQ['Control']]} {$LNG[$RowQ['ControlMenu']]} {$LNG[$RowQ['SubFiles']]}";
            $MenuControlFind.="-{$BControlFind}-";
        }
            
        echo "
        <div id='Find' find='$MenuControlFind' class='CategoryWrapper' data-category-title='$ControlMenu'>
            <div class='CategoryHeader' onclick='toggleCategoryIcon(\"$categoryId\")'>
                <span class='CategoryArrow' id='arrow_$categoryId'>▼</span>
                <span class='CategoryTitle'>$ControlMenu</span>
            </div>
            <div class='CategoryContent' id='$categoryId' style='display: block;'>
                <div class='DivIcon'>
        ";
    }

    if (stristr("|{$_SESSION['SessionControlFile']}|","|$ControlFile|") or $_SESSION['SessionControlFile']=="")
    {   
        if ($ControlTarget == "")
        {
            echo "
                    <a id='Find' find='$ControlFind' href='javascript:Load(\"$ControlUrl\",\"$ControlID\")' class='Main {$Dir}Main' data-find='$ControlFind'>
                        <div class='Icon'>
                            <img src='theme/{$_SESSION['SessionTheme']}/svg/$ControlImage' alt='$Control'>
                        </div>
                        <span>$Control</span>
                    </a>
                        
            ";
        }
        else
        {

            echo "
                    <a id='Find' find='$ControlFind' href='$ControlUrl' target='$ControlTarget' class='Main {$Dir}Main'>
                        <div class='Icon'>
                            <img src='theme/{$_SESSION['SessionTheme']}/svg/$ControlImage' alt='$Control'>
                        </div>
                        <span>$Control</span>
                    </a>
                    
            ";
        }
    }

    $lastControlMenu = $ControlMenu;
}

// Close last category content
if ($categoryCount > 0)
{
    echo "
                </div>
            </div>
        </div>
        
    ";
}
?>
