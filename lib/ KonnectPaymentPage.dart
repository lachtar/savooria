import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trrr/KonnectController.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KonnectPaymentPage extends StatefulWidget {
  const KonnectPaymentPage({super.key});

  @override
  State<KonnectPaymentPage> createState() => _KonnectPaymentPageState();
}

class _KonnectPaymentPageState extends State<KonnectPaymentPage> {
  KonnectController controller = Get.put(KonnectController());
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      appBar: AppBar(),
      body:Obx(()=>   controller.isLoading.value ?  CircularProgressIndicator():  WebViewWidget(controller: controller.webViewController)),

    );
  }
}
