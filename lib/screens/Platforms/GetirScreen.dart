// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

class GetirScreen extends StatefulWidget {
  const GetirScreen({super.key});

  @override
  _GetirScreenState createState() => _GetirScreenState();
}

class _GetirScreenState extends State<GetirScreen> with AutomaticKeepAliveClientMixin {
  final webviewController = WebviewController();
  bool isLoading = true; // Yüklenme durumu için

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      await webviewController.initialize();
      webviewController.setBackgroundColor(Colors.transparent);
      await webviewController.loadUrl('https://restoran.getiryemek.com/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Webview yüklenemedi: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Yüklenme tamamlandığında durumu güncelle
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin kullanımı için gerekli
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: webviewController.value.isInitialized
                ? Webview(
                    webviewController,
                    permissionRequested: _onPermissionRequested,
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    return WebviewPermissionDecision.allow;
  }

  @override
  bool get wantKeepAlive => true; // WebView oturumunu koruyarak yeniden yüklenmesini engeller
}
