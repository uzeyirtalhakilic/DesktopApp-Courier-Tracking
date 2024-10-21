import 'package:flutter/material.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // Drawer özelliği kaldırıldı
      body: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                  ),
                  child: const Text(
                    'Çıkış Yap',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Mehel Ar-Ge ve Otomasyon',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
