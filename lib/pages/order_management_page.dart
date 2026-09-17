import 'package:flutter/material.dart';

class OrderManagementPage extends StatelessWidget {
  const OrderManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý đơn hàng'),
      ),
      body: Center(
        child: Text(
          'Chưa có đơn hàng',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}