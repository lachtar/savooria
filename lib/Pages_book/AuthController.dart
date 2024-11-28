import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  // Variables pour stocker les données de l'utilisateur
  var token = ''.obs;
  var userName = ''.obs;
  var userEmail = ''.obs;
  var mobile=''.obs;

  // Méthode pour définir le token
  void setToken(String newToken) {
    token.value = newToken;
  }

  // Méthode pour définir les informations utilisateur
  void setUserDetails(Map<String, dynamic> userDetails) {
    userName.value = userDetails['name'] ?? 'Unknown User';
    userEmail.value = userDetails['email'] ?? 'Unknown Email';
    mobile.value= userDetails['mobile']?? 'Unknown Email';
  }

  // Méthode pour se déconnecter (réinitialiser les données)
  void logout() {
    token.value = '';
    userName.value = '';
    userEmail.value = '';
    mobile.value='';
  }
}
