import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SmallCardWidget extends StatelessWidget {
  final String title; // Texte du carré
  final int cardType; // Type de carré pour les couleurs

  const SmallCardWidget({
    super.key,
    required this.title,
    required this.cardType,
  });

  @override
  Widget build(BuildContext context) {
    // Couleurs des carrés basées sur le type
    Color backgroundColor;

    if (cardType == 1) {
      backgroundColor = const Color(0xFFE06B44); // Couleur unie pour type 1
    } else if (cardType == 2) {
      backgroundColor = const Color(0xFFFFD700); // Couleur unie pour type 2
    } else if (cardType == 3) {
      backgroundColor = const Color(0xFFF7C1A4); // Couleur unie pour type 3
    } else {
      backgroundColor = Colors.white;
    }

    return SizedBox(
      width: Get.width*0.4, // Largeur des carrés
      height: Get.height*0.1, // Hauteur des carrés
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Coins arrondis
        ),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center, // Centrer le contenu
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14, // Taille du texte réduite
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
