<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

// Koneksi ke database MySQL
$conn = new mysqli("localhost", "root", "", "kasir_app");

// Cek koneksi
if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Database connection failed: " . $conn->connect_error]));
}

// Endpoint login
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['username']) && isset($_POST['password'])) {
    $username = $conn->real_escape_string($_POST['username']);
    $password = md5($_POST['password']); // Ganti dengan hash lebih aman seperti password_hash()

    $sql = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        echo json_encode([
            "success" => true,
            "message" => "Login berhasil",
            "role" => $user['role']
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Username atau password salah"
        ]);
    }
    exit;
}

// Default response
echo json_encode(["success" => false, "message" => "Invalid request"]);
?>
