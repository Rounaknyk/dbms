<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$host = 'localhost';
$dbname = 'dummy';
$username = 'root';
$password = '';

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $email = $_GET['email'];

    // First, get the employee details
    $sql = "
    SELECT
        e.id,
        e.name,
        e.email,
        e.phone,
        e.age,
        e.ssn,
        e.address,
        e.salary,
        e.role,
        e.dob,
        e.created_at,
        e.updated_at
    FROM Employee e
    WHERE e.email = :email
    ";

    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':email', $email);
    $stmt->execute();
    $employeeData = $stmt->fetch(PDO::FETCH_ASSOC);

    // Get staff assignments and their details
    $sql = "
    SELECT DISTINCT
        s.staff_id,
        s.staff_name,
        s.department,
        d.name AS department_name,
        se.is_manager,
        (
            SELECT e2.name
            FROM Staff_Employees se2
            JOIN Employee e2 ON se2.employee_id = e2.id
            WHERE se2.staff_id = s.staff_id AND se2.is_manager = 1
            LIMIT 1
        ) as manager_name,
        (
            SELECT COUNT(*)
            FROM Staff_Employees se3
            WHERE se3.staff_id = s.staff_id AND se3.is_manager = 0
        ) as member_count
    FROM Staff s
    JOIN Staff_Employees se ON s.staff_id = se.staff_id
    LEFT JOIN Department d ON s.department = d.id
    WHERE se.employee_id = :employee_id
    ";

    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':employee_id', $employeeData['id']);
    $stmt->execute();
    $staffAssignments = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // For each staff, get all its members
    foreach ($staffAssignments as &$staff) {
        $sql = "
        SELECT
            e.name,
            e.email,
            e.role,
            se.is_manager
        FROM Staff_Employees se
        JOIN Employee e ON se.employee_id = e.id
        WHERE se.staff_id = :staff_id
        ORDER BY se.is_manager DESC, e.name ASC
        ";

        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':staff_id', $staff['staff_id']);
        $stmt->execute();
        $staff['members'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    $data = [
        'employee' => $employeeData,
        'staff' => $staffAssignments
    ];

    echo json_encode($data);

} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}