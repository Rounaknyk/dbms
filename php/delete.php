<?php
// delete_employee.php

$servername = "localhost";
$username = "root";  // Adjust this if your database has a different username
$password = "";      // Adjust if there's a database password
$dbname = "dummy";   // Your database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if (isset($_POST['id'])) {
    $id = $_POST['id'];

    // Prepare DELETE statement
    $stmt = $conn->prepare("DELETE FROM Employee WHERE id = ?");
    $stmt->bind_param("i", $id);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Employee deleted successfully."]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to delete employee."]);
    }

    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Employee ID not provided."]);
}

$conn->close();
?>
