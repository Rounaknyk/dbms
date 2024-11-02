<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "dummy";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode([
        'status' => 'error',
        'message' => 'Connection failed: ' . $conn->connect_error
    ]));
}

// Get POST data
$data = json_decode(file_get_contents('php://input'), true);

try {
    // Start transaction
    $conn->begin_transaction();

    // Insert into Staff table
    $stmt = $conn->prepare("INSERT INTO Staff (staff_id, staff_name, department) VALUES (?, ?, ?)");
    $stmt->bind_param("iss",
        $data['staffId'],
        $data['staffName'],
        $data['department']
    );

    if (!$stmt->execute()) {
        throw new Exception("Error creating staff: " . $stmt->error);
    }

    // Insert employees into Staff_Employees table
    $stmt2 = $conn->prepare("INSERT INTO Staff_Employees (staff_id, employee_id, is_manager) VALUES (?, ?, ?)");

    foreach ($data['employees'] as $employee) {
        $isManager = $employee['isManager'] ? 1 : 0;
        $stmt2->bind_param("iii",
            $data['staffId'],
            $employee['id'],
            $isManager
        );

        if (!$stmt2->execute()) {
            throw new Exception("Error adding employee to staff: " . $stmt2->error);
        }
    }

    // Commit transaction
    $conn->commit();

    echo json_encode([
        'status' => 'success',
        'message' => 'Staff created successfully'
    ]);

} catch (Exception $e) {
    // Rollback transaction on error
    $conn->rollback();

    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}

$conn->close();
?>