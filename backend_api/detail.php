<?php
header('Content-Type: application/json');
include 'konekdb.php';

$id = isset($_GET['id']) ? intval($_GET['id']) : 0;
try {
    $stmt = $konekdb->prepare("SELECT * FROM produk WHERE id = :id");
    $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    $stmt->execute();
    $produk = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($produk) {
        echo json_encode($produk);
    } else {
        echo json_encode(['error' => 'Product not found']);
    }
} catch (PDOException $e) {
    echo json_encode(['error' => $e->getMessage()]);
}