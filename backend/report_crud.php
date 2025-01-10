<?php
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

// Ambil parameter 'action' dari request
$action = isset($_GET['action']) ? $_GET['action'] : null;

// Pastikan parameter 'action' ada
if (!$action) {
    echo json_encode(["success" => false, "message" => "No action provided"]);
    exit();
}

// Tangani berbagai aksi berdasarkan parameter 'action'
switch ($action) {
    case 'fetch': // Mengambil semua laporan
        $query = "SELECT * FROM reports ORDER BY created_at DESC";
        $result = $conn->query($query);

        if ($result) {
            $reports = [];
            while ($row = $result->fetch_assoc()) {
                $reports[] = [
                    "id" => (int) $row['id'],
                    "menu_name" => $row['menu_name'],
                    "quantity" => (int) $row['quantity'],
                    "total_price" => (float) $row['total_price'],
                    "created_at" => $row['created_at'],
                ];
            }
            echo json_encode(["success" => true, "reports" => $reports]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to fetch reports: " . $conn->error]);
        }
        break;

    case 'save': // Menyimpan transaksi ke laporan
        $input = json_decode(file_get_contents('php://input'), true);
        $transactions = $input['transactions'] ?? [];

        if (empty($transactions)) {
            echo json_encode(["success" => false, "message" => "No transactions provided"]);
            exit();
        }

        // Mulai transaksi
        $conn->begin_transaction();
        try {
            foreach ($transactions as $transaction) {
                if (!isset($transaction['menu_name'], $transaction['quantity'], $transaction['total_price'])) {
                    throw new Exception("Invalid transaction data");
                }

                $stmt = $conn->prepare("INSERT INTO reports (menu_name, quantity, total_price, created_at) VALUES (?, ?, ?, NOW())");
                $stmt->bind_param(
                    "sid",
                    $transaction['menu_name'],
                    $transaction['quantity'],
                    $transaction['total_price']
                );

                if (!$stmt->execute()) {
                    throw new Exception("Failed to save transaction: " . $stmt->error);
                }
            }
            // Commit transaksi
            $conn->commit();
            echo json_encode(["success" => true, "message" => "Transactions saved to report"]);
        } catch (Exception $e) {
            // Rollback jika ada kesalahan
            $conn->rollback();
            echo json_encode(["success" => false, "message" => $e->getMessage()]);
        }
        break;

    case 'delete': // Menghapus laporan berdasarkan ID
        $input = json_decode(file_get_contents('php://input'), true);
        $id = $input['id'] ?? null;

        if (!$id) {
            echo json_encode(["success" => false, "message" => "ID is required"]);
            exit();
        }

        $stmt = $conn->prepare("DELETE FROM reports WHERE id = ?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Report deleted successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to delete report: " . $stmt->error]);
        }
        break;

    default: // Jika action tidak valid
        echo json_encode(["success" => false, "message" => "Invalid action: $action"]);
        break;
}

// Tutup koneksi database
$conn->close();
?>
