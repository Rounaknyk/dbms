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

// Check if email already exists
$checkEmail = $conn->prepare("SELECT email FROM Employee WHERE email = ?");
$checkEmail->bind_param("s", $data['email']);
$checkEmail->execute();
$result = $checkEmail->get_result();

if ($result->num_rows > 0) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Email already exists'
    ]);
    exit();
}

// Prepare and bind
$stmt = $conn->prepare("INSERT INTO Employee (name, email, password, phone, dob, age, ssn, address, salary, role) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

// Hash the password
$hashedPassword = password_hash($data['password'], PASSWORD_DEFAULT);

// Convert salary to integer
$salary = intval($data['salary']);

// Convert age to integer
$age = intval($data['age']);

$stmt->bind_param("sssssissis",
    $data['name'],
    $data['email'],
    $hashedPassword,
    $data['phone'],
    $data['dob'],
    $age,
    $data['ssn'],
    $data['address'],
    $salary,
    $data['role']
);

try {
    if ($stmt->execute()) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Registration successful'
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Registration failed: ' . $stmt->error
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Registration failed: ' . $e->getMessage()
    ]);
}

$stmt->close();
$conn->close();
?>