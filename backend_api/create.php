<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'konekdb.php';

$kode = $_POST['kode'];
$nama = $_POST['nama'];
$harga = $_POST['harga'];
$foto = null; // Default null jika tidak ada gambar

if (isset($_FILES['foto']['name'])) {
    $nama_file = date('YmdHis') . "_" . $_FILES['foto']['name'];
    $target_dir = "uploads/";
    $target_file = $target_dir . basename($nama_file);

    if (move_uploaded_file($_FILES['foto']['tmp_name'], $target_file)) {
        $foto = $nama_file;
    }
}

try {
    $sql = "INSERT INTO produk (kode, nama, harga, foto) VALUES (:kode, :nama, :harga, :foto)";
    $stmt = $konekdb->prepare($sql);
    $stmt->bindParam(':kode', $kode);
    $stmt->bindParam(':nama', $nama);
    $stmt->bindParam(':harga', $harga);
    $stmt->bindParam(':foto', $foto);
    
    $stmt->execute();
    
    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>