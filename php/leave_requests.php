<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// If it's a preflight OPTIONS request, return early
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $host = 'localhost';
    $dbname = 'dummy';
    $username = 'root';  // Replace with your database username
    $password = '';      // Replace with your database password

    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Handle GET request to retrieve leave requests
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // Check if we're fetching by staff_id or employee_id
        if (isset($_GET['staff_id'])) {
            $staffId = $_GET['staff_id'];

            // Verify if the staff member exists and is a manager
            $checkManager = $conn->prepare("
                SELECT se.is_manager
                FROM Staff_Employees se
                WHERE se.staff_id = ? AND se.is_manager = 1
            ");
            $checkManager->execute([$staffId]);

            if (!$checkManager->fetch()) {
                throw new Exception('Not authorized to view these leave requests');
            }

            $sql = "
                SELECT
                    lr.id,
                    lr.employee_id,
                    e.name AS employee_name,
                    lr.reason,
                    lr.status,
                    lr.created_at,
                    lr.updated_at
                FROM leave_requests lr
                JOIN Employee e ON lr.employee_id = e.id
                WHERE lr.staff_id = :staffId
                ORDER BY lr.created_at DESC
            ";

            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':staffId', $staffId);

        } elseif (isset($_GET['employee_id'])) {
            $employeeId = $_GET['employee_id'];

            // Verify if the employee exists
            $checkEmployee = $conn->prepare("SELECT id FROM Employee WHERE id = ?");
            $checkEmployee->execute([$employeeId]);

            if (!$checkEmployee->fetch()) {
                throw new Exception('Employee not found');
            }

            $sql = "
                SELECT
                    lr.id,
                    lr.staff_id,
                    s.staff_name,
                    lr.reason,
                    lr.status,
                    lr.created_at,
                    lr.updated_at
                FROM leave_requests lr
                JOIN Staff s ON lr.staff_id = s.staff_id
                WHERE lr.employee_id = :employeeId
                ORDER BY lr.created_at DESC
            ";

            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':employeeId', $employeeId);

        } else {
            throw new Exception('Either staff_id or employee_id is required');
        }

        $stmt->execute();
        $leaveRequests = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($leaveRequests);
    }

    // Handle POST request to create a new leave request
    elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $requestData = json_decode(file_get_contents('php://input'), true);

        // Validate required fields
        if (!isset($requestData['employee_id']) || !isset($requestData['staff_id']) || !isset($requestData['reason'])) {
            throw new Exception('Employee ID, Staff ID, and reason are required');
        }

        $employeeId = $requestData['employee_id'];
        $staffId = $requestData['staff_id'];
        $reason = $requestData['reason'];

        // Validate that the employee exists
        $checkEmployee = $conn->prepare("SELECT id FROM Employee WHERE id = ?");
        $checkEmployee->execute([$employeeId]);
        if (!$checkEmployee->fetch()) {
            throw new Exception('Employee not found');
        }

        // Validate that the staff exists
        $checkStaff = $conn->prepare("SELECT staff_id FROM Staff WHERE staff_id = ?");
        $checkStaff->execute([$staffId]);
        if (!$checkStaff->fetch()) {
            throw new Exception('Staff not found');
        }

        // Check if employee is not requesting leave to their own managed staff
        $checkNotManager = $conn->prepare("
            SELECT 1 FROM Staff_Employees
            WHERE employee_id = ? AND staff_id = ? AND is_manager = 1
        ");
        $checkNotManager->execute([$employeeId, $staffId]);
        if ($checkNotManager->fetch()) {
            throw new Exception('Managers cannot request leave from their own staff');
        }

        $sql = "
            INSERT INTO leave_requests (employee_id, staff_id, reason, status)
            VALUES (:employeeId, :staffId, :reason, 'Pending')
        ";

        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':employeeId', $employeeId);
        $stmt->bindParam(':staffId', $staffId);
        $stmt->bindParam(':reason', $reason);
        $stmt->execute();

        $response = [
            'success' => true,
            'message' => 'Leave request created successfully'
        ];
        echo json_encode($response);
    }

    // Handle PUT request to update leave request status
    elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
        $requestData = json_decode(file_get_contents('php://input'), true);

        // Validate required fields
        if (!isset($requestData['request_id']) || !isset($requestData['status'])) {
            throw new Exception('Request ID and status are required');
        }

        $requestId = $requestData['request_id'];
        $status = $requestData['status'];

        // Validate status value
        $validStatuses = ['Approved', 'Rejected'];
        if (!in_array($status, $validStatuses)) {
            throw new Exception('Invalid status value');
        }

        // Verify the leave request exists and get its staff_id
        $checkRequest = $conn->prepare("
            SELECT lr.staff_id, se.is_manager
            FROM leave_requests lr
            JOIN Staff_Employees se ON lr.staff_id = se.staff_id
            WHERE lr.id = ? AND lr.status = 'Pending'
        ");
        $checkRequest->execute([$requestId]);
        $requestInfo = $checkRequest->fetch(PDO::FETCH_ASSOC);

        if (!$requestInfo) {
            throw new Exception('Leave request not found or already processed');
        }

        if ($requestInfo['is_manager'] != 1) {
            throw new Exception('Only managers can approve or reject leave requests');
        }

        // Update the status
        $sql = "
            UPDATE leave_requests
            SET status = :status,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = :requestId
        ";

        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':status', $status);
        $stmt->bindParam(':requestId', $requestId);
        $stmt->execute();

        $response = [
            'success' => true,
            'message' => "Leave request $status successfully"
        ];
        echo json_encode($response);
    }

    else {
        throw new Exception('Invalid request method');
    }

} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
} catch(Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>