import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/core/theme/app_colors.dart';

class ComplaintPage extends StatelessWidget {
  const ComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("IMPERIAL SUPPORT")),
      body: Container(
        decoration: const BoxDecoration(color: AppColors.bgBlack),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(
                "Submit your feedback to our royal support team.",
                style: GoogleFonts.outfit(color: Colors.white54),
              ),
              const SizedBox(height: 40),
              _buildInput("Full Name"),
              const SizedBox(height: 20),
              _buildInput("Subject of Inquiry"),
              const SizedBox(height: 20),
              _buildInput("Detailed Message", maxLines: 5),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("SEND TO COURT"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white24),
        fillColor: AppColors.deepSurface,
      ),
    );
  }
}
