// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

class TrendyolScreen extends StatefulWidget {
  const TrendyolScreen({super.key});

  @override
  _TrendyolScreenState createState() => _TrendyolScreenState();
}

class _TrendyolScreenState extends State<TrendyolScreen> {
  final webviewController = WebviewController(); // WebviewController oluşturma
  bool isLoading = true; // Yüklenme durumu için

  @override
  void initState() {
    super.initState();
    _initializeWebView(); // WebView'i başlatmak için çağrılan fonksiyon
  }

  Future<void> _initializeWebView() async {
    try {
      await webviewController.initialize(); // WebView'i başlat
      webviewController.setBackgroundColor(Colors.transparent); // Arka planı ayarla
      await webviewController.loadUrl(
          'https://partner.trendyol.com/account/login?redirect=%2F'); // Trendyol giriş sayfasını yükle
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Webview yüklenemedi: $e')), // Hata mesajı göster
      );
    } finally {
      setState(() {
        isLoading = false; // Yüklenme tamamlandığında durumu güncelle
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: webviewController.value.isInitialized
                ? Webview(
                    webviewController,
                    permissionRequested: _onPermissionRequested, // İzin isteği
                  )
                : const Center(child: CircularProgressIndicator()), // Yüklenirken gösterilecek
          ),
        ],
      ),
    );
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    return WebviewPermissionDecision.allow; // İzinleri otomatik olarak ver
  }
}
