import 'package:flutter/material.dart';

import 'product_management_page.dart';

class AdminPage extends StatelessWidget {
  final String token;

  const AdminPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: Material(
              color: const Color.fromARGB(255, 57, 97, 162),
              child: Column(
                children: [
                  SizedBox(height: 40),

                  Text(
                    'ADMIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),

                  ListTile(
                    leading: Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Quản lý sản phẩm',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      debugPrint('Đã bấm quản lý sản phẩm');
                    },
                  ),

                  ListTile(
                    leading: Icon(Icons.receipt_long, color: Colors.white),
                    title: Text(
                      'Quản lý đơn hàng',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      debugPrint('Đã bấm quản lý đơn hàng');
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(child: ProductManagementPage(token: token)),
          ),
        ],
      ),
    );
  }
}
