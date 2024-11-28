import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import '../LoginPage.dart';

class SpaceScreen extends StatelessWidget {
  const SpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Animated logo
            WidgetAnimator(
              atRestEffect: WidgetRestingEffects.bounce(
                duration: const Duration(seconds: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logoo.png',
                    //height: Get.height * 0.5,
                    //width: Get.width * 0.7,
                    fit: BoxFit.contain,
                  ),
                  //const SizedBox(height: 30),
                  Text(
                    "Each book, a new flavor of knowledge".tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Georgia',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // Navigate to the LoginPage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4B79F),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:  Text(
                "Welcome".tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
