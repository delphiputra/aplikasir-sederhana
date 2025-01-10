<?php
// Tambahkan Header CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

// Koneksi ke database
$conn = new mysqli("localhost", "root", "", "kasir_app");

// Periksa koneksi database
if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Database connection failed"]));
}

// Ambil tindakan dari parameter 'action'
$action = isset($_GET['action']) ? $_GET['action'] : null;

switch ($action) {
    case 'fetch':
        // Ambil semua menu
        $result = $conn->query("SELECT * FROM menu");
        $menus = [];
        while ($row = $result->fetch_assoc()) {
            $menus[] = [
                'id' => (int) $row['id'], // Pastikan id berupa integer
                'name' => $row['name'],   // String tetap sama
                'price' => (float) $row['price'] // Pastikan price berupa float
            ];
        }
        echo json_encode(["success" => true, "menus" => $menus]);
        break;

    case 'add':
        // Tambah menu baru
        $name = $_POST['name'];
        $price = $_POST['price'];

        if ($conn->query("INSERT INTO menu (name, price) VALUES ('$name', '$price')")) {
            echo json_encode(["success" => true, "message" => "Menu added successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to add menu"]);
        }
        break;

    case 'update':
        // Perbarui menu
        $id = $_POST['id'];
        $name = $_POST['name'];
        $price = $_POST['price'];

        if ($conn->query("UPDATE menu SET name='$name', price='$price' WHERE id=$id")) {
            echo json_encode(["success" => true, "message" => "Menu updated successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to update menu"]);
        }
        break;

    case 'delete':
        // Hapus menu
        $id = $_POST['id'];

        if ($conn->query("DELETE FROM menu WHERE id=$id")) {
            echo json_encode(["success" => true, "message" => "Menu deleted successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to delete menu"]);
        }
        break;

    default:
        // Jika tindakan tidak valid
        echo json_encode(["success" => false, "message" => "Invalid action"]);
        break;
}

$conn->close();
?>
