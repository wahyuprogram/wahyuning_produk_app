<?php
// Header CORS (Izin Akses Browser)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// PERBAIKAN PENTING:
// Jika browser mengirim sinyal cek (OPTIONS), langsung jawab "OK" dan berhenti.
// Jangan biarkan lanjut ke bawah (koneksi database), nanti error.
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Koneksi Database
$host = "localhost";
$user = "root";
$pass = "";
$database = "db_produk";

try {
    $konekdb = new PDO("mysql:host=$host;dbname=$database", $user, $pass);
    $konekdb->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
    $konekdb->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(['error' => 'Koneksi Database Gagal: ' . $e->getMessage()]);
    exit;
}
?>