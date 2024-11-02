<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
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

try {
    // Query to get staff with their employees
    $query = "
        SELECT
            s.staff_id,
            s.staff_name,
            s.department,
            e.employee_id,
            e.is_manager,
            emp.id AS employee_id,
            emp.name AS employee_name,
            emp.email AS employee_email,
            emp.phone AS employee_phone,
            emp.dob AS employee_dob,
            emp.age AS employee_age,
            emp.ssn AS employee_ssn,
            emp.address AS employee_address,
            emp.salary AS employee_salary,
            emp.role AS employee_role
        FROM Staff s
        LEFT JOIN Staff_Employees e ON s.staff_id = e.staff_id
        LEFT JOIN Employee emp ON e.employee_id = emp.id
        ORDER BY s.staff_id
    ";

    $result = $conn->query($query);

    if (!$result) {
        throw new Exception("Error fetching staff: " . $conn->error);
    }

    $staffList = [];
    $currentStaff = null;

    while ($row = $result->fetch_assoc()) {
        if ($currentStaff === null || $currentStaff['staffId'] !== $row['staff_id']) {
            // Start a new staff entry
            if ($currentStaff !== null) {
                $staffList[] = $currentStaff;
            }

            $currentStaff = [
                'staffId' => $row['staff_id'],
                'staffName' => $row['staff_name'],
                'department' => $row['department'],
                'employees' => []
            ];
        }

        // Add employee if employee_id exists
       if ($row['employee_id']) {
           $currentStaff['employees'][] = [
               'id' => $row['employee_id'],
               'isManager' => (bool)$row['is_manager'],
               'name' => $row['employee_name'],
               'email' => $row['employee_email'],
               'phone' => $row['employee_phone'],
               'dob' => $row['employee_dob'],
               'age' => $row['employee_age'],
               'ssn' => $row['employee_ssn'],
               'address' => $row['employee_address'],
               'salary' => $row['employee_salary'],
               'role' => $row['employee_role']
           ];
       }
    }

    // Add the last staff entry
    if ($currentStaff !== null) {
        $staffList[] = $currentStaff;
    }

    echo json_encode([
        'status' => 'success',
        'data' => $staffList
    ]);

} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}

$conn->close();
?>