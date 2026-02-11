<?php
require_once('konekdb.php');
$id = isset($_GET['id']) ? intval($_GET['id']) : 0;
if ($id > 0) {
    $stmt = $konekdb->prepare("DELETE FROM produk WHERE id = :id");
    $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    if ($stmt->execute()) {
        echo json_encode(['success' => 'Data produk berhasil dihapus']);
    } else {
        echo json_encode(['error' => 'Gagal menghapus data']);
    }
}
?>