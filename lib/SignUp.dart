import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http;
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import ' KonnectPaymentPage.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> registerUser() async {
    const String url = 'https://savooria.com/json/register';
    final Map<String, String> headers = {"Content-Type": "application/json"};
    final Map<String, dynamic> body = {
      "name": _nameController.text,
      "email": _emailController.text,
      "mobile": _mobileController.text,
      "password": _passwordController.text,
    };
    Get.to(() => const KonnectPaymentPage(), arguments:body);


    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody['message']),
            backgroundColor: const Color(0xFF0079C2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Process to the payment'),
            backgroundColor: Color(0xFF0079C2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $error'),
          backgroundColor: Colors.deepOrangeAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Logo animé avec WidgetAnimator
            WidgetAnimator(
              atRestEffect: WidgetRestingEffects.bounce(
                duration: const Duration(seconds: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  WidgetAnimator(
                    child: Image.asset(
                      'assets/images/logoo.png',
                      height: Get.height * 0.5, // Hauteur de 50% de l'écran
                      width: Get.width * 0.7,   // Largeur de 70% de l'écran
                      fit: BoxFit.contain,      // Adapter l'image sans la déformer
                    ),
                  ),

                  // Slogan
                  Text(
                    "Each book,a new flavor of knowledge".tr, // Le texte du slogan
                    style: TextStyle(
                      fontSize: 16, // Taille de police
                      color: Colors.grey[700], // Couleur du texte
                      fontWeight: FontWeight.w500, // Épaisseur moyenne
                      fontFamily: 'Georgia', // Police utilisée
                    ),
                    textAlign: TextAlign.center, // Centrer le texte
                  ),
                ],
              ),
            ),

            // Formulaire d'inscription
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  // Champ pour le nom
                  FadeInUp(
                    duration: const Duration(milliseconds: 1800),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD4B79F)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4B79F).withOpacity(0.2),
                            blurRadius: 20.0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          // Champ de texte pour le nom
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFD4B79F)),
                              ),
                            ),
                            child: TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Put your Name".tr,
                                hintStyle: TextStyle(
                                  color: Colors.grey[700],
                                  fontFamily: 'Georgia', // Définir la famille de police ici
                                ),
                              ),
                            ),
                          ),
                          // Champ de texte pour l'email
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFD4B79F)),
                              ),
                            ),
                            child: TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Put your Email".tr,
                                hintStyle: TextStyle(
                                  color: Colors.grey[700],
                                  fontFamily: 'Georgia', // Définir la famille de police ici
                                ),
                              ),
                            ),
                          ),
                          // Champ de texte pour le numéro de mobile
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFD4B79F)),
                              ),
                            ),
                            child: TextField(
                              controller: _mobileController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Mobile or Phone Number".tr,
                                hintStyle: TextStyle(
                                  color: Colors.grey[700],
                                  fontFamily: 'Georgia', // Définir la famille de police ici
                                ),
                              ),
                            ),
                          ),
                          // Champ de texte pour le mot de passe
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password".tr,
                                hintStyle: TextStyle(
                                  color: Colors.grey[700],
                                  fontFamily: 'Georgia', // Définir la famille de police ici
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Bouton d'inscription
                  FadeInUp(
                    duration: const Duration(milliseconds: 1900),
                    child: GestureDetector(
                      onTap: registerUser,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFD4B79F),
                              Color(0xFFD4B79F),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Sign Up".tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 70),

                  // Lien vers la page de connexion si l'utilisateur a déjà un compte
                  FadeInUp(
                    duration: const Duration(milliseconds: 2000),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Already have an account?'.tr,
                        style: TextStyle(color: Color(0xFFD4B79F)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





