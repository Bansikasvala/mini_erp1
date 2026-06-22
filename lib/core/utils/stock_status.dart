enum StockStatus {
  outOfStock('Out of Stock'),
  lowStock('Low Stock'),
  inStock('In Stock');

  final String label;
  const StockStatus(this.label);
}

StockStatus stockStatusFromQuantity(int stock) {
  if (stock == 0) return StockStatus.outOfStock;
  if (stock <= 10) return StockStatus.lowStock;
  return StockStatus.inStock;
}

bool isLowStock(int stock) => stock >= 1 && stock <= 10;
