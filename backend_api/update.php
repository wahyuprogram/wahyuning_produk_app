<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'konekdb.php';

// KARENA ADA GAMBAR, KITA WAJIB PAKAI $_POST (Bukan JSON)
$id = $_POST['id'];
$kode = $_POST['kode'];
$nama = $_POST['nama'];
$harga = $_POST['harga'];
$foto = null;

// LOGIKA: Cek apakah user mengirim file foto baru?
if (isset($_FILES['foto']['name']) && $_FILES['foto']['name'] != "") {
    $nama_file = date('YmdHis') . "_" . $_FILES['foto']['name'];
    $target_dir = "uploads/";
    $target_file = $target_dir . basename($nama_file);

    // Coba upload
    if (move_uploaded_file($_FILES['foto']['tmp_name'], $target_file)) {
        $foto = $nama_file;
    }
}

try {
    // Jika ada foto baru, kita update kolom 'foto' juga
    if ($foto != null) {
        $sql = "UPDATE produk SET kode=:kode, nama=:nama, harga=:harga, foto=:foto WHERE id=:id";
    } else {
        // Jika tidak ada foto baru, kolom 'foto' JANGAN disentuh
        $sql = "UPDATE produk SET kode=:kode, nama=:nama, harga=:harga WHERE id=:id";
    }

    $stmt = $konekdb->prepare($sql);
    $stmt->bindParam(':id', $id);
    $stmt->bindParam(':kode', $kode);
    $stmt->bindParam(':nama', $nama);
    $stmt->bindParam(':harga', $harga);
    
    // Bind parameter foto hanya jika ada update foto
    if ($foto != null) {
        $stmt->bindParam(':foto', $foto);
    }

    $stmt->execute();
    
    echo json_encode(['success' => true]);

} catch (PDOException $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>