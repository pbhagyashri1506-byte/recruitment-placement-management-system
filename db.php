<?php
$host = "localhost";
$user = "root";
$password = "";
$database = "rpms_db";

// Create database connection
$conn = mysqli_connect($host, $user, $password, $database);

// Check connection
if (!$conn) {
    die("Database Connection Failed: " . mysqli_connect_error());
}
?>
