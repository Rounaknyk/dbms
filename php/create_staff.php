<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Add error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

$host = 'localhost';
$dbname = 'dummy';
$username = 'root';
$password = '';

// Initialize $conn before try block so it's accessible in catch
$conn = null;

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Log received data for debugging
    $rawInput = file_get_contents('php://input');
    error_log('Received data: ' . $rawInput);

    $data = json_decode($rawInput, true);

    if (!$data) {
        throw new Exception('Invalid JSON data received: ' . json_last_error_msg());
    }

    // Validate required fields
    if (!isset($data['staff_id']) || !isset($data['staff_name']) || !isset($data['department']) || !isset($data['employees'])) {
        throw new Exception('Missing required fields');
    }

    // Start transaction
    $conn->beginTransaction();

    // Insert into Staff table
    $staffQuery = "INSERT INTO Staff (staff_id, staff_name, department)
                  VALUES (:staff_id, :staff_name, :department)";

    $staffStmt = $conn->prepare($staffQuery);
    $staffStmt->execute([
        ':staff_id' => $data['staff_id'],
        ':staff_name' => $data['staff_name'],
        ':department' => $data['department']
    ]);

    // Insert employees into Staff_Employees table
    $employeeQuery = "INSERT INTO Staff_Employees (staff_id, employee_id, is_manager)
                     VALUES (:staff_id, :employee_id, :is_manager)";

    $employeeStmt = $conn->prepare($employeeQuery);

    foreach ($data['employees'] as $employee) {
        $employeeStmt->execute([
            ':staff_id' => $data['staff_id'],
            ':employee_id' => $employee['id'],
            ':is_manager' => $employee['is_manager'] ? 1 : 0
        ]);
    }

    // Commit transaction
    $conn->commit();

    echo json_encode([
        'success' => true,
        'message' => 'Staff created successfully'
    ]);

} catch (PDOException $e) {
    if ($conn) {
        $conn->rollBack();
    }
    error_log('Database error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
} catch (Exception $e) {
    if ($conn) {
        $conn->rollBack();
    }
    error_log('Error: ' . $e->getMessage());
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>