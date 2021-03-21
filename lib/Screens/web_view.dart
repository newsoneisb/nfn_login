import 'package:flutter/material.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

class LoadURL extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<LoadURL> {
  // Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: 'https://www.fun4chat.com',
        // onWebViewCreated: (WebViewController webViewController) {
          // _controller.complete(webViewController);
        // },
      );
  }
}
