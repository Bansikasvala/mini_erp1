import 'package:flutter/material.dart';
import 'package:mini_erp/core/utils/stock_status.dart';

class AppFormatters {
  static String dateTime(DateTime? value) {
    if (value == null) return 'Not synced yet';
    final local = value.toLocal();
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day.toString().padLeft(2, '0')} '
        '${_month(local.month)} ${local.year}, '
        '${hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')} $period';
  }

  static String _month(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}

Color stockStatusColor(StockStatus status) {
  switch (status) {
    case StockStatus.outOfStock:
      return Colors.red;
    case StockStatus.lowStock:
      return Colors.orange;
    case StockStatus.inStock:
      return Colors.green;
  }
}

Widget offlineBanner() {
  return Container(
    width: double.infinity,
    color: Colors.orange.shade100,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: const Row(
      children: [
        Icon(Icons.cloud_off, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text('Showing cached data — network unavailable'),
        ),
      ],
    ),
  );
}
