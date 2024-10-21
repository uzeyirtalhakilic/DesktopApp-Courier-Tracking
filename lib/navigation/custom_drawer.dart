// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_courier/components/ProductModal.dart';

class CustomDrawer extends StatefulWidget {
  final Function(int) onMenuItemSelected; // int türünde bir indeks alın

  const CustomDrawer({
    super.key,
    required this.onMenuItemSelected,
  });

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? selectedItem;
  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCollapsed ? 80 : 250,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF42A5F5),
                Color(0xFF1A237E),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Align(
                alignment:
                    isCollapsed ? Alignment.center : Alignment.centerRight,
                child: IconButton(
                  icon: Icon(isCollapsed ? Icons.menu : Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      isCollapsed = !isCollapsed;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (!isCollapsed)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Mehel Ar-Ge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    buildListTile(Icons.home_outlined, 'Ana Ekran', 0),
                    buildListTile(Icons.list_alt_outlined, 'Sipariş Takibi', 1),
                    buildListTile(Icons.settings_outlined, 'Ayarlar', 2),
                    buildListTileWithImage(
                        'assets/logo/yemeksepetiIcon.png', 'YemekSepeti', 3),
                    buildListTileWithImage(
                        'assets/logo/getirIcon.png', 'Getir', 4),
                    buildListTileWithImage(
                        'assets/logo/trendyolIcon.png', 'Trendyol', 5),
                  ],
                ),
              ),
              if (!isCollapsed)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              showGeneralDialog(
                context: context,
                barrierDismissible:
                    true, // Dışarıya tıklanıldığında kapanması için
                barrierLabel: '',
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation1, animation2) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pop(); // Dışarıya tıklanınca modalı kapat
                    },
                    child: Scaffold(
                      backgroundColor:
                          Colors.transparent, // Arka planı şeffaf yapar
                      body: Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap:
                              () {}, // Modalın içine tıklanıldığında bir şey yapma (yani modal kapanmasın)
                          child: Container(
                            height: 400, // İstediğiniz yüksekliği ayarlayın
                            width: double.infinity, // Genişlik ayarı

                            decoration: BoxDecoration(
                              color: Colors.white, // Arka plan rengi
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(
                                      20)), // Yalnızca üst köşeleri yuvarla
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.2), // Gölge rengi
                                  blurRadius: 10, // Gölge bulanıklığı
                                  offset: const Offset(0, -2), // Gölge konumu
                                ),
                              ],
                            ),
                            child: const ProductModal(), // Modal içeriği
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            backgroundColor: const Color(0xFF42A5F5),
            child: const Icon(Icons.add_shopping_cart),
          ),
        ),
      ],
    );
  }

  Widget buildListTile(IconData icon, String title, int index) {
    final isSelected = selectedItem == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItem = title;
        });
        widget.onMenuItemSelected(index); // İndeksi geçin
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: 26,
          ),
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isCollapsed
                ? const SizedBox.shrink()
                : Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 18,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget buildListTileWithImage(String imagePath, String title, int index) {
    final isSelected = selectedItem == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItem = title;
        });
        widget.onMenuItemSelected(index); // İndeksi geçin
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Image.asset(
            imagePath,
            color: isSelected ? Colors.white : Colors.white70,
            width: 26,
            height: 26,
          ),
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isCollapsed
                ? const SizedBox.shrink()
                : Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 18,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
