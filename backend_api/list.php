<?php
header('Content-Type: application/json');
include 'konekdb.php';

try {
    $stmt = $konekdb->prepare("SELECT * FROM produk");
    $stmt->execute();
    $produk = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($produk);
} catch (PDOException $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>