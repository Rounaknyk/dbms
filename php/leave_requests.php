<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $host = 'localhost';
    $dbname = 'dummy';
    $username = 'root';
    $password = '';

    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Handle GET request
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        if (isset($_GET['staff_id'])) {
            $staffId = $_GET['staff_id'];

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
                    lr.start_date,
                    lr.end_date,
                    lr.total_days,
                    lt.name AS leave_type,
                    lt.id AS leave_type_id,
                    lr.created_at,
                    lr.updated_at
                FROM leave_requests lr
                JOIN Employee e ON lr.employee_id = e.id
                JOIN leave_types lt ON lr.leave_type_id = lt.id
                WHERE lr.staff_id = :staffId
                ORDER BY lr.created_at DESC
            ";

            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':staffId', $staffId);

        } elseif (isset($_GET['employee_id'])) {
            $employeeId = $_GET['employee_id'];

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
                    lr.start_date,
                    lr.end_date,
                    lr.total_days,
                    lt.name AS leave_type,
                    lt.id AS leave_type_id,
                    lr.created_at,
                    lr.updated_at
                FROM leave_requests lr
                JOIN Staff s ON lr.staff_id = s.staff_id
                JOIN leave_types lt ON lr.leave_type_id = lt.id
                WHERE lr.employee_id = :employeeId
                ORDER BY lr.created_at DESC
            ";

            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':employeeId', $employeeId);

        } elseif (isset($_GET['leave_types'])) {
            // Endpoint to get all leave types
            $sql = "SELECT id, name, description FROM leave_types ORDER BY name";
            $stmt = $conn->prepare($sql);
            $stmt->execute();
            $leaveTypes = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($leaveTypes);
            exit();
        } else {
            throw new Exception('Either staff_id or employee_id is required');
        }

        $stmt->execute();
        $leaveRequests = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($leaveRequests);
    }

    // Handle POST request
    elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $requestData = json_decode(file_get_contents('php://input'), true);

        // Validate required fields
        if (!isset($requestData['employee_id']) ||
            !isset($requestData['staff_id']) ||
            !isset($requestData['reason']) ||
            !isset($requestData['leave_type_id']) ||
            !isset($requestData['start_date']) ||
            !isset($requestData['end_date'])) {
            throw new Exception('Missing required fields');
        }

        $employeeId = $requestData['employee_id'];
        $staffId = $requestData['staff_id'];
        $reason = $requestData['reason'];
        $leaveTypeId = $requestData['leave_type_id'];
        $startDate = $requestData['start_date'];
        $endDate = $requestData['end_date'];

        // Validate dates
        $startDateTime = new DateTime($startDate);
        $endDateTime = new DateTime($endDate);
        if ($endDateTime < $startDateTime) {
            throw new Exception('End date must be after start date');
        }

        // Validate leave type exists
        $checkLeaveType = $conn->prepare("SELECT id FROM leave_types WHERE id = ?");
        $checkLeaveType->execute([$leaveTypeId]);
        if (!$checkLeaveType->fetch()) {
            throw new Exception('Invalid leave type');
        }

        // Check for overlapping leave requests
        $checkOverlap = $conn->prepare("
            SELECT COUNT(*) FROM leave_requests
            WHERE employee_id = ?
            AND status != 'Rejected'
            AND (
                (start_date BETWEEN ? AND ?) OR
                (end_date BETWEEN ? AND ?) OR
                (start_date <= ? AND end_date >= ?)
            )
        ");
        $checkOverlap->execute([
            $employeeId,
            $startDate, $endDate,
            $startDate, $endDate,
            $startDate, $endDate
        ]);
        if ($checkOverlap->fetchColumn() > 0) {
            throw new Exception('You already have a leave request for these dates');
        }

        // Other validations
        $checkEmployee = $conn->prepare("SELECT id FROM Employee WHERE id = ?");
        $checkEmployee->execute([$employeeId]);
        if (!$checkEmployee->fetch()) {
            throw new Exception('Employee not found');
        }

        $checkStaff = $conn->prepare("SELECT staff_id FROM Staff WHERE staff_id = ?");
        $checkStaff->execute([$staffId]);
        if (!$checkStaff->fetch()) {
            throw new Exception('Staff not found');
        }

        $checkNotManager = $conn->prepare("
            SELECT 1 FROM Staff_Employees
            WHERE employee_id = ? AND staff_id = ? AND is_manager = 1
        ");
        $checkNotManager->execute([$employeeId, $staffId]);
        if ($checkNotManager->fetch()) {
            throw new Exception('Managers cannot request leave from their own staff');
        }

        $sql = "
            INSERT INTO leave_requests
            (employee_id, staff_id, reason, leave_type_id, start_date, end_date, status)
            VALUES
            (:employeeId, :staffId, :reason, :leaveTypeId, :startDate, :endDate, 'Pending')
        ";

        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':employeeId', $employeeId);
        $stmt->bindParam(':staffId', $staffId);
        $stmt->bindParam(':reason', $reason);
        $stmt->bindParam(':leaveTypeId', $leaveTypeId);
        $stmt->bindParam(':startDate', $startDate);
        $stmt->bindParam(':endDate', $endDate);
        $stmt->execute();

        $response = [
            'success' => true,
            'message' => 'Leave request created successfully'
        ];
        echo json_encode($response);
    }

    // Handle PUT request
    elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
        $requestData = json_decode(file_get_contents('php://input'), true);

        if (!isset($requestData['request_id']) || !isset($requestData['status'])) {
            throw new Exception('Request ID and status are required');
        }

        $requestId = intval($requestData['request_id']);
        $status = $requestData['status'];

        $validStatuses = ['Approved', 'Rejected'];
        if (!in_array($status, $validStatuses)) {
            throw new Exception('Invalid status value');
        }

        // Verify if the leave request exists and is pending
        $checkRequest = $conn->prepare("
            SELECT lr.id, lr.status
            FROM leave_requests lr
            WHERE lr.id = ?
        ");
        $checkRequest->execute([$requestId]);
        $requestInfo = $checkRequest->fetch(PDO::FETCH_ASSOC);

        if (!$requestInfo) {
            throw new Exception('Leave request not found');
        }

        if ($requestInfo['status'] !== 'Pending') {
            throw new Exception('Leave request has already been processed');
        }

        $sql = "
            UPDATE leave_requests
            SET
                status = :status,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = :requestId
        ";

        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':status', $status);
        $stmt->bindParam(':requestId', $requestId);

        if ($stmt->execute()) {
            $response = [
                'success' => true,
                'message' => "Leave request has been $status successfully"
            ];
            echo json_encode($response);
        } else {
            throw new Exception('Failed to update leave request');
        }
    }

    else {
        throw new Exception('Invalid request method');
    }

} catch(PDOException $e) {
    error_log('Database Error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
} catch(Exception $e) {
    error_log('Application Error: ' . $e->getMessage());
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}