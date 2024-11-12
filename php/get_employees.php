<?php
// get_employees.php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$host = 'localhost';
$dbname = 'dummy';
$username = 'root';
$password = '';

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $query = "SELECT
                id,
                name,
                email,
                phone,
                age,
                ssn,
                address,
                salary,
                role,
                dob,
                created_at,
                updated_at
              FROM Employee";

    $stmt = $conn->prepare($query);
    $stmt->execute();
    $employees = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format the response data to match your Flutter model
    $formattedEmployees = array_map(function($employee) {
        return [
            'id' => (int)$employee['id'],
            'name' => $employee['name'],
            'email' => $employee['email'],
            'phone' => $employee['phone'],
            'age' => $employee['age'] ? (int)$employee['age'] : null,
            'ssn' => $employee['ssn'],
            'address' => $employee['address'],
            'salary' => (int)$employee['salary'],
            'role' => $employee['role'],
            'dob' => $employee['dob'],
            'created_at' => $employee['created_at'],
            'updated_at' => $employee['updated_at']
        ];
    }, $employees);

    echo json_encode([
        'success' => true,
        'data' => $formattedEmployees
    ]);

} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>