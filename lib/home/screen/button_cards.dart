import 'package:flutter/material.dart';

class ButtonCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  const ButtonCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.onTap, // Ajout de la fonction de callback
  }) : super(key: key);

  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap, // Appel de la fonction onTap quand on clique sur la card
        child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
    ),
      child: Container(
        width: 120,
        height: 123,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white.withOpacity(0), // Fond transparent
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Afficher l'image avec des coins arrondis
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Arrondir les coins de l'image
              child: Image.asset(
                imagePath,
                height: 40,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 19.0),

            // Titre avec un style de texte simple
            Container(
              width: 70,
              height:40,
              decoration: BoxDecoration(
                color: const Color(0xFFD4B79F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4B79F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
