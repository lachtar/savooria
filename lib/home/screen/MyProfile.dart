import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/LoginPage.dart';
import '../../Pages_book/AuthController.dart';
import 'home_screen.dart'; // Import the HomeScreen page

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? selectedLanguage;

  @override
  void initState() {
    super.initState();

    // Définir la valeur initiale de la liste déroulante en fonction de la langue actuelle
    if (Get.locale?.languageCode == 'fr') {
      selectedLanguage = 'Français';
    } else if (Get.locale?.languageCode == 'en') {
      selectedLanguage = 'English';
    } else if (Get.locale?.languageCode == 'ar') {
      selectedLanguage = 'Arabic';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4B79F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                color: const Color(0xFFD4B79F),
                height: 100,
              ),
              Positioned(
                top: 30,
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage("assets/images/profile.jpg"),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Obx(() => ListTile(
                      title: Text(
                        "UserName".tr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        Get.find<AuthController>().userName.value,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    )),
                const Divider(),
                Obx(() => ListTile(
                      title: Text(
                        "Email".tr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        Get.find<AuthController>().userEmail.value,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    )),
                const Divider(),
                Obx(() => ListTile(
                      title: Text(
                        "Mobile".tr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        Get.find<AuthController>().mobile.value,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    )),
                const Divider(),
                ListTile(
                  title: Text("Traduction".tr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                  trailing: DropdownButton<String>(
                    hint: Text('Select Language'.tr),
                    value: selectedLanguage,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLanguage = newValue!;

                        // Mettre à jour la langue dans Get
                        if (selectedLanguage == 'Français') {
                          Get.updateLocale(const Locale('fr', 'FR'));
                        } else if (selectedLanguage == 'English') {
                          Get.updateLocale(const Locale('en', 'US'));
                        } else if (selectedLanguage == 'Arabic') {
                          Get.updateLocale(const Locale('ar', 'SA'));
                        }
                      });
                    },
                    items: <String>['English', 'Français', 'Arabic']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 15.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4B79F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  child: Center(
                    child: Text(
                      "Done".tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                    Get.find<AuthController>().logout();
                    // Exemple d'action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4B79F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical:5.0),
                  ),
                  child: Center(
                    child: Text(
                      "Log Out".tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
