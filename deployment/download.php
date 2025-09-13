<?php
// Simple APK Download Handler
// File: download.php

// Set the path to your APK file
$apkFile = __DIR__ . '/downloads/oz3-kpi.apk';
$fileName = 'OZ3-KPI-v1.0.0.apk';

// Check if file exists
if (!file_exists($apkFile)) {
    http_response_code(404);
    die('File not found');
}

// Get file info
$fileSize = filesize($apkFile);
$lastModified = filemtime($apkFile);

// Set headers for APK download
header('Content-Type: application/vnd.android.package-archive');
header('Content-Disposition: attachment; filename="' . $fileName . '"');
header('Content-Length: ' . $fileSize);
header('Cache-Control: must-revalidate');
header('Pragma: public');
header('Last-Modified: ' . gmdate('D, d M Y H:i:s', $lastModified) . ' GMT');

// Optional: Log download
$logEntry = date('Y-m-d H:i:s') . " - " . $_SERVER['REMOTE_ADDR'] . " - Downloaded: $fileName\n";
file_put_contents(__DIR__ . '/downloads/download_log.txt', $logEntry, FILE_APPEND | LOCK_EX);

// Stream the file
readfile($apkFile);
exit;
?>