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
    die(json_encode(["success" => false, "message" => "Database connection failed: " . $conn->connect_error]));
}

// Ambil tindakan dari parameter 'action'
$action = isset($_GET['action']) ? $_GET['action'] : null;

switch ($action) {
    case 'fetch':
        // Ambil semua transaksi
        $query = "
            SELECT t.id, t.quantity, t.total_price, m.name AS menu_name 
            FROM transactions t
            JOIN menu m ON t.menu_id = m.id
        ";
        $result = $conn->query($query);

        if ($result) {
            $transactions = [];
            while ($row = $result->fetch_assoc()) {
                $transactions[] = [
                    'id' => (int) $row['id'],
                    'menu_name' => $row['menu_name'],
                    'quantity' => (int) $row['quantity'],
                    'total_price' => (float) $row['total_price']
                ];
            }
            echo json_encode(["success" => true, "transactions" => $transactions]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to fetch transactions: " . $conn->error]);
        }
        break;

    case 'add':
        // Ambil parameter dari POST
        $menu_id = isset($_POST['menu_id']) ? intval($_POST['menu_id']) : null;
        $quantity = isset($_POST['quantity']) ? intval($_POST['quantity']) : null;

        if ($menu_id && $quantity) {
            // Hitung total harga berdasarkan harga menu
            $menu_query = $conn->prepare("SELECT price FROM menu WHERE id = ?");
            $menu_query->bind_param("i", $menu_id);
            $menu_query->execute();
            $menu_result = $menu_query->get_result();

            if ($menu_result->num_rows > 0) {
                $menu = $menu_result->fetch_assoc();
                $price = (float) $menu['price'];
                $total_price = $price * $quantity;

                // Simpan transaksi dengan total harga
                $stmt = $conn->prepare("INSERT INTO transactions (menu_id, quantity, total_price) VALUES (?, ?, ?)");
                $stmt->bind_param("iid", $menu_id, $quantity, $total_price);

                if ($stmt->execute()) {
                    echo json_encode(["success" => true, "message" => "Transaction added successfully"]);
                } else {
                    echo json_encode(["success" => false, "message" => "Failed to add transaction"]);
                }
                $stmt->close();
            } else {
                echo json_encode(["success" => false, "message" => "Menu not found"]);
            }
            $menu_query->close();
        } else {
            echo json_encode(["success" => false, "message" => "Invalid input. Please provide menu_id and quantity."]);
        }
        break;

    case 'delete':
        // Hapus transaksi berdasarkan ID
        $id = isset($_POST['id']) ? intval($_POST['id']) : null;

        if ($id) {
            $stmt = $conn->prepare("DELETE FROM transactions WHERE id = ?");
            $stmt->bind_param("i", $id);

            if ($stmt->execute()) {
                echo json_encode(["success" => true, "message" => "Transaction deleted successfully"]);
            } else {
                echo json_encode(["success" => false, "message" => "Failed to delete transaction: " . $stmt->error]);
            }
            $stmt->close();
        } else {
            echo json_encode(["success" => false, "message" => "Invalid transaction ID"]);
        }
        break;

    case 'clear':
        // Hapus semua transaksi
        $query = "DELETE FROM transactions";
        if ($conn->query($query)) {
            echo json_encode(["success" => true, "message" => "All transactions cleared"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to clear transactions: " . $conn->error]);
        }
        break;

    default:
        // Jika tindakan tidak valid
        echo json_encode(["success" => false, "message" => "Invalid action"]);
        break;
}

// Tutup koneksi database
$conn->close();
?>
