import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '/traduction/intl.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'Pages_book/AuthController.dart';
import 'SignUp.dart';
import '/home/screen/home_screen.dart';

void main() => runApp(
  GetMaterialApp(
    debugShowCheckedModeBanner: false,
    translations: LanguageTranslation(),
    locale: Get.deviceLocale,
    fallbackLocale: const Locale('en', 'US',),
    home: const LoginPage(),
  ),
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Libérer les ressources des contrôleurs
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      // Formulaire invalide
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse("https://savooria.com/json/login");
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Enregistrer le token
        final token = responseData['token'];
        Get.find<AuthController>().setToken(token);

        // Enregistrer les détails de l'utilisateur
        final user = responseData['user'];
        Get.find<AuthController>().setUserDetails(user);

        // Naviguer vers HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showError("Failed to login. Please check your credentials.");
      }
    } catch (e) {
      _showError("An error occurred. Please try again. ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[

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
                    "Each book,a new flavor of knowledge".tr,
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
            const SizedBox(height: 30),

            // Formulaire de connexion
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
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
                            // Champ email
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFD4B79F)),
                                ),
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Put your Email".tr,
                                  hintStyle: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: 'Georgia', // Définir la famille de police ici
                                  ),
                                ),

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your email".tr;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // Champ mot de passe
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Put your Password".tr,
                                  hintStyle: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: 'Georgia', // Définir la famille de police ici
                                  ),

                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your password".tr;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Bouton de connexion
                    FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: GestureDetector(
                        onTap: () => _login(),
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
                            child: _isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : Text(
                              "Login".tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 70),

                    // Lien vers la page d'inscription
                    FadeInUp(
                      duration: const Duration(milliseconds: 2000),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const  SignupPage()),
                          );
                        },
                        child: Text(
                          "Do you have an account !".tr,
                          style: const TextStyle(color: Color(0xFFD4B79F)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
