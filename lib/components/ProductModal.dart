// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_courier/contexts/CartProvider.dart';
import 'package:flutter_courier/contexts/auth_provider.dart';
import 'package:flutter_courier/models/restaurant.dart';
import 'package:flutter_courier/screens/create_order_screen.dart';
import 'package:provider/provider.dart';

class ProductModal extends StatefulWidget {
  const ProductModal({super.key});

  @override
  _ProductModalState createState() => _ProductModalState();
}

class _ProductModalState extends State<ProductModal> {
  int? selectedModelIndex;

  @override
  Widget build(BuildContext context) {
    // AuthProvider'dan kullanıcıyı alıyoruz
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context); // CartProvider'ı alıyoruz
    final user = authProvider.user;

    if (user == null) {
      return const Center(child: Text('Kullanıcı bulunamadı.'));
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height, // Tam ekran
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row( // Row ile iki yan yana alan
          children: [
            Expanded(
              flex: 2, // Ürünlerin gösterileceği alan
              child: Column(
                children: [
                  _buildHeader(user, cartProvider), // Header güncellendi
                  const SizedBox(height: 20),
                  selectedModelIndex == null
                      ? _buildModelGrid(user) // Modelleri gösteren grid
                      : _buildProductGrid(user.models[selectedModelIndex!].products, cartProvider), // Ürünleri gösteren grid
                ],
              ),
            ),
            const SizedBox(width: 20), // Sağda sepet alanı için boşluk
            Expanded(
              flex: 1, // Sepetin gösterileceği alan
              child: _buildCartView(cartProvider), // Sepet görünümü
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Restaurant user, CartProvider cartProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (selectedModelIndex != null)
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                selectedModelIndex = null; // Geri butonuna basınca modeller ekranına dön
              });
            },
          ),
        Text(
          selectedModelIndex == null
              ? 'Modeller' // Eğer model seçili değilse başlık "Modeller"
              : user.models[selectedModelIndex!].modelTitle, // Model seçiliyse model başlığı
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop(); // Kapatma butonuna basınca modal kapanır
              },
            ),

      ],
    );
  }

  Widget _buildModelGrid(Restaurant user) {
    int crossAxisCount = (MediaQuery.of(context).size.width / 150).floor(); // Genişliğe göre sütun sayısı
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // Dinamik sütun sayısı
          childAspectRatio: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: user.models.length,
        itemBuilder: (context, index) {
          final model = user.models[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedModelIndex = index;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  model.modelTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products, CartProvider cartProvider) {
    int crossAxisCount = (MediaQuery.of(context).size.width / 150).floor(); // Genişliğe göre sütun sayısı
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // Dinamik sütun sayısı
          childAspectRatio: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final Product product = products[index];

          return GestureDetector(
            onTap: () {
              cartProvider.addItem(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.productTitle} sepete eklendi!'),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C00),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.productTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${product.productPrice} TL',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

Widget _buildCartView(CartProvider cartProvider) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sepet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                cartProvider.clearCart(); // Sepeti sıfırla
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sepet sıfırlandı!'),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: cartProvider.itemCount,
            itemBuilder: (context, index) {
              final item = cartProvider.items.values.toList()[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Text('Miktar: ${item.quantity}'),
                trailing: Text('${item.price * item.quantity} TL'),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Toplam: ${cartProvider.totalAmount} TL',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Yeni ekrana yönlendirme işlemi
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateOrderScreen(),
                  ),
                );
              },
              child: const Text('Siparişi Oluştur'),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
}
