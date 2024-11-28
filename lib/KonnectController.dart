import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:webview_flutter/webview_flutter.dart';

import 'LoginPage.dart';
import 'LoginResponse.dart';

class KonnectController extends GetxController {
  final Api_Key = "67444bd1a363c8ae12e0db3f:HzskKRedqypnbYf6jDP";
  final wallet_Id = "67444bd1a363c8ae12e0db47";

  WebViewController webViewController = WebViewController();
  var isLoading = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    webViewController = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
          onUrlChange: (url) => print("this is the new url : $url")));
    initPayment();
  }
  Future<bool> isUserInTunisia() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception("Location permissions are denied");
        }
      }

      Position position = await Geolocator.getCurrentPosition();

      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        String? country = placemarks.first.country;
        print("country = " + country.toString());
        return country?.toLowerCase() == "tunisia";
      } else {
        throw Exception("No placemarks found");
      }
    } catch (e) {
      print("Error checking if user is in Tunisia: $e");
      return false;
    }
  }

  initPayment() async {
    bool isInTunisia = await isUserInTunisia();
    isLoading.value = true;
    var body = {
      "receiverWalletId": wallet_Id,
      "amount": 70000,
      "token": isInTunisia ? "TND" : "USD",
      "acceptedPaymentMethods": ["wallet", "bank_card", "e-DINAR", "flouci"],
      "silentWebhook": true,
      "email": Get.arguments["email"],
      "firstName": Get.arguments["username"]
    };
    const url =
        "https://api.preprod.konnect.network/api/v2/payments/init-payment";

    var response = await http.post(
      Uri.parse(url),
      headers: {
        "x-api-key": Api_Key,
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
            NavigationDelegate(
            onProgress: (int progress) {
        // Update loading bar.
      },
    onPageStarted: (String url) {
    print("url started " + url);
    if (url ==
    "https://gateway.sandbox.konnect.network/payment-success") {
    saveLogin(Get.arguments);
    }
    },
    onPageFinished: (String url) {
    if (url ==
    " https://gateway.sandbox.konnect.network/payment-success") {

    saveLogin(Get.arguments);
    }
    },
    onWebResourceError: (WebResourceError error) {},
            ),
        )
        ..loadRequest(Uri.parse(
            KonnectResponse.fromJson(jsonDecode(response.body)).payUrl ??
                "https://flutter.dev"));
      isLoading.value = false;
    } else {
      isLoading.value = false;
      print(response.statusCode);
      print(response.body);
    }
  }
}


saveLogin(dynamic body) async {
  final response = await http.post(
    Uri.parse('https://pentest.pentestyourwebsite.com/api/auth/register'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  if (response.statusCode == 201) {
    print("Registration successful. Redirecting to login page...");

    Get.off(() => const LoginPage());
  } else {
    print("Error during registration: ${response.body}");
    // Vous pouvez afficher un message d'erreur ici si nécessaire
  }
}

class KonnectResponse {
  String? payUrl;
  String? paymentRef;

  KonnectResponse({this.payUrl, this.paymentRef});

  KonnectResponse.fromJson(Map<String, dynamic> json) {
    payUrl = json['payUrl'];
    paymentRef = json['paymentRef'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['payUrl'] = payUrl;
    data['paymentRef'] = paymentRef;
    return data;
    }
}