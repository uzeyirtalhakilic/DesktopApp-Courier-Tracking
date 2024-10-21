// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

class YemeksepetiScreen extends StatefulWidget {
  const YemeksepetiScreen({super.key});

  @override
  _YemeksepetiScreenState createState() => _YemeksepetiScreenState();
}

class _YemeksepetiScreenState extends State<YemeksepetiScreen> with AutomaticKeepAliveClientMixin {
  final webviewController = WebviewController(); // WebviewController oluşturuldu

  @override
  void initState() {
    super.initState();
    _initializeWebView(); // WebView başlatılır
  }

  Future<void> _initializeWebView() async {
    await webviewController.initialize(); // WebView'i başlat
    webviewController.setBackgroundColor(Colors.transparent); // Arka planı ayarla
    await webviewController.loadUrl('https://partner-app.yemeksepeti.com/login'); // Yemeksepeti giriş sayfasını yükle
    setState(() {}); // Yüklenme tamamlandığında UI güncellenir
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin'i etkinleştirmek için gerekli
    return Scaffold(
      body: webviewController.value.isInitialized
          ? Webview(
              webviewController,
              permissionRequested: _onPermissionRequested, // İzinleri yönetir
            )
          : const Center(child: CircularProgressIndicator()), // Yüklenirken gösterilen gösterge
    );
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
    String url,
    WebviewPermissionKind kind,
    bool isUserInitiated,
  ) async {
    return WebviewPermissionDecision.allow; // Tüm izinler kabul ediliyor
  }

  @override
  bool get wantKeepAlive => true; // Sayfanın durumunu korumak için true döndürülür
}
