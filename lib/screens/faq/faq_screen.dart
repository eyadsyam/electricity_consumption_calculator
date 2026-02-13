import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/core/theme/app_colors.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("KNOWLEDGE VAULT")),
      body: Container(
        decoration: const BoxDecoration(color: AppColors.bgBlack),
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.deepSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ExpansionTile(
                title: Text(
                  "What is the royal tariff?",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Our tariffs are calculated using the scientific standards of the Egyptian Electric Utility Regulatory Agency.",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
