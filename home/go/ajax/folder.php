<?php
// Function to scan directories and build tree structure
function getFolderTree($directory, $basePath = '') {
    $folders = [];
    $currentPath = $basePath ? $basePath . '/' . basename($directory) : basename($directory);
    
    if (is_dir($directory)) {
        $items = scandir($directory);
        $dirs = array_filter($items, function($item) use ($directory) {
            return $item !== '.' && $item !== '..' && is_dir($directory . DIRECTORY_SEPARATOR . $item);
        });
        
        sort($dirs);
        
        foreach ($dirs as $dir) {
            $fullPath = $directory . DIRECTORY_SEPARATOR . $dir;
            $relativePath = $currentPath . '/' . $dir;
            $folders[] = [
                'name' => $dir,
                'path' => $relativePath,
                'full_path' => $fullPath,
                'children' => getFolderTree($fullPath, $currentPath)
            ];
        }
    }
    
    return $folders;
}

// Get WWWPath from GET parameter
$WWWPath = $_REQUEST['WWWPath'];

if (is_dir($WWWPath)) {
    $tree = getFolderTree($WWWPath);
    $response = [
        'success' => true, 
        'tree' => $tree, 
        'root' => basename($WWWPath),
        'wwwPath' => $WWWPath
    ];
} else {
    $response = [
        'success' => false, 
        'error' => 'Invalid directory path: ' . $WWWPath
    ];
}

// Return JSON response
header('Content-Type: application/json');
echo json_encode($response);
exit;
?>