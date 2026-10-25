<?php
session_start();

if (!stristr($_SESSION['SessionDomain'],"."))
{
echo "Please Login.";
exit;
}

// Configuration
$root_path = "/home/{$_SESSION['SessionDomain']}/www";
$script_url = "https://{$_SERVER['HTTP_HOST']}/fm/index.php";
$download_url = "https://www.{$_SESSION['SessionDomain']}";
$current_path = isset($_GET['path']) ? $_GET['path'] : '';
$full_path = $root_path . ($current_path ? '/' . $current_path : '');

// Security: Prevent directory traversal
$real_full_path = realpath($full_path);
$real_root_path = realpath($root_path);
if ($real_full_path === false || strpos($real_full_path, $real_root_path) !== 0) {
    die('Access denied');
}

// Handle file actions
$message = '';
$clipboard = isset($_SESSION['clipboard']) ? $_SESSION['clipboard'] : null;

// G7 Constants
define('G7_MAGIC', 'G7ARCHIVE');
define('G7_VERSION', 1);
define('G7_CHUNK_SIZE', 65536); // 64KB chunks

// Helper function to convert server path to web URL
function getWebUrl($server_path, $root_path, $base_url) {
    $relative_path = str_replace($root_path, '', $server_path);
    return rtrim($base_url, '/') . '/' . ltrim($relative_path, '/');
}

// G7 Compression Functions
function isG7Archive($filepath) {
    if (!file_exists($filepath)) return false;
    $handle = fopen($filepath, 'rb');
    if (!$handle) return false;
    $magic = fread($handle, 10);
    fclose($handle);
    return $magic === G7_MAGIC;
}

function getG7Metadata($filepath) {
    if (!isG7Archive($filepath)) return false;
    
    $handle = fopen($filepath, 'rb');
    if (!$handle) return false;
    
    // Read magic
    $magic = fread($handle, 10);
    
    // Read version
    $version_data = fread($handle, 2);
    $version = unpack('v', $version_data)[1];
    
    // Read compression type
    $compression_data = fread($handle, 1);
    $compression_type = unpack('C', $compression_data)[1];
    
    // Read file count
    $filecount_data = fread($handle, 4);
    $file_count = unpack('V', $filecount_data)[1];
    
    // Read metadata size
    $metadata_size_data = fread($handle, 4);
    $metadata_size = unpack('V', $metadata_size_data)[1];
    
    // Read metadata
    $metadata_compressed = fread($handle, $metadata_size);
    $metadata_json = gzuncompress($metadata_compressed);
    $metadata = json_decode($metadata_json, true);
    
    fclose($handle);
    
    return [
        'version' => $version,
        'compression_type' => $compression_type,
        'file_count' => $file_count,
        'files' => $metadata['files'],
        'total_size' => $metadata['total_size']
    ];
}

function compressG7($source_path, $destination_path, $compression_level = 6) {
    // Handle single file or directory
    if (is_dir($source_path)) {
        $files = getAllFilesRecursive($source_path);
    } else {
        $files = [[
            'path' => $source_path,
            'name' => basename($source_path),
            'relative_path' => basename($source_path)
        ]];
    }
    
    $handle = fopen($destination_path, 'wb');
    if (!$handle) throw new Exception("Cannot create G7 archive: $destination_path");
    
    // Write magic header
    fwrite($handle, G7_MAGIC);
    
    // Write version (2 bytes)
    fwrite($handle, pack('v', G7_VERSION));
    
    // Write compression type (1 byte: 0=none, 1=zlib, 2=gzip)
    $compression_type = 1; // zlib
    fwrite($handle, pack('C', $compression_type));
    
    // Prepare metadata
    $metadata = [
        'files' => [],
        'total_size' => 0,
        'created' => time(),
        'compression_level' => $compression_level
    ];
    
    // First pass: collect file info and calculate total size
    $file_data_offsets = [];
    $current_offset = 10 + 2 + 1 + 4 + 4; // magic(10)+version(2)+compression(1)+filecount(4)+metadatasize(4)
    
    $total_original_size = 0;
    $total_compressed_size = 0;
    
    foreach ($files as $file) {
        $filepath = $file['path'];
        if (!file_exists($filepath)) continue;
        
        $original_size = filesize($filepath);
        $total_original_size += $original_size;
        
        // Compress file content
        $content = file_get_contents($filepath);
        $compressed = gzcompress($content, $compression_level);
        $compressed_size = strlen($compressed);
        $total_compressed_size += $compressed_size;
        
        $metadata['files'][] = [
            'name' => $file['name'],
            'relative_path' => $file['relative_path'],
            'original_size' => $original_size,
            'compressed_size' => $compressed_size,
            'offset' => $current_offset,
            'is_dir' => false
        ];
        
        $file_data_offsets[] = [
            'offset' => $current_offset,
            'data' => $compressed
        ];
        
        $current_offset += $compressed_size;
    }
    
    $metadata['total_size'] = $total_original_size;
    $metadata['compressed_total_size'] = $total_compressed_size;
    
    // Compress metadata
    $metadata_json = json_encode($metadata);
    $metadata_compressed = gzcompress($metadata_json, 9);
    $metadata_size = strlen($metadata_compressed);
    
    // Write placeholder for file count (will be updated later)
    fseek($handle, 10 + 2 + 1);
    fwrite($handle, pack('V', count($metadata['files'])));
    
    // Write metadata size
    fwrite($handle, pack('V', $metadata_size));
    
    // Write metadata
    fwrite($handle, $metadata_compressed);
    
    // Write file data
    foreach ($file_data_offsets as $file_data) {
        fwrite($handle, $file_data['data']);
    }
    
    fclose($handle);
    return true;
}

function extractG7($archive_path, $destination_path, $preserve_structure = true) {
    if (!isG7Archive($archive_path)) {
        throw new Exception("Not a valid G7 archive");
    }
    
    $metadata = getG7Metadata($archive_path);
    if (!$metadata) {
        throw new Exception("Cannot read G7 archive metadata");
    }
    
    $handle = fopen($archive_path, 'rb');
    if (!$handle) throw new Exception("Cannot open G7 archive");
    
    // Seek to file data start
    $header_size = 10 + 2 + 1 + 4 + 4 + $metadata['metadata_size'];
    fseek($handle, $header_size);
    
    // Create destination directory if not exists
    if (!is_dir($destination_path)) {
        mkdir($destination_path, 0777, true);
    }
    
    foreach ($metadata['files'] as $file_info) {
        // Read compressed data
        fseek($handle, $file_info['offset']);
        $compressed_data = fread($handle, $file_info['compressed_size']);
        
        // Decompress
        $original_data = gzuncompress($compressed_data);
        if ($original_data === false) {
            throw new Exception("Failed to decompress: {$file_info['name']}");
        }
        
        // Determine output path
        if ($preserve_structure && isset($file_info['relative_path'])) {
            $output_path = $destination_path . '/' . $file_info['relative_path'];
        } else {
            $output_path = $destination_path . '/' . $file_info['name'];
        }
        
        // Create subdirectories if needed
        $output_dir = dirname($output_path);
        if (!is_dir($output_dir)) {
            mkdir($output_dir, 0777, true);
        }
        
        // Write decompressed data
        file_put_contents($output_path, $original_data);
        
        // Preserve original file modification time if available
        if (isset($file_info['mtime'])) {
            touch($output_path, $file_info['mtime']);
        }
    }
    
    fclose($handle);
    return true;
}

function listG7Contents($archive_path) {
    if (!isG7Archive($archive_path)) {
        throw new Exception("Not a valid G7 archive");
    }
    
    $metadata = getG7Metadata($archive_path);
    if (!$metadata) {
        throw new Exception("Cannot read G7 archive metadata");
    }
    
    return $metadata['files'];
}

function getAllFilesRecursive($dir, $base_path = null) {
    $files = [];
    if ($base_path === null) {
        $base_path = $dir;
    }
    
    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($dir, RecursiveDirectoryIterator::SKIP_DOTS),
        RecursiveIteratorIterator::LEAVES_ONLY
    );
    
    foreach ($iterator as $file) {
        if ($file->isFile()) {
            $relative_path = substr($file->getPathname(), strlen($base_path) + 1);
            $files[] = [
                'path' => $file->getPathname(),
                'name' => $file->getFilename(),
                'relative_path' => $relative_path
            ];
        }
    }
    
    return $files;
}

// Helper functions
function showMessage($msg, $type = 'success') {
    return "<div class='alert alert-$type'>" . htmlspecialchars($msg) . "</div>";
}

function formatSize($bytes) {
    if ($bytes >= 1073741824) return number_format($bytes / 1073741824, 2) . ' GB';
    if ($bytes >= 1048576) return number_format($bytes / 1048576, 2) . ' MB';
    if ($bytes >= 1024) return number_format($bytes / 1024, 2) . ' KB';
    return $bytes . ' B';
}

function getFileIcon($filename) {
    $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    
    $icons = [
        'txt' => '📄', 'pdf' => '📑', 'jpg' => '🖼️', 'jpeg' => '🖼️', 'png' => '🖼️',
        'gif' => '🖼️', 'zip' => '📦', 'rar' => '💿', 'tar' => '📀', 'gz' => '📦',
        'php' => '⚙️', 'html' => '🌐', 'css' => '🎨', 'js' => '📜', 'mp3' => '🎵',
        'mp4' => '🎬', 'doc' => '📝', 'docx' => '📝', 'xls' => '📊', 'xlsx' => '📊',
        'json' => '{ }', 'xml' => '📋', 'md' => '📝', 'py' => '🐍', 'c' => '⚙️',
        'cpp' => '⚙️', 'java' => '☕', 'sql' => '🗄️', 'sh' => '💻', 'bat' => '💻',
        '7z' => '🗜️', 'g7' => '💎'
    ];
    return isset($icons[$ext]) ? $icons[$ext] : (is_dir($filename) ? '📁' : '📄');
}

function isTextFile($filename) {
    $text_extensions = ['txt', 'php', 'html', 'htm', 'css', 'js', 'json', 'xml', 'md', 'py', 'c', 'cpp', 'java', 'sql', 'sh', 'bat', 'ini', 'cfg', 'conf', 'log'];
    $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    return in_array($ext, $text_extensions);
}

function isArchiveFile($filename) {
    $archive_extensions = ['zip', 'rar', 'tar', 'gz', 'tar.gz', '7z', 'g7'];
    $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    
    // Special check for .tar.gz
    if (strpos($filename, '.tar.gz') !== false) return true;
    
    // Check for .g7 extension
    if ($ext === 'g7') return true;
    
    return in_array($ext, $archive_extensions);
}

function getFileContent($filepath) {
    return file_get_contents($filepath);
}

function saveFileContent($filepath, $content) {
    return file_put_contents($filepath, $content);
}

function deleteDirectory($dir) {
    if (!file_exists($dir)) return true;
    if (!is_dir($dir)) return unlink($dir);
    foreach (scandir($dir) as $item) {
        if ($item == '.' || $item == '..') continue;
        if (!deleteDirectory($dir . DIRECTORY_SEPARATOR . $item)) return false;
    }
    return rmdir($dir);
}

function copyDirectory($source, $target) {
    if (!is_dir($target)) mkdir($target, 0777, true);
    foreach (scandir($source) as $item) {
        if ($item == '.' || $item == '..') continue;
        $s = $source . '/' . $item;
        $t = $target . '/' . $item;
        if (is_dir($s)) {
            copyDirectory($s, $t);
        } else {
            copy($s, $t);
        }
    }
}

function extractArchive($archive, $destination) {
    if (!is_dir($destination)) mkdir($destination, 0777, true);
    
    // Check for G7 archive first
    if (isG7Archive($archive)) {
        extractG7($archive, $destination);
        return true;
    }
    
    if (preg_match('/\.(tar\.gz|tgz)$/i', $archive)) {
        try {
            // First, extract the .tar.gz to a temporary location
            $temp_dir = dirname($destination) . '/temp_extract_' . uniqid();
            if (!is_dir($temp_dir)) mkdir($temp_dir, 0777, true);
            
            // Extract the .tar.gz file
            $phar = new PharData($archive);
            $phar->extractTo($temp_dir);
            
            // Now look for the .tar file in the temp directory
            $temp_files = scandir($temp_dir);
            $tar_file = null;
            
            foreach ($temp_files as $file) {
                if ($file != '.' && $file != '..' && preg_match('/\.tar$/i', $file)) {
                    $tar_file = $temp_dir . '/' . $file;
                    break;
                }
            }
            
            // If we found a .tar file, extract it to the actual destination
            if ($tar_file && file_exists($tar_file)) {
                $tar = new PharData($tar_file);
                $tar->extractTo($destination);
            } else {
                // If no .tar file found, just move everything from temp to destination
                foreach ($temp_files as $file) {
                    if ($file != '.' && $file != '..') {
                        rename($temp_dir . '/' . $file, $destination . '/' . $file);
                    }
                }
            }
            
            // Clean up temp directory
            deleteDirectory($temp_dir);
            
        } catch (Exception $e) {
            // Fallback to system command if Phar fails
            if (function_exists('exec') && !ini_get('safe_mode')) {
                // Extract to a temp directory first
                $temp_dir = dirname($destination) . '/temp_extract_' . uniqid();
                mkdir($temp_dir, 0777, true);
                
                // Extract tar.gz
                exec("tar -xzf " . escapeshellarg($archive) . " -C " . escapeshellarg($temp_dir));
                
                // Check if we have a .tar file in the temp directory
                $temp_files = scandir($temp_dir);
                $tar_file = null;
                
                foreach ($temp_files as $file) {
                    if ($file != '.' && $file != '..' && preg_match('/\.tar$/i', $file)) {
                        $tar_file = $temp_dir . '/' . $file;
                        break;
                    }
                }
                
                // If .tar file exists, extract it
                if ($tar_file && file_exists($tar_file)) {
                    exec("tar -xf " . escapeshellarg($tar_file) . " -C " . escapeshellarg($destination));
                } else {
                    // Move all contents from temp to destination
                    foreach ($temp_files as $file) {
                        if ($file != '.' && $file != '..') {
                            rename($temp_dir . '/' . $file, $destination . '/' . $file);
                        }
                    }
                }
                
                // Clean up
                deleteDirectory($temp_dir);
            } else {
                throw new Exception("Unable to extract TAR.GZ file. Please check PHP Phar extension.");
            }
        }
    } elseif (preg_match('/\.zip$/i', $archive)) {
        $zip = new ZipArchive();
        if ($zip->open($archive) === true) {
            $zip->extractTo($destination);
            $zip->close();
        } else {
            throw new Exception("Unable to open ZIP archive");
        }
    } elseif (preg_match('/\.rar$/i', $archive)) {
        // Extract RAR archive using system command
        $success = false;
        
        // Try using unrar command line tool
        if (function_exists('exec') && !ini_get('safe_mode')) {
            // Check if unrar is installed
            exec("unrar x " . escapeshellarg($archive) . " " . escapeshellarg($destination) . " 2>&1", $output, $return_var);
            if ($return_var === 0 || file_exists($destination . '/' . basename($archive, '.rar'))) {
                $success = true;
            } else {
                // Try alternative method
                exec("rar x " . escapeshellarg($archive) . " " . escapeshellarg($destination) . " 2>&1", $output, $return_var);
                if ($return_var === 0) {
                    $success = true;
                }
            }
        }
        
        // Try PHP RAR extension as fallback
        if (!$success && class_exists('RarArchive')) {
            $rar = RarArchive::open($archive);
            if ($rar !== false) {
                $entries = $rar->getEntries();
                if ($entries !== false) {
                    foreach ($entries as $entry) {
                        $entry->extract($destination);
                    }
                    $success = true;
                }
                $rar->close();
            }
        }
        
        if (!$success) {
            throw new Exception("Unable to extract RAR file. Please ensure 'unrar' or 'rar' command is installed.");
        }
    } elseif (preg_match('/\.7z$/i', $archive)) {
        // Extract 7z archive using system command
        if (function_exists('exec') && !ini_get('safe_mode')) {
            exec("7z x " . escapeshellarg($archive) . " -o" . escapeshellarg($destination) . " -y 2>&1", $output, $return_var);
            if ($return_var !== 0) {
                exec("7za x " . escapeshellarg($archive) . " -o" . escapeshellarg($destination) . " -y 2>&1", $output, $return_var);
            }
            if ($return_var !== 0) {
                throw new Exception("Unable to extract 7z file. Please ensure 7z or 7za command is installed.");
            }
        } else {
            throw new Exception("7z extraction requires command-line tools.");
        }
    } elseif (preg_match('/\.tar$/i', $archive)) {
        try {
            $phar = new PharData($archive);
            $phar->extractTo($destination);
        } catch (Exception $e) {
            if (function_exists('exec') && !ini_get('safe_mode')) {
                exec("tar -xf " . escapeshellarg($archive) . " -C " . escapeshellarg($destination));
            } else {
                throw new Exception("Unable to extract TAR file");
            }
        }
    } elseif (preg_match('/\.gz$/i', $archive) && !preg_match('/\.tar\.gz$/i', $archive)) {
        $buffer_size = 4096;
        $out_file_name = str_replace('.gz', '', $archive);
        $file = gzopen($archive, 'rb');
        $out_file = fopen($out_file_name, 'wb');
        while (!gzeof($file)) {
            fwrite($out_file, gzread($file, $buffer_size));
        }
        fclose($out_file);
        gzclose($file);
    }
}

function compressFolder($folder, $archive_path, $type) {
    // Set temporary directory to current folder to avoid permission issues
    $temp_dir = dirname($archive_path);
    $old_temp = sys_get_temp_dir();
    
    // Try to use current directory for temp files
    if (is_writable($temp_dir)) {
        putenv("TMPDIR=$temp_dir");
        putenv("TEMP=$temp_dir");
        putenv("TMP=$temp_dir");
    }
    
    // Handle G7 compression
    if ($type == 'g7') {
        compressG7($folder, $archive_path);
        return true;
    }
    
    if ($type == 'zip') {
        $zip = new ZipArchive();
        if ($zip->open($archive_path, ZipArchive::CREATE | ZipArchive::OVERWRITE) === true) {
            $files = new RecursiveIteratorIterator(
                new RecursiveDirectoryIterator($folder, RecursiveDirectoryIterator::SKIP_DOTS),
                RecursiveIteratorIterator::LEAVES_ONLY
            );
            foreach ($files as $name => $file) {
                if (!$file->isDir()) {
                    $filePath = $file->getRealPath();
                    $relativePath = substr($filePath, strlen($folder) + 1);
                    $zip->addFile($filePath, $relativePath);
                }
            }
            $zip->close();
            return true;
        } else {
            throw new Exception("Failed to create ZIP archive");
        }
    } elseif ($type == 'rar') {
        // Use system rar command for compression
        $success = false;
        
        if (function_exists('exec') && !ini_get('safe_mode')) {
            // Try using rar command
            $cmd = "rar a -r " . escapeshellarg($archive_path) . " " . escapeshellarg($folder) . "/* 2>&1";
            exec($cmd, $output, $return_var);
            
            if (file_exists($archive_path) && filesize($archive_path) > 0) {
                $success = true;
            } else {
                // Try alternative method with different parameters
                $cmd2 = "rar a -ep1 -r " . escapeshellarg($archive_path) . " " . escapeshellarg($folder) . " 2>&1";
                exec($cmd2, $output2, $return_var2);
                if (file_exists($archive_path) && filesize($archive_path) > 0) {
                    $success = true;
                } else {
                    throw new Exception("Failed to create RAR archive. Command output: " . implode("\n", $output));
                }
            }
        } else {
            throw new Exception("RAR compression requires 'rar' command-line tool. Please install RAR command line tools.");
        }
        
        return $success;
    } elseif ($type == '7z') {
        // 7z compression
        if (function_exists('exec') && !ini_get('safe_mode')) {
            $cmd = "7z a -t7z " . escapeshellarg($archive_path) . " " . escapeshellarg($folder) . "/* -mx=9 2>&1";
            exec($cmd, $output, $return_var);
            
            if (file_exists($archive_path) && filesize($archive_path) > 0) {
                return true;
            } else {
                throw new Exception("Failed to create 7z archive. Please ensure 7z command is installed.");
            }
        } else {
            throw new Exception("7z compression requires command-line tools.");
        }
    } elseif ($type == 'tar.gz') {
        $tar_path = str_replace('.tar.gz', '.tar', $archive_path);
        try {
            // Try using Phar for tar first
            $phar = new PharData($tar_path);
            $phar->buildFromDirectory($folder);
            
            // Then compress to gz
            if (file_exists($tar_path)) {
                $phar_gz = $phar->compress(Phar::GZ);
                unlink($tar_path);
                return true;
            }
            throw new Exception("Failed to create intermediate TAR file");
        } catch (Exception $e) {
            // Clean up if Phar fails
            if (file_exists($tar_path)) @unlink($tar_path);
            
            // Fallback to system command
            if (function_exists('exec') && !ini_get('safe_mode')) {
                exec("tar -czf " . escapeshellarg($archive_path) . " -C " . escapeshellarg(dirname($folder)) . " " . escapeshellarg(basename($folder)));
                return file_exists($archive_path);
            } else {
                throw new Exception("Unable to create TAR.GZ archive. Please check PHP Phar extension and system permissions: " . $e->getMessage());
            }
        }
    }
    return false;
}

// Handle file editing
$edit_file = isset($_GET['edit']) ? $_GET['edit'] : '';
$edit_content = '';
$is_editing = false;

if ($edit_file) {
    $edit_path = $full_path . '/' . basename($edit_file);
    if (file_exists($edit_path) && is_file($edit_path) && isTextFile($edit_file)) {
        $is_editing = true;
        if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['file_content'])) {
            if (saveFileContent($edit_path, $_POST['file_content'])) {
                $message = showMessage('File saved successfully!');
                $edit_content = $_POST['file_content'];
            } else {
                $message = showMessage('Error saving file!', 'danger');
                $edit_content = getFileContent($edit_path);
            }
        } else {
            $edit_content = getFileContent($edit_path);
        }
    } else {
        $message = showMessage('File not found or not editable!', 'danger');
        $is_editing = false;
    }
}

// Enhanced upload handling with multi-file support
function handleMultiFileUpload($files, $target_dir) {
    $uploaded = [];
    $errors = [];
    
    // Handle single file upload
    if (isset($files['file']) && $files['file']['error'] !== UPLOAD_ERR_NO_FILE) {
        $file = $files['file'];
        // Handle multiple files with same name input
        if (is_array($file['name'])) {
            // Multiple files uploaded
            for ($i = 0; $i < count($file['name']); $i++) {
                if ($file['error'][$i] == UPLOAD_ERR_OK) {
                    $target = $target_dir . '/' . basename($file['name'][$i]);
                    if (move_uploaded_file($file['tmp_name'][$i], $target)) {
                        $uploaded[] = $file['name'][$i];
                    } else {
                        $errors[] = "Failed to upload: " . $file['name'][$i];
                    }
                } elseif ($file['error'][$i] != UPLOAD_ERR_NO_FILE) {
                    $errors[] = "Error uploading " . $file['name'][$i] . ": " . getUploadErrorMessage($file['error'][$i]);
                }
            }
        } else {
            // Single file uploaded
            if ($file['error'] == UPLOAD_ERR_OK) {
                $target = $target_dir . '/' . basename($file['name']);
                if (move_uploaded_file($file['tmp_name'], $target)) {
                    $uploaded[] = $file['name'];
                } else {
                    $errors[] = "Failed to upload: " . $file['name'];
                }
            } elseif ($file['error'] != UPLOAD_ERR_NO_FILE) {
                $errors[] = "Error uploading " . $file['name'] . ": " . getUploadErrorMessage($file['error']);
            }
        }
    }
    
    // Handle multiple file uploads from 'files[]' input
    if (isset($files['files'])) {
        foreach ($files['files']['name'] as $i => $name) {
            if ($files['files']['error'][$i] == UPLOAD_ERR_OK) {
                $target = $target_dir . '/' . basename($name);
                if (move_uploaded_file($files['files']['tmp_name'][$i], $target)) {
                    $uploaded[] = $name;
                } else {
                    $errors[] = "Failed to upload: " . $name;
                }
            } elseif ($files['files']['error'][$i] != UPLOAD_ERR_NO_FILE) {
                $errors[] = "Error uploading " . $name . ": " . getUploadErrorMessage($files['files']['error'][$i]);
            }
        }
    }
    
    return ['uploaded' => $uploaded, 'errors' => $errors];
}

function getUploadErrorMessage($error_code) {
    switch ($error_code) {
        case UPLOAD_ERR_INI_SIZE:
            return "File exceeds upload_max_filesize directive";
        case UPLOAD_ERR_FORM_SIZE:
            return "File exceeds MAX_FILE_SIZE directive";
        case UPLOAD_ERR_PARTIAL:
            return "File was only partially uploaded";
        case UPLOAD_ERR_NO_FILE:
            return "No file was uploaded";
        case UPLOAD_ERR_NO_TMP_DIR:
            return "Missing temporary folder";
        case UPLOAD_ERR_CANT_WRITE:
            return "Failed to write file to disk";
        case UPLOAD_ERR_EXTENSION:
            return "File upload stopped by extension";
        default:
            return "Unknown upload error";
    }
}

// Action handlers
if ($_SERVER['REQUEST_METHOD'] == 'POST' && !isset($_POST['save_content'])) {
    if (isset($_POST['action'])) {
        try {
            switch ($_POST['action']) {
                case 'upload':
                    $upload_result = handleMultiFileUpload($_FILES, $full_path);
                    if (count($upload_result['uploaded']) > 0) {
                        $message = showMessage('Uploaded: ' . implode(', ', $upload_result['uploaded']));
                    }
                    if (count($upload_result['errors']) > 0) {
                        $message .= showMessage('Errors: ' . implode(', ', $upload_result['errors']), 'danger');
                    }
                    if (count($upload_result['uploaded']) == 0 && count($upload_result['errors']) == 0) {
                        $message = showMessage('No files selected or upload error', 'warning');
                    }
                    break;
                    
                case 'mkdir':
                    $dirname = trim($_POST['dirname']);
                    if ($dirname && !is_dir($full_path . '/' . $dirname)) {
                        mkdir($full_path . '/' . $dirname, 0777, true);
                        $message = showMessage('Folder created: ' . $dirname);
                    } else {
                        $message = showMessage('Invalid folder name or already exists', 'danger');
                    }
                    break;
                    
                case 'delete':
                    $items_json = isset($_POST['items']) ? $_POST['items'] : '[]';
                    $items = json_decode($items_json, true);
                    if (is_array($items)) {
                        foreach ($items as $item) {
                            $item_path = $full_path . '/' . basename($item);
                            if (file_exists($item_path)) {
                                if (is_file($item_path)) {
                                    unlink($item_path);
                                } elseif (is_dir($item_path)) {
                                    deleteDirectory($item_path);
                                }
                            }
                        }
                        $message = showMessage('Selected items deleted');
                    }
                    break;
                    
                case 'copy_to_clipboard':
                    $items_json = isset($_POST['items']) ? $_POST['items'] : '[]';
                    $items = json_decode($items_json, true);
                    if (is_array($items) && !empty($items)) {
                        $_SESSION['clipboard'] = ['action' => 'copy', 'items' => $items, 'source_path' => $full_path];
                        $message = showMessage('Copied ' . count($items) . ' item(s)');
                    }
                    break;
                    
                case 'cut_to_clipboard':
                    $items_json = isset($_POST['items']) ? $_POST['items'] : '[]';
                    $items = json_decode($items_json, true);
                    if (is_array($items) && !empty($items)) {
                        $_SESSION['clipboard'] = ['action' => 'cut', 'items' => $items, 'source_path' => $full_path];
                        $message = showMessage('Cut ' . count($items) . ' item(s)');
                    }
                    break;
                    
                case 'paste':
                    if ($clipboard && is_array($clipboard['items'])) {
                        $success = true;
                        foreach ($clipboard['items'] as $item) {
                            $source = $clipboard['source_path'] . '/' . basename($item);
                            $target = $full_path . '/' . basename($item);
                            
                            // Handle duplicate names
                            if (file_exists($target)) {
                                $info = pathinfo($target);
                                $counter = 1;
                                while (file_exists($target)) {
                                    $target = $info['dirname'] . '/' . $info['filename'] . '_copy_' . $counter . (isset($info['extension']) ? '.' . $info['extension'] : '');
                                    $counter++;
                                }
                            }
                            
                            if ($clipboard['action'] == 'copy') {
                                if (is_file($source)) {
                                    copy($source, $target);
                                } elseif (is_dir($source)) {
                                    copyDirectory($source, $target);
                                }
                            } else { // cut
                                rename($source, $target);
                            }
                        }
                        if ($clipboard['action'] == 'cut') {
                            $_SESSION['clipboard'] = null;
                        }
                        $message = showMessage('Pasted successfully');
                    } else {
                        $message = showMessage('Nothing to paste', 'warning');
                    }
                    break;
                
				                case 'extract':
                    if (isset($_POST['archive'])) {
                        $archive = $full_path . '/' . basename($_POST['archive']);
                        if (file_exists($archive)) {
                            // For .tar.gz files, remove both .tar and .gz extensions
                            $archive_name = $_POST['archive'];
                            if (preg_match('/\.tar\.gz$/i', $archive_name)) {
                                $extract_to = $full_path . '/' . preg_replace('/\.tar\.gz$/i', '', $archive_name);
                            } elseif (preg_match('/\.g7$/i', $archive_name)) {
                                $extract_to = $full_path . '/' . preg_replace('/\.g7$/i', '', $archive_name);
                            } else {
                                $extract_to = $full_path . '/' . pathinfo($archive_name, PATHINFO_FILENAME);
                            }
                            extractArchive($archive, $extract_to);
                            $message = showMessage('Archive extracted successfully');
                        } else {
                            $message = showMessage('Archive not found', 'danger');
                        }
                    }
                    break;
                    
                case 'compress':
                    if (isset($_POST['compress_type']) && isset($_POST['compress_folder'])) {
                        $folder = $full_path . '/' . basename($_POST['compress_folder']);
                        if (is_dir($folder)) {
                            $compress_type = $_POST['compress_type'];
                            $archive_name = basename($_POST['compress_folder']) . '.' . $compress_type;
                            $archive_path = $full_path . '/' . $archive_name;
                            
                            // Check if archive already exists
                            if (file_exists($archive_path)) {
                                $message = showMessage('Archive already exists! Please delete or rename existing archive first.', 'warning');
                            } else {
                                compressFolder($folder, $archive_path, $compress_type);
                                $message = showMessage('Folder compressed to ' . $archive_name);
                            }
                        } else {
                            $message = showMessage('Folder not found', 'danger');
                        }
                    }
                    break;
                    
                case 'rename':
                    if (isset($_POST['old_name']) && isset($_POST['new_name'])) {
                        $old_path = $full_path . '/' . basename($_POST['old_name']);
                        $new_path = $full_path . '/' . basename($_POST['new_name']);
                        if (file_exists($old_path) && !file_exists($new_path)) {
                            rename($old_path, $new_path);
                            $message = showMessage('Renamed successfully');
                        } else {
                            $message = showMessage('Rename failed - target may already exist', 'danger');
                        }
                    }
                    break;
                    
                case 'view_g7_info':
                    if (isset($_POST['archive'])) {
                        $archive = $full_path . '/' . basename($_POST['archive']);
                        if (file_exists($archive) && isG7Archive($archive)) {
                            $info = getG7Metadata($archive);
                            $message = showMessage("G7 Archive Info: " . $info['file_count'] . " files, Original: " . formatSize($info['total_size']) . ", Compressed: " . formatSize($info['compressed_total_size']), "info");
                        }
                    }
                    break;
                    
                case 'cancel_upload':
                    // Clear any pending upload sessions
                    if (isset($_SESSION['pending_uploads'])) {
                        unset($_SESSION['pending_uploads']);
                    }
                    $message = showMessage('Upload cancelled', 'info');
                    break;
                    
                case 'clear_clipboard':
                    $_SESSION['clipboard'] = null;
                    $message = showMessage('Clipboard cleared', 'info');
                    break;
            }
        } catch (Exception $e) {
            $message = showMessage('Error: ' . $e->getMessage(), 'danger');
        }
    }
    header('Location: ' . $script_url . $_SERVER['PHP_SELF'] . '?path=' . urlencode($current_path));
    exit;
}

// Get directory contents
$items = [];
if (is_dir($full_path)) {
    $dir_content = scandir($full_path);
    if ($dir_content !== false) {
        foreach ($dir_content as $item) {
            if ($item != '.' && $item != '..') {
                $item_path = $full_path . '/' . $item;
                $items[] = [
                    'name' => $item,
                    'path' => $item_path,
                    'is_dir' => is_dir($item_path),
                    'size' => is_file($item_path) ? filesize($item_path) : 0,
                    'modified' => date('Y-m-d H:i:s', filemtime($item_path)),
                    'icon' => getFileIcon($item_path),
                    'is_text' => isTextFile($item),
                    'is_archive' => isArchiveFile($item),
                    'web_url' => getWebUrl($item_path, $root_path, $download_url)
                ];
            }
        }
        usort($items, function($a, $b) {
            if ($a['is_dir'] == $b['is_dir']) return strcmp($a['name'], $b['name']);
            return $a['is_dir'] ? -1 : 1;
        });
    }
}

// Navigation breadcrumb
$breadcrumb = '<a href="?path=">Root</a>';
if ($current_path) {
    $parts = explode('/', $current_path);
    $accum = '';
    foreach ($parts as $part) {
        $accum .= ($accum ? '/' : '') . $part;
        $breadcrumb .= ' / <a href="?path=' . urlencode($accum) . '">' . htmlspecialchars($part) . '</a>';
    }
}

// Get current script URL for use in JavaScript
$current_script_url = $script_url . $_SERVER['PHP_SELF'];
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GoAdmio File Manager</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; padding: 20px; }
        .container { max-width: 1400px; margin: 0 auto; background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); overflow: hidden; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; }
        .header h1 { margin-bottom: 10px; }
        .header small { opacity: 0.9; }
        .breadcrumb { padding: 15px 20px; background: #ecf0f1; border-bottom: 1px solid #ddd; font-size: 14px; }
        .toolbar { padding: 15px 20px; background: #f8f9fa; border-bottom: 1px solid #ddd; display: flex; gap: 10px; flex-wrap: wrap; }
        .toolbar form { display: inline-flex; gap: 5px; margin: 0; }
        .toolbar input, .toolbar select, .toolbar button { padding: 5px 10px; border: 1px solid #ddd; border-radius: 4px; }
        .toolbar button { background: #3498db; color: white; border: none; cursor: pointer; transition: all 0.2s; }
        .toolbar button:hover { background: #2980b9; transform: translateY(-1px); }
        .toolbar button.danger { background: #e74c3c; }
        .toolbar button.danger:hover { background: #c0392b; }
        .toolbar button.success { background: #27ae60; }
        .toolbar button.success:hover { background: #229954; }
        .toolbar button.warning { background: #f39c12; }
        .toolbar button.warning:hover { background: #e67e22; }
        .toolbar button.g7 { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .toolbar button.g7:hover { background: linear-gradient(135deg, #5a67d8 0%, #6b46a0 100%); }
        .alert { padding: 10px 20px; margin: 10px 20px; border-radius: 4px; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-danger { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alert-warning { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        .alert-info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f8f9fa; font-weight: 600; }
        tr { cursor: context-menu; }
        tr:hover { background: #f5f5f5; }
        .file-icon { font-size: 20px; margin-right: 10px; }
        .folder { color: #2980b9; cursor: pointer; text-decoration: none; }
        .file { color: #2c3e50; }
        .actions { display: flex; gap: 5px; flex-wrap: wrap; }
        .checkbox { width: 20px; }
        .g7-badge { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; font-size: 10px; padding: 2px 6px; border-radius: 10px; margin-left: 5px; display: inline-block; }
        
        /* Context Menu */
        .context-menu { position: fixed; background: white; border: 1px solid #ddd; border-radius: 4px; box-shadow: 0 2px 10px rgba(0,0,0,0.2); z-index: 1000; min-width: 200px; display: none; }
        .context-menu ul { list-style: none; margin: 0; padding: 5px 0; }
        .context-menu li { padding: 8px 15px; cursor: pointer; transition: background 0.2s; }
        .context-menu li:hover { background: #f0f0f0; }
        .context-menu li.disabled { color: #999; cursor: not-allowed; }
        .context-menu li.disabled:hover { background: transparent; }
        .context-menu hr { margin: 5px 0; border: none; border-top: 1px solid #ddd; }
        .context-menu .menu-icon { margin-right: 10px; }
        
        /* Modal Styles */
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); justify-content: center; align-items: center; z-index: 1001; }
        .modal-content { background: white; padding: 20px; border-radius: 8px; min-width: 300px; max-width: 90%; }
        .modal-content h3 { margin-bottom: 15px; }
        .modal-content input, .modal-content select, .modal-content textarea { width: 100%; padding: 8px; margin: 10px 0; border: 1px solid #ddd; border-radius: 4px; }
        .modal-content textarea { font-family: monospace; min-height: 400px; }
        .modal-content button { padding: 8px 15px; margin-right: 10px; }
        .close { float: right; cursor: pointer; font-size: 20px; }
        .edit-container { padding: 20px; }
        .edit-header { margin-bottom: 20px; padding-bottom: 10px; border-bottom: 2px solid #ddd; }
        .btn { display: inline-block; padding: 8px 15px; margin: 5px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; }
        .btn-primary { background: #3498db; color: white; }
        .btn-primary:hover { background: #2980b9; }
        .btn-secondary { background: #95a5a6; color: white; }
        .btn-secondary:hover { background: #7f8c8d; }
        
        /* Advanced Compress Dropdown */
        .compress-dropdown { position: relative; display: inline-block; }
        .compress-btn { background: #27ae60; color: white; padding: 5px 10px; border: none; border-radius: 4px; cursor: pointer; }
        .compress-btn:hover { background: #229954; }
        .compress-menu { display: none; position: absolute; background: white; min-width: 180px; box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2); z-index: 1; border-radius: 4px; overflow: hidden; }
        .compress-menu a { color: black; padding: 10px 12px; text-decoration: none; display: block; cursor: pointer; transition: background 0.2s; }
        .compress-menu a:hover { background-color: #f1f1f1; }
        .compress-menu a.g7-option { background: linear-gradient(135deg, #f5f0ff 0%, #e8e0ff 100%); }
        .compress-menu a.g7-option:hover { background: linear-gradient(135deg, #e8e0ff 0%, #d8ccff 100%); }
        .compress-dropdown:hover .compress-menu { display: block; }
        
        /* Upload Zone */
        .upload-zone { border: 2px dashed #ddd; border-radius: 8px; padding: 30px; text-align: center; margin: 10px 20px; transition: all 0.3s; background: #fafafa; }
        .upload-zone.drag-over { border-color: #3498db; background: #e8f4fd; }
        .upload-zone .upload-icon { font-size: 48px; margin-bottom: 15px; }
        .upload-zone input[type="file"] { display: none; }
        .upload-zone .upload-btn { background: #3498db; color: white; padding: 8px 20px; border-radius: 4px; cursor: pointer; display: inline-block; margin-top: 10px; }
        .upload-zone .upload-btn:hover { background: #2980b9; }
        .file-list { margin-top: 15px; text-align: left; max-height: 150px; overflow-y: auto; }
        .file-list-item { padding: 5px; border-bottom: 1px solid #eee; font-size: 12px; display: flex; justify-content: space-between; }
        .upload-progress { width: 100%; height: 4px; background: #eee; border-radius: 2px; overflow: hidden; margin-top: 10px; display: none; }
        .upload-progress-bar { width: 0%; height: 100%; background: #27ae60; transition: width 0.3s; }
        
        /* G7 Info Panel */
        .g7-info-panel { position: fixed; bottom: 20px; right: 20px; background: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); padding: 10px 15px; max-width: 300px; z-index: 999; display: none; border-left: 4px solid #764ba2; }
        .g7-info-panel.show { display: block; animation: slideIn 0.3s ease-out; }
        .g7-info-panel h4 { margin: 0 0 5px 0; color: #764ba2; }
        .g7-info-panel p { margin: 5px 0; font-size: 12px; }
        .g7-info-panel .close-info { float: right; cursor: pointer; color: #999; }
        
        @keyframes slideIn {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: scale(0.9); }
            to { opacity: 1; transform: scale(1); }
        }
        
        .modal-content { animation: fadeIn 0.2s ease-out; }
        
        @media (max-width: 768px) {
            .toolbar { flex-direction: column; }
            .toolbar form, .toolbar div { width: 100%; }
            .toolbar input, .toolbar select, .toolbar button { width: 100%; }
            .compress-dropdown { width: 100%; }
            .compress-btn { width: 100%; }
            .compress-menu { width: 100%; position: static; display: none; }
            .compress-dropdown:hover .compress-menu { display: block; }
            th, td { font-size: 12px; padding: 8px; }
            .actions { flex-wrap: wrap; }
        }
        
        ::-webkit-scrollbar { width: 10px; height: 10px; }
        ::-webkit-scrollbar-track { background: #f1f1f1; }
        ::-webkit-scrollbar-thumb { background: #888; border-radius: 5px; }
        ::-webkit-scrollbar-thumb:hover { background: #555; }
        
        .custom-tooltip { position: absolute; background: #333; color: white; padding: 5px 10px; border-radius: 4px; font-size: 12px; z-index: 10000; white-space: nowrap; pointer-events: none; box-shadow: 0 2px 5px rgba(0,0,0,0.2); }
        button:disabled, button[disabled] { opacity: 0.5; cursor: not-allowed; }
        #fileTable tbody tr { transition: background 0.2s; }
        #fileTable tbody tr:hover { background: #f0f7ff; }
        
        .status-badge { display: inline-block; padding: 2px 6px; border-radius: 3px; font-size: 11px; font-weight: bold; }
        .status-badge.info { background: #3498db; color: white; }
        .status-badge.success { background: #27ae60; color: white; }
        
        .loading { display: inline-block; width: 20px; height: 20px; border: 3px solid #f3f3f3; border-top: 3px solid #3498db; border-radius: 50%; animation: spin 1s linear infinite; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        
        .topicons { font-size: 1.2em; margin-right: 5px; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <b>GoAdmio File Manager</b> 
        <?php echo "| <a href='https://{$_SERVER['HTTP_HOST']}/fm/{$_SESSION['SessionDomain']}/index.php' style='color:white;'>Basic</a>"; ?>
        <br>
        <small style="display: block; margin-top: 5px;">📍 Path: <?php echo htmlspecialchars($root_path); ?></small>
    </div>
    
    <?php if (!$is_editing): ?>
    <div class="breadcrumb">
        📂 Navigation: <?php echo $breadcrumb; ?>
        <?php if ($clipboard && is_array($clipboard['items'])): ?>
            <span style="float: right; background: #3498db; color: white; padding: 2px 8px; border-radius: 4px;">
                📋 <?php echo htmlspecialchars($clipboard['action']); ?> ready (<?php echo count($clipboard['items']); ?> items) 
                <a href="#" onclick="clearClipboard(); return false;" style="color: white; text-decoration: none; margin-left: 8px;">✖️</a>
            </span>
        <?php endif; ?>
    </div>
    <?php endif; ?>
    
    <?php echo $message; ?>
    
    <?php if ($is_editing): ?>
        <div class="edit-container">
            <div class="edit-header">
                <h2>✏️ Editing: <?php echo htmlspecialchars($edit_file); ?></h2>
                <a href="?path=<?php echo urlencode($current_path); ?>" class="btn btn-secondary">← Back to File Manager</a>
            </div>
            <form method="POST" id="editForm">
                <textarea name="file_content" style="width: 100%; min-height: 500px; font-family: monospace; padding: 10px; border: 1px solid #ddd; border-radius: 4px;"><?php echo htmlspecialchars($edit_content); ?></textarea>
                <div style="margin-top: 20px;">
                    <button type="submit" name="save_content" class="btn btn-primary">💾 Save File</button>
                    <a href="?path=<?php echo urlencode($current_path); ?>" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    <?php else: ?>
    
    <div class="toolbar">
        <!-- Enhanced Multi-File Upload Zone -->
        <div class="upload-zone" id="uploadZone">
            <div class="upload-icon">📁📄📁</div>
            <div>Drag & drop files here or click to select</div>
            <form id="uploadForm" method="POST" enctype="multipart/form-data" style="display: inline;">
                <input type="file" name="files[]" id="fileInput" multiple style="display: none;" onchange="uploadFiles(this.files)">
                <button type="button" class="upload-btn" onclick="document.getElementById('fileInput').click()">📤 Select Files</button>
                <input type="hidden" name="action" value="upload">
            </form>
            <div class="file-list" id="fileList"></div>
            <div class="upload-progress" id="uploadProgress">
                <div class="upload-progress-bar" id="uploadProgressBar"></div>
            </div>
            <div id="uploadStatus"></div>
        </div>
        
        <div style="display: inline-flex; gap: 5px;">
            <button type="button" class="success" onclick="showModal('mkdirModal')">📁 New Folder</button>
            <button type="button" onclick="submitAction('copy_to_clipboard')">📋 Copy</button>
            <button type="button" onclick="submitAction('cut_to_clipboard')">✂️ Cut</button>
            <button type="button" onclick="submitAction('paste')" <?php echo !$clipboard ? 'disabled' : ''; ?>>📎 Paste</button>
            <button type="button" class="danger" onclick="if(confirm('Delete selected items?')) submitAction('delete')">🗑️ Delete</button>
            <button type="button" class="warning" onclick="selectAllItems()">☐ Select All</button>
        </div>
        
        <button type="button" onclick="showModal('extractModal')">📦 Extract Archive</button>
        
        <div class="compress-dropdown">
            <button class="compress-btn">🗜️ Compress ▼</button>
            <div class="compress-menu">
                <a onclick="showCompressModal('zip')">📦 ZIP Archive</a>
                <a onclick="showCompressModal('rar')">💿 RAR Archive</a>
                <a onclick="showCompressModal('7z')">🗜️ 7z Archive</a>
                <a onclick="showCompressModal('tar.gz')">📀 TAR.GZ Archive</a>
                <a class="g7-option" onclick="showCompressModal('g7')">💎 G7 Archive (Advanced)</a>
            </div>
        </div>
        
        <span id="selectedCount" style="margin-left: auto; background: #e0e0e0; padding: 5px 10px; border-radius: 4px; font-size: 12px; display: none;">0 item(s) selected</span>
    </div>
    
    <form method="POST" id="mainForm">
        <input type="hidden" name="action" id="mainAction">
        <input type="hidden" name="items" id="mainSelectedItems">
        <input type="hidden" name="archive" id="archiveName">
        <input type="hidden" name="compress_folder" id="compressFolder">
        <input type="hidden" name="compress_type" id="compressType">
        <input type="hidden" name="old_name" id="oldName">
        <input type="hidden" name="new_name" id="newName">
        
        <table id="fileTable">
            <thead>
                <tr>
                    <th class="checkbox"><input type="checkbox" id="selectAll"></th>
                    <th>Name</th>
                    <th>Size</th>
                    <th>Modified</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php if ($current_path): ?>
                <tr data-name=".." data-is-dir="true">
                    <td class="checkbox"><input type="checkbox" class="item-checkbox" value=".." disabled></td>
                    <td colspan="4"><a href="?path=<?php echo urlencode(dirname($current_path)); ?>" style="text-decoration: none;">🔙 .. (Parent Directory)</a></td>
                </tr>
                <?php endif; ?>
                
                <?php foreach ($items as $index => $item): ?>
                <tr data-name="<?php echo htmlspecialchars($item['name']); ?>" data-is-dir="<?php echo $item['is_dir'] ? 'true' : 'false'; ?>" data-path="<?php echo htmlspecialchars($item['path']); ?>" data-web-url="<?php echo htmlspecialchars($item['web_url']); ?>" data-index="<?php echo $index; ?>" data-is-archive="<?php echo $item['is_archive'] ? 'true' : 'false'; ?>">
                    <td class="checkbox"><input type="checkbox" name="selected_items[]" value="<?php echo htmlspecialchars($item['name']); ?>" class="item-checkbox"></td>
                    <td>
                        <?php if ($item['is_dir']): ?>
                            <a href="?path=<?php echo urlencode($current_path . ($current_path ? '/' : '') . $item['name']); ?>" class="folder">
                                <span class="file-icon">📁</span> <?php echo htmlspecialchars($item['name']); ?>
                            </a>
                        <?php else: ?>
                            <span class="file">
                                <span class="file-icon"><?php echo $item['icon']; ?></span> <?php echo htmlspecialchars($item['name']); ?>
                                <?php if (preg_match('/\.g7$/i', $item['name'])): ?>
                                    <span class="g7-badge" onclick="event.stopPropagation(); viewG7Info('<?php echo htmlspecialchars($item['name']); ?>')" style="cursor: pointer;">G7</span>
                                <?php endif; ?>
                            </span>
                        <?php endif; ?>
                    </td>
                    <td><?php echo $item['is_dir'] ? '&lt;DIR&gt;' : formatSize($item['size']); ?></td>
                    <td><?php echo htmlspecialchars($item['modified']); ?></td>
                    <td class="actions">
                        <?php if (!$item['is_dir']): ?>
                            <a href="<?php echo htmlspecialchars($item['web_url']); ?>" download style="text-decoration: none;" title="Download">⬇️</a>
                        <?php endif; ?>
                        <?php if (!$item['is_dir'] && $item['is_text']): ?>
                            <a href="?path=<?php echo urlencode($current_path); ?>&edit=<?php echo urlencode($item['name']); ?>" style="text-decoration: none;" title="Edit File">✏️</a>
                        <?php endif; ?>
                        <?php if ($item['is_dir']): ?>
                            <div class="compress-dropdown" style="display: inline-block;">
                                <button type="button" onclick="event.stopPropagation(); showCompressModalForFolder('<?php echo htmlspecialchars($item['name']); ?>')" style="padding: 2px 5px;" title="Compress Folder">🗜️</button>
                            </div>
                        <?php else: ?>
                            <?php if ($item['is_archive']): ?>
                                <button type="button" onclick="extractSpecificArchive('<?php echo htmlspecialchars($item['name']); ?>')" style="padding: 2px 5px;" title="Extract Archive">📦</button>
                            <?php endif; ?>
                        <?php endif; ?>
                        <button type="button" onclick="showRenameModal('<?php echo htmlspecialchars($item['name']); ?>')" style="padding: 2px 5px;" title="Rename">✏️</button>
                    </td>
                </tr>
                <?php endforeach; ?>
                <?php if (empty($items) && !$current_path): ?>
                <tr>
                    <td colspan="5" style="text-align: center; padding: 40px;">📂 Directory is empty. Upload files or create a folder to get started!</td>
                </tr>
                <?php endif; ?>
            </tbody>
        </table>
    </form>

    <div id="contextMenu" class="context-menu">
        <ul>
            <li id="menu-open" style="display: none;" onclick="contextMenuAction('open')"><span class="menu-icon">📂</span> Open</li>
            <li id="menu-download" style="display: none;" onclick="contextMenuAction('download')"><span class="menu-icon">⬇️</span> Download</li>
            <li id="menu-edit" style="display: none;" onclick="contextMenuAction('edit')"><span class="menu-icon">✏️</span> Edit</li>
            <li id="menu-extract" style="display: none;" onclick="contextMenuAction('extract')"><span class="menu-icon">📦</span> Extract Archive</li>
            <li id="menu-compress" style="display: none;" onclick="contextMenuAction('compress')"><span class="menu-icon">🗜️</span> Compress</li>
            <li onclick="contextMenuAction('rename')"><span class="menu-icon">✏️</span> Rename</li>
            <li onclick="contextMenuAction('copy')"><span class="menu-icon">📋</span> Copy</li>
            <li onclick="contextMenuAction('cut')"><span class="menu-icon">✂️</span> Cut</li>
            <li onclick="contextMenuAction('paste')" id="menu-paste"><span class="menu-icon">📎</span> Paste</li>
            <li><hr></li>
            <li onclick="contextMenuAction('delete')" style="color: #e74c3c;"><span class="menu-icon">🗑️</span> Delete</li>
        </ul>
    </div>

    <div id="mkdirModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('mkdirModal')">&times;</span>
            <h3>Create New Folder</h3>
            <form method="POST">
                <input type="text" name="dirname" placeholder="Folder name" required>
                <input type="hidden" name="action" value="mkdir">
                <button type="submit">Create</button>
                <button type="button" onclick="closeModal('mkdirModal')">Cancel</button>
            </form>
        </div>
    </div>

    <div id="extractModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('extractModal')">&times;</span>
            <h3>Extract Archive</h3>
            <form method="POST">
                <select name="archive" required>
                    <option value="">Select archive to extract</option>
                    <?php foreach ($items as $item): ?>
                        <?php if (!$item['is_dir'] && $item['is_archive']): ?>
                            <option value="<?php echo htmlspecialchars($item['name']); ?>"><?php echo htmlspecialchars($item['name']); ?></option>
                        <?php endif; ?>
                    <?php endforeach; ?>
                </select>
                <input type="hidden" name="action" value="extract">
                <button type="submit">Extract</button>
                <button type="button" onclick="closeModal('extractModal')">Cancel</button>
            </form>
        </div>
    </div>

    <div id="compressModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('compressModal')">&times;</span>
            <h3>Compress Folder</h3>
            <form method="POST">
                <select name="compress_folder" id="compressFolderSelect" required>
                    <option value="">Select folder to compress</option>
                    <?php foreach ($items as $item): ?>
                        <?php if ($item['is_dir']): ?>
                            <option value="<?php echo htmlspecialchars($item['name']); ?>"><?php echo htmlspecialchars($item['name']); ?></option>
                        <?php endif; ?>
                    <?php endforeach; ?>
                </select>
                <select name="compress_type" id="compressTypeSelect" required>
                    <option value="zip">ZIP - Standard compression</option>
                    <option value="rar">RAR - WinRAR compression</option>
                    <option value="7z">7z - High compression ratio</option>
                    <option value="tar.gz">TAR.GZ - GZipped TAR archive</option>
                    <option value="g7" style="background: #e8e0ff;">G7 - Advanced PHP compression (Recommended)</option>
                </select>
                <input type="hidden" name="action" value="compress">
                <button type="submit">Compress</button>
                <button type="button" onclick="closeModal('compressModal')">Cancel</button>
            </form>
        </div>
    </div>


<div id="renameModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('renameModal')">&times;</span>
            <h3>Rename Item</h3>
            <input type="text" id="renameOldName" readonly style="background: #f0f0f0;">
            <input type="text" id="renameNewName" placeholder="New name" required>
            <div style="margin-top: 15px;">
                <button onclick="submitRename()" class="btn-primary">Rename</button>
                <button onclick="closeModal('renameModal')" class="btn-secondary">Cancel</button>
            </div>
        </div>
    </div>

    <?php endif; ?>
</div>

<script>
let currentContextItem = null;
let currentContextItemName = null;
let currentContextItemIsDir = false;
let currentContextItemPath = null;
let currentContextItemWebUrl = null;
let currentContextItemIsArchive = false;
let currentSelectedItems = [];

// Drag and drop upload zone
const uploadZone = document.getElementById('uploadZone');
const fileInput = document.getElementById('fileInput');
const fileList = document.getElementById('fileList');
const uploadProgress = document.getElementById('uploadProgress');
const uploadProgressBar = document.getElementById('uploadProgressBar');

if (uploadZone) {
    uploadZone.addEventListener('dragover', function(e) {
        e.preventDefault();
        uploadZone.classList.add('drag-over');
    });
    
    uploadZone.addEventListener('dragleave', function(e) {
        e.preventDefault();
        uploadZone.classList.remove('drag-over');
    });
    
    uploadZone.addEventListener('drop', function(e) {
        e.preventDefault();
        uploadZone.classList.remove('drag-over');
        const files = e.dataTransfer.files;
        if (files.length > 0) {
            uploadFiles(files);
        }
    });
}

function uploadFiles(files) {
    if (!files || files.length === 0) return;
    
    const formData = new FormData();
    let validFiles = 0;
    
    for (let i = 0; i < files.length; i++) {
        const file = files[i];
        if (file.size > 0) {
            formData.append('files[]', file);
            validFiles++;
        }
    }
    
    if (validFiles === 0) {
        showUploadStatus('No valid files selected', 'error');
        return;
    }
    
    // Show file list
    fileList.innerHTML = '';
    for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const fileItem = document.createElement('div');
        fileItem.className = 'file-list-item';
        fileItem.innerHTML = `<span>📄 ${escapeHtml(file.name)}</span><span>${formatFileSize(file.size)}</span>`;
        fileList.appendChild(fileItem);
    }
    
    formData.append('action', 'upload');
    
    uploadProgress.style.display = 'block';
    uploadProgressBar.style.width = '50%';
    showUploadStatus(`Uploading ${validFiles} file(s)...`, 'info');
    
    // Use XMLHttpRequest for progress tracking
    const xhr = new XMLHttpRequest();
    xhr.open('POST', window.location.href, true);
    
    xhr.upload.addEventListener('progress', function(e) {
        if (e.lengthComputable) {
            const percent = (e.loaded / e.total) * 100;
            uploadProgressBar.style.width = percent + '%';
        }
    });
    
    xhr.onload = function() {
        uploadProgress.style.display = 'none';
        uploadProgressBar.style.width = '0%';
        if (xhr.status === 200) {
            showUploadStatus('Upload complete! Refreshing...', 'success');
            setTimeout(() => {
                location.reload();
            }, 1000);
        } else {
            showUploadStatus('Upload failed. Please try again.', 'error');
        }
        setTimeout(() => {
            fileList.innerHTML = '';
        }, 3000);
    };
    
    xhr.onerror = function() {
        uploadProgress.style.display = 'none';
        showUploadStatus('Upload failed. Please try again.', 'error');
        setTimeout(() => {
            fileList.innerHTML = '';
        }, 3000);
    };
    
    xhr.send(formData);
}

function showUploadStatus(message, type) {
    const statusDiv = document.getElementById('uploadStatus');
    if (statusDiv) {
        statusDiv.innerHTML = `<div class="alert alert-${type}" style="margin: 10px 0 0 0; padding: 5px;">${message}</div>`;
        setTimeout(() => {
            if (statusDiv.innerHTML) statusDiv.innerHTML = '';
        }, 5000);
    }
}

function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

document.addEventListener('contextmenu', function(e) {
    let target = e.target;
    let row = null;
    
    while (target && target.tagName !== 'TR') {
        target = target.parentElement;
    }
    
    if (target && target.tagName === 'TR' && target.dataset.name && target.dataset.name !== '..') {
        e.preventDefault();
        currentContextItem = target;
        currentContextItemName = target.dataset.name;
        currentContextItemIsDir = target.dataset.isDir === 'true';
        currentContextItemPath = target.dataset.path;
        currentContextItemWebUrl = target.dataset.webUrl;
        currentContextItemIsArchive = target.dataset.isArchive === 'true';
        
        const menuOpen = document.getElementById('menu-open');
        const menuDownload = document.getElementById('menu-download');
        const menuEdit = document.getElementById('menu-edit');
        const menuExtract = document.getElementById('menu-extract');
        const menuCompress = document.getElementById('menu-compress');
        
        if (currentContextItemIsDir) {
            if (menuOpen) menuOpen.style.display = 'block';
            if (menuDownload) menuDownload.style.display = 'none';
            if (menuEdit) menuEdit.style.display = 'none';
            if (menuExtract) menuExtract.style.display = 'none';
            if (menuCompress) menuCompress.style.display = 'block';
        } else {
            if (menuOpen) menuOpen.style.display = 'none';
            if (menuDownload) menuDownload.style.display = 'block';
            if (menuEdit) {
                const isText = <?php 
                    $textFiles = [];
                    foreach ($items as $item) {
                        if (!$item['is_dir'] && $item['is_text']) {
                            $textFiles[] = $item['name'];
                        }
                    }
                    echo json_encode($textFiles);
                ?>;
                menuEdit.style.display = isText.includes(currentContextItemName) ? 'block' : 'none';
            }
            
            const isArchive = currentContextItemIsArchive;
            if (menuExtract) menuExtract.style.display = isArchive ? 'block' : 'none';
            if (menuCompress) menuCompress.style.display = 'none';
        }
        
        const hasClipboard = <?php echo $clipboard ? 'true' : 'false'; ?>;
        const menuPaste = document.getElementById('menu-paste');
        if (menuPaste) {
            if (!hasClipboard) {
                menuPaste.style.opacity = '0.5';
                menuPaste.style.pointerEvents = 'none';
            } else {
                menuPaste.style.opacity = '1';
                menuPaste.style.pointerEvents = 'auto';
            }
        }
        
        const contextMenu = document.getElementById('contextMenu');
        contextMenu.style.display = 'block';
        contextMenu.style.left = e.pageX + 'px';
        contextMenu.style.top = e.pageY + 'px';
    } else {
        document.getElementById('contextMenu').style.display = 'none';
    }
});

document.addEventListener('click', function() {
    document.getElementById('contextMenu').style.display = 'none';
});

function contextMenuAction(action) {
    const contextMenu = document.getElementById('contextMenu');
    contextMenu.style.display = 'none';
    
    if (!currentContextItem) return;
    
    switch(action) {
        case 'open':
            if (currentContextItemIsDir) {
                window.location.href = '?path=<?php echo urlencode($current_path); ?>' + (<?php echo json_encode($current_path); ?> ? '/' : '') + encodeURIComponent(currentContextItemName);
            }
            break;
        case 'download':
            if (!currentContextItemIsDir && currentContextItemWebUrl) {
                window.location.href = currentContextItemWebUrl;
            }
            break;
        case 'edit':
            if (!currentContextItemIsDir) {
                window.location.href = '?path=<?php echo urlencode($current_path); ?>&edit=' + encodeURIComponent(currentContextItemName);
            }
            break;
        case 'extract':
            if (confirm('Extract ' + currentContextItemName + '?')) {
                document.getElementById('mainAction').value = 'extract';
                document.getElementById('archiveName').value = currentContextItemName;
                document.getElementById('mainForm').submit();
            }
            break;
        case 'compress':
            showCompressModalForFolder(currentContextItemName);
            break;
        case 'rename':
            showRenameModal(currentContextItemName);
            break;
        case 'copy':
            const copyItems = [currentContextItemName];
            document.getElementById('mainAction').value = 'copy_to_clipboard';
            document.getElementById('mainSelectedItems').value = JSON.stringify(copyItems);
            document.getElementById('mainForm').submit();
            break;
        case 'cut':
            const cutItems = [currentContextItemName];
            document.getElementById('mainAction').value = 'cut_to_clipboard';
            document.getElementById('mainSelectedItems').value = JSON.stringify(cutItems);
            document.getElementById('mainForm').submit();
            break;
        case 'paste':
            if (<?php echo $clipboard ? 'true' : 'false'; ?>) {
                document.getElementById('mainAction').value = 'paste';
                document.getElementById('mainForm').submit();
            }
            break;
        case 'delete':
            if (confirm('Delete ' + currentContextItemName + '?')) {
                const deleteItems = [currentContextItemName];
                document.getElementById('mainAction').value = 'delete';
                document.getElementById('mainSelectedItems').value = JSON.stringify(deleteItems);
                document.getElementById('mainForm').submit();
            }
            break;
    }
}

function showModal(id) {
    document.getElementById(id).style.display = 'flex';
}

function closeModal(id) {
    document.getElementById(id).style.display = 'none';
}

function showRenameModal(itemName) {
    document.getElementById('renameOldName').value = itemName;
    document.getElementById('renameNewName').value = itemName;
    showModal('renameModal');
}

function submitRename() {
    const oldName = document.getElementById('renameOldName').value;
    const newName = document.getElementById('renameNewName').value;
    
    if (!newName || newName === oldName) {
        closeModal('renameModal');
        return;
    }
    
    document.getElementById('mainAction').value = 'rename';
    document.getElementById('oldName').value = oldName;
    document.getElementById('newName').value = newName;
    document.getElementById('mainForm').submit();
}

function submitAction(action) {
    var checkboxes = document.querySelectorAll('.item-checkbox:checked');
    var selected = [];
    checkboxes.forEach(function(cb) {
        if (cb.value !== '..') {
            selected.push(cb.value);
        }
    });
    
    if (selected.length === 0 && action !== 'paste') {
        alert('Please select at least one item');
        return false;
    }
    
    document.getElementById('mainAction').value = action;
    document.getElementById('mainSelectedItems').value = JSON.stringify(selected);
    document.getElementById('mainForm').submit();
    return true;
}

function clearClipboard() {
    if (confirm('Clear clipboard?')) {
        document.getElementById('mainAction').value = 'clear_clipboard';
        document.getElementById('mainForm').submit();
    }
}

function selectAllItems() {
    const selectAll = document.getElementById('selectAll');
    if (selectAll) {
        selectAll.checked = !selectAll.checked;
        const event = new Event('change');
        selectAll.dispatchEvent(event);
    }
}

function extractSpecificArchive(archive) {
    if (confirm('Extract ' + archive + '?')) {
        document.getElementById('mainAction').value = 'extract';
        document.getElementById('archiveName').value = archive;
        document.getElementById('mainForm').submit();
    }
}

function showCompressModal(compressType) {
    const folderSelect = document.getElementById('compressFolderSelect');
    if (folderSelect && folderSelect.value) {
        document.getElementById('compressType').value = compressType;
        document.getElementById('compressFolder').value = folderSelect.value;
        document.getElementById('mainAction').value = 'compress';
        document.getElementById('mainForm').submit();
    } else {
        const modal = document.getElementById('compressModal');
        if (modal) {
            const typeSelect = document.getElementById('compressTypeSelect');
            if (typeSelect) {
                for(let i = 0; i < typeSelect.options.length; i++) {
                    if(typeSelect.options[i].value === compressType) {
                        typeSelect.selectedIndex = i;
                        break;
                    }
                }
            }
            showModal('compressModal');
        } else {
            alert('Please select a folder to compress');
        }
    }
}

function showCompressModalForFolder(folderName) {
    const folderSelect = document.getElementById('compressFolderSelect');
    if (folderSelect) {
        for(let i = 0; i < folderSelect.options.length; i++) {
            if(folderSelect.options[i].value === folderName) {
                folderSelect.selectedIndex = i;
                break;
            }
        }
    }
    showModal('compressModal');
}

function viewG7Info(archiveName) {
    const formData = new FormData();
    formData.append('action', 'view_g7_info');
    formData.append('archive', archiveName);
    
    fetch(window.location.href, {
        method: 'POST',
        body: formData
    }).then(response => response.text()).then(() => {
        // Reload to show message
        location.reload();
    }).catch(error => console.error('Error:', error));
}

function closeG7InfoPanel() {
    document.getElementById('g7InfoPanel').classList.remove('show');
}

// Select all checkbox
if (document.getElementById('selectAll')) {
    document.getElementById('selectAll').addEventListener('change', function(e) {
        document.querySelectorAll('.item-checkbox').forEach(cb => {
            if (cb.value !== '..') {
                cb.checked = e.target.checked;
            }
        });
        updateSelectedCount();
    });
}

// Close modals when clicking outside
window.onclick = function(event) {
    if (event.target.classList && event.target.classList.contains('modal')) {
        event.target.style.display = 'none';
    }
}

// Keyboard shortcuts
document.addEventListener('keydown', function(e) {
    // Ctrl+C for copy
    if (e.ctrlKey && e.key === 'c') {
        e.preventDefault();
        const selected = document.querySelectorAll('.item-checkbox:checked');
        if (selected.length > 0) {
            submitAction('copy_to_clipboard');
        }
    }
    
    // Ctrl+X for cut
    if (e.ctrlKey && e.key === 'x') {
        e.preventDefault();
        const selected = document.querySelectorAll('.item-checkbox:checked');
        if (selected.length > 0) {
            submitAction('cut_to_clipboard');
        }
    }
    
    // Ctrl+V for paste
    if (e.ctrlKey && e.key === 'v') {
        e.preventDefault();
        submitAction('paste');
    }
    
    // Ctrl+A for select all
    if (e.ctrlKey && e.key === 'a') {
        e.preventDefault();
        selectAllItems();
    }
    
    // Delete key for delete
    if (e.key === 'Delete') {
        e.preventDefault();
        const selected = document.querySelectorAll('.item-checkbox:checked');
        if (selected.length > 0 && confirm('Delete selected items?')) {
            submitAction('delete');
        }
    }
    
    // F2 for rename
    if (e.key === 'F2') {
        e.preventDefault();
        const selected = document.querySelectorAll('.item-checkbox:checked');
        if (selected.length === 1) {
            showRenameModal(selected[0].value);
        } else if (selected.length > 1) {
            alert('Please select only one item to rename');
        }
    }
    
    // Ctrl+G for G7 info (if a G7 file is selected)
    if (e.ctrlKey && e.key === 'g') {
        e.preventDefault();
        const selected = document.querySelectorAll('.item-checkbox:checked');
        if (selected.length === 1 && selected[0].value.match(/\.g7$/i)) {
            viewG7Info(selected[0].value);
        } else if (selected.length === 1) {
            alert('Selected item is not a G7 archive');
        } else {
            alert('Please select exactly one G7 archive');
        }
    }
});

// Tooltip for better UX
const tooltips = document.querySelectorAll('[title]');
tooltips.forEach(el => {
    el.addEventListener('mouseenter', function(e) {
        const title = this.getAttribute('title');
        if (!title) return;
        
        const tooltip = document.createElement('div');
        tooltip.className = 'custom-tooltip';
        tooltip.textContent = title;
        tooltip.style.position = 'absolute';
        tooltip.style.background = '#333';
        tooltip.style.color = 'white';
        tooltip.style.padding = '5px 10px';
        tooltip.style.borderRadius = '4px';
        tooltip.style.fontSize = '12px';
        tooltip.style.zIndex = '10000';
        tooltip.style.whiteSpace = 'nowrap';
        
        document.body.appendChild(tooltip);
        
        const rect = this.getBoundingClientRect();
        tooltip.style.left = rect.left + window.scrollX + 'px';
        tooltip.style.top = rect.bottom + window.scrollY + 5 + 'px';
        
        this.addEventListener('mouseleave', function() {
            tooltip.remove();
        }, { once: true });
    });
});

// Add double-click to edit text files
document.querySelectorAll('#fileTable tbody tr[data-is-dir="false"]').forEach(row => {
    row.addEventListener('dblclick', function() {
        const fileName = this.dataset.name;
        const isTextFile = <?php 
            $textFileList = [];
            foreach ($items as $item) {
                if (!$item['is_dir'] && $item['is_text']) {
                    $textFileList[] = $item['name'];
                }
            }
            echo json_encode($textFileList);
        ?>;
        
        if (isTextFile.includes(fileName)) {
            window.location.href = '?path=<?php echo urlencode($current_path); ?>&edit=' + encodeURIComponent(fileName);
        }
    });
});

// Show selected count
function updateSelectedCount() {
    const selected = document.querySelectorAll('.item-checkbox:checked').length;
    let countDisplay = document.getElementById('selectedCount');
    if (!countDisplay) {
        const toolbar = document.querySelector('.toolbar');
        if (toolbar) {
            const span = document.createElement('span');
            span.id = 'selectedCount';
            span.style.cssText = 'margin-left: auto; background: #e0e0e0; padding: 5px 10px; border-radius: 4px; font-size: 12px;';
            toolbar.appendChild(span);
            countDisplay = span;
        }
    }
    if (countDisplay) {
        countDisplay.textContent = selected + ' item(s) selected';
        countDisplay.style.display = selected > 0 ? 'inline-block' : 'none';
    }
}

document.querySelectorAll('.item-checkbox').forEach(cb => {
    cb.addEventListener('change', updateSelectedCount);
});

updateSelectedCount();

// Progress indicator for long operations
document.querySelectorAll('form').forEach(form => {
    form.addEventListener('submit', function() {
        const submitBtn = this.querySelector('button[type="submit"]');
        if (submitBtn) {
            submitBtn.disabled = true;
            const originalText = submitBtn.textContent;
            submitBtn.textContent = '⏳ Processing...';
            
            setTimeout(function() {
                if (submitBtn.disabled) {
                    submitBtn.disabled = false;
                    submitBtn.textContent = originalText;
                }
            }, 10000);
        }
    });
});

// G7 Drag and Drop upload support
const fileTable = document.getElementById('fileTable');
if (fileTable) {
    fileTable.addEventListener('dragover', function(e) {
        e.preventDefault();
        fileTable.style.opacity = '0.8';
    });
    
    fileTable.addEventListener('dragleave', function(e) {
        e.preventDefault();
        fileTable.style.opacity = '1';
    });
    
    fileTable.addEventListener('drop', function(e) {
        e.preventDefault();
        fileTable.style.opacity = '1';
        
        const files = e.dataTransfer.files;
        if (files.length > 0) {
            uploadFiles(files);
        }
    });
}

console.log('G7 File Manager Loaded Successfully!');
console.log('💎 G7 Compression Support Enabled');
console.log('📤 Multi-file upload support enabled');
</script>

<style>
    /* Additional styles for custom tooltips and improvements */
    .custom-tooltip {
        position: absolute;
        background: #333;
        color: white;
        padding: 5px 10px;
        border-radius: 4px;
        font-size: 12px;
        z-index: 10000;
        white-space: nowrap;
        pointer-events: none;
        box-shadow: 0 2px 5px rgba(0,0,0,0.2);
    }
    
    .context-menu li.danger {
        color: #e74c3c;
    }
    
    .context-menu li.danger:hover {
        background: #fee;
    }
    
    button:disabled, button[disabled] {
        opacity: 0.5;
        cursor: not-allowed;
    }
    
    #fileTable tbody tr {
        transition: background 0.2s;
    }
    
    #fileTable tbody tr:hover {
        background: #f0f7ff;
    }
    
    .compress-dropdown {
        position: relative;
        display: inline-block;
    }
    
    .compress-btn {
        background: #27ae60;
        color: white;
        padding: 5px 10px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        transition: background 0.2s;
    }
    
    .compress-btn:hover {
        background: #229954;
    }
    
    .compress-menu {
        display: none;
        position: absolute;
        background: white;
        min-width: 180px;
        box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
        z-index: 1;
        border-radius: 4px;
        overflow: hidden;
    }
    
    .compress-menu a {
        color: black;
        padding: 10px 12px;
        text-decoration: none;
        display: block;
        cursor: pointer;
        transition: background 0.2s;
    }
    
    .compress-menu a:hover {
        background-color: #f1f1f1;
    }
    
    .compress-menu a.g7-option {
        background: linear-gradient(135deg, #f5f0ff 0%, #e8e0ff 100%);
        font-weight: 500;
    }
    
    .compress-menu a.g7-option:hover {
        background: linear-gradient(135deg, #e8e0ff 0%, #d8ccff 100%);
    }
    
    .compress-dropdown:hover .compress-menu {
        display: block;
    }
    
    /* Animation for modals */
    @keyframes fadeIn {
        from { opacity: 0; transform: scale(0.9); }
        to { opacity: 1; transform: scale(1); }
    }
    
    .modal-content {
        animation: fadeIn 0.2s ease-out;
    }
    
    /* Upload zone styles */
    .upload-zone {
        border: 2px dashed #ddd;
        border-radius: 8px;
        padding: 20px;
        text-align: center;
        margin: 0;
        transition: all 0.3s;
        background: #fafafa;
        flex: 1;
    }
    
    .upload-zone.drag-over {
        border-color: #3498db;
        background: #e8f4fd;
    }
    
    .upload-zone .upload-icon {
        font-size: 32px;
        margin-bottom: 10px;
    }
    
    .upload-zone .upload-btn {
        background: #3498db;
        color: white;
        padding: 6px 16px;
        border-radius: 4px;
        cursor: pointer;
        display: inline-block;
        margin-top: 8px;
        border: none;
    }
    
    .upload-zone .upload-btn:hover {
        background: #2980b9;
    }
    
    .file-list {
        margin-top: 10px;
        text-align: left;
        max-height: 100px;
        overflow-y: auto;
        font-size: 12px;
    }
    
    .file-list-item {
        padding: 4px;
        border-bottom: 1px solid #eee;
        display: flex;
        justify-content: space-between;
    }
    
    .upload-progress {
        width: 100%;
        height: 4px;
        background: #eee;
        border-radius: 2px;
        overflow: hidden;
        margin-top: 10px;
        display: none;
    }
    
    .upload-progress-bar {
        width: 0%;
        height: 100%;
        background: #27ae60;
        transition: width 0.3s;
    }
    
    /* Responsive improvements */
    @media (max-width: 768px) {
        .toolbar {
            flex-direction: column;
        }
        
        .toolbar form,
        .toolbar div {
            width: 100%;
        }
        
        .toolbar input,
        .toolbar select,
        .toolbar button {
            width: 100%;
        }
        
        .compress-dropdown {
            width: 100%;
        }
        
        .compress-btn {
            width: 100%;
        }
        
        .compress-menu {
            width: 100%;
            position: static;
            display: none;
        }
        
        .compress-dropdown:hover .compress-menu {
            display: block;
        }
        
        th, td {
            font-size: 12px;
            padding: 8px;
        }
        
        .actions {
            flex-wrap: wrap;
        }
        
        .actions a,
        .actions button {
            font-size: 16px;
            padding: 4px 8px;
        }
        
        .upload-zone {
            padding: 12px;
        }
    }
    
    /* Scrollbar styling */
    ::-webkit-scrollbar {
        width: 10px;
        height: 10px;
    }
    
    ::-webkit-scrollbar-track {
        background: #f1f1f1;
    }
    
    ::-webkit-scrollbar-thumb {
        background: #888;
        border-radius: 5px;
    }
    
    ::-webkit-scrollbar-thumb:hover {
        background: #555;
    }
    
    /* Status indicators */
    .status-badge {
        display: inline-block;
        padding: 2px 6px;
        border-radius: 3px;
        font-size: 11px;
        font-weight: bold;
    }
    
    .status-badge.info {
        background: #3498db;
        color: white;
    }
    
    .status-badge.success {
        background: #27ae60;
        color: white;
    }
    
    /* Loading spinner */
    .loading {
        display: inline-block;
        width: 20px;
        height: 20px;
        border: 3px solid #f3f3f3;
        border-top: 3px solid #3498db;
        border-radius: 50%;
        animation: spin 1s linear infinite;
    }
    
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    
    /* G7 specific styling */
    .g7-badge {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        font-size: 10px;
        padding: 2px 6px;
        border-radius: 10px;
        margin-left: 8px;
        display: inline-block;
        cursor: pointer;
        transition: transform 0.2s;
    }
    
    .g7-badge:hover {
        transform: scale(1.05);
    }
    
    button.g7 {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }
    
    button.g7:hover {
        background: linear-gradient(135deg, #5a67d8 0%, #6b46a0 100%);
    }
    
    .g7-info-panel {
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: white;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        padding: 12px 16px;
        max-width: 320px;
        z-index: 999;
        display: none;
        border-left: 4px solid #764ba2;
    }
    
    .g7-info-panel.show {
        display: block;
        animation: slideIn 0.3s ease-out;
    }
    
    .g7-info-panel .close-info {
        float: right;
        cursor: pointer;
        color: #999;
        font-size: 18px;
        line-height: 1;
    }
    
    .g7-info-panel .close-info:hover {
        color: #333;
    }
    
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    /* File type specific styling */
    .file .file-icon {
        font-size: 18px;
        display: inline-block;
        width: 24px;
        text-align: center;
    }
    
    /* Table row selection styling */
    #fileTable tbody tr.selected {
        background-color: #e8f0fe;
    }
    
    /* Action buttons hover effects */
    .actions a, .actions button {
        opacity: 0.7;
        transition: opacity 0.2s, transform 0.2s;
        background: transparent;
        border: none;
        cursor: pointer;
        font-size: 16px;
    }
    
    .actions a:hover, .actions button:hover {
        opacity: 1;
        transform: scale(1.1);
    }
    
    /* Form input focus effects */
    input:focus, select:focus, textarea:focus, button:focus {
        outline: none;
        box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.4);
    }
    
    /* Success/Error message animations */
    .alert {
        animation: slideDown 0.3s ease-out;
    }
    
    @keyframes slideDown {
        from {
            transform: translateY(-20px);
            opacity: 0;
        }
        to {
            transform: translateY(0);
            opacity: 1;
        }
    }
</style>

</body>
</html>
