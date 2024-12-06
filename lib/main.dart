import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/Pages_book/SpaceScreen.dart';
import '/traduction/intl.dart';
import 'LoginPage.dart';
import 'Pages_book/AuthController.dart';

void main() {
  // Initialisez les dépendances ici
  Get.put(AuthController()); // Met AuthController dans la mémoire

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: LanguageTranslation(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      home: const SpaceScreen(),
    ),
  );
}







