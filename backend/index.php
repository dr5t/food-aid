<?php
header("Content-Type: application/json");

// Simple PHP API for Food Aid App
$response = [
    "status" => "success",
    "message" => "Food Aid Backend Operational",
    "version" => "1.0.0",
    "timestamp" => date("Y-m-d H:i:s")
];

echo json_encode($response);
?>
