<?php
// Tambahkan Header CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

// Tangani preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Koneksi ke database
$conn = new mysqli("localhost", "root", "", "kasir_app");

// Periksa koneksi database
if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Database connection failed"]));
}

// Ambil tindakan dari parameter 'action'
$action = isset($_GET['action']) ? $_GET['action'] : null;

switch ($action) {
    case 'register':
        $username = isset($_POST['username']) ? trim($_POST['username']) : null;
        $password = isset($_POST['password']) ? trim($_POST['password']) : null;
        $role = isset($_POST['role']) ? trim($_POST['role']) : null;

        if (!$username || !$password || !$role) {
            echo json_encode(["success" => false, "message" => "All fields are required"]);
            exit();
        }

        $checkUserStmt = $conn->prepare("SELECT id FROM users WHERE username = ?");
        $checkUserStmt->bind_param("s", $username);
        $checkUserStmt->execute();
        $checkUserStmt->store_result();

        if ($checkUserStmt->num_rows > 0) {
            echo json_encode(["success" => false, "message" => "Username already exists"]);
            $checkUserStmt->close();
            exit();
        }
        $checkUserStmt->close();

        $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

        $stmt = $conn->prepare("INSERT INTO users (username, password, role) VALUES (?, ?, ?)");
        $stmt->bind_param("sss", $username, $hashedPassword, $role);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "User registered successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to register user"]);
        }

        $stmt->close();
        break;

    case 'login':
        $username = isset($_POST['username']) ? trim($_POST['username']) : null;
        $password = isset($_POST['password']) ? trim($_POST['password']) : null;

        if (!$username || !$password) {
            echo json_encode(["success" => false, "message" => "Username and password are required"]);
            exit();
        }

        $stmt = $conn->prepare("SELECT id, password, role FROM users WHERE username = ?");
        $stmt->bind_param("s", $username);
        $stmt->execute();
        $stmt->bind_result($id, $hashedPassword, $role);

        if ($stmt->fetch()) {
            if (password_verify($password, $hashedPassword)) {
                echo json_encode([
                    "success" => true,
                    "message" => "Login successful",
                    "data" => [
                        "id" => $id,
                        "username" => $username,
                        "role" => $role
                    ]
                ]);
            } else {
                echo json_encode(["success" => false, "message" => "Invalid username or password"]);
            }
        } else {
            echo json_encode(["success" => false, "message" => "Invalid username or password"]);
        }

        $stmt->close();
        break;

    case 'fetch':
        $result = $conn->query("SELECT id, username, role FROM users");
        if ($result) {
            $users = [];
            while ($row = $result->fetch_assoc()) {
                $users[] = [
                    "id" => (int) $row["id"],
                    "username" => $row["username"],
                    "role" => $row["role"],
                ];
            }
            echo json_encode(["success" => true, "users" => $users]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to fetch users"]);
        }
        break;

    case 'update':
        $id = isset($_POST['id']) ? (int)$_POST['id'] : null;
        $username = isset($_POST['username']) ? trim($_POST['username']) : null;
        $password = isset($_POST['password']) ? trim($_POST['password']) : null;
        $role = isset($_POST['role']) ? trim($_POST['role']) : null;

        if (!$id || !$username || !$role) {
            echo json_encode(["success" => false, "message" => "ID, Username, and Role are required"]);
            exit();
        }

        $hashedPassword = $password ? password_hash($password, PASSWORD_BCRYPT) : null;

        $sql = "UPDATE users SET username = ?, role = ?";
        $params = [$username, $role];
        $types = "ss";

        if ($hashedPassword) {
            $sql .= ", password = ?";
            $params[] = $hashedPassword;
            $types .= "s";
        }
        $sql .= " WHERE id = ?";
        $params[] = $id;
        $types .= "i";

        $stmt = $conn->prepare($sql);
        $stmt->bind_param($types, ...$params);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "User updated successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to update user"]);
        }

        $stmt->close();
        break;

    case 'delete':
        $id = isset($_POST['id']) ? (int)$_POST['id'] : null;

        if (!$id) {
            echo json_encode(["success" => false, "message" => "ID is required"]);
            exit();
        }

        $stmt = $conn->prepare("DELETE FROM users WHERE id = ?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "User deleted successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to delete user"]);
        }

        $stmt->close();
        break;

    default:
        echo json_encode(["success" => false, "message" => "Invalid action"]);
        break;
}

$conn->close();
?>
