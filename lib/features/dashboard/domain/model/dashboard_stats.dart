class DashboardStats {
  final int totalProducts;
  final int lowStockCount;
  final int pendingOrdersCount;
  final DateTime? lastUpdatedAt;

  const DashboardStats({
    required this.totalProducts,
    required this.lowStockCount,
    required this.pendingOrdersCount,
    this.lastUpdatedAt,
  });
}
