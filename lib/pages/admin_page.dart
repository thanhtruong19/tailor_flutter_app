import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            color: Color.fromARGB(255, 57, 97, 162),
            child: Column(
              children: [
                SizedBox(height: 40),

                Text(
                  'TAILOR ADMIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold
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
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: (){
                    debugPrint('Đã bấm quản lý sản phẩm');
                  },
                ),
              ],
            )
          ),
          Expanded(
            child: Center(
              child: Text('Nội dung quản lý', 
              style: TextStyle(fontSize: 24)),
            ),
          ),
        ],
      ),
    );
  }
}
