enum OrderStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  delivered('Delivered'),
  cancelled('Cancelled');

  final String label;
  const OrderStatus(this.label);

  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}
