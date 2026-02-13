import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:finalproject/core/theme/app_colors.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  // Developer Data
  final String _name = 'Eyad Syam';
  final String _title = 'Mobile App Developer';
  final String _whatsapp = '201101118616'; // International format without +
  final String _phoneDisplay = '01101118616';
  final String _linkedin = 'https://www.linkedin.com/in/eyad-syam';
  final String _github = 'https://github.com/eyadsyam';
  final String _email = 'eyadsyam124@gmail.com';

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _launchWhatsApp() async {
    // WhatsApp URL scheme
    final url = 'https://wa.me/$_whatsapp';
    await _launchUrl(url);
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {'subject': 'Electra App Inquiry'},
    );
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.royalGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About Developer',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            // Developer Image with Gold Border
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.royalGold, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.royalGold.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/EyadSyam.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.deepSurface,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Image',
                            style: GoogleFonts.outfit(
                              color: Colors.white24,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Name & Title
            Text(
              _name,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.royalGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.royalGold.withOpacity(0.3)),
              ),
              child: Text(
                _title,
                style: GoogleFonts.outfit(
                  color: AppColors.royalGold,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Contact Links
            _buildContactCard(
              context: context,
              icon: FontAwesomeIcons.whatsapp,
              title: 'WhatsApp',
              subtitle: _phoneDisplay,
              onTap: _launchWhatsApp,
              color: const Color(0xFF25D366),
              isFontAwesome: true,
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context: context,
              icon: FontAwesomeIcons.linkedinIn,
              title: 'LinkedIn',
              subtitle: 'Connect Professionally',
              onTap: () => _launchUrl(_linkedin),
              color: const Color(0xFF0077B5),
              isFontAwesome: true,
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context: context,
              icon: FontAwesomeIcons.github,
              title: 'GitHub',
              subtitle: 'View Source & Projects',
              onTap: () => _launchUrl(_github),
              color: Colors.white,
              isFontAwesome: true,
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context: context,
              icon: Icons.email_rounded,
              title: 'Email',
              subtitle: _email,
              onTap: _launchEmail,
              color: AppColors.royalGold,
              isFontAwesome: false,
            ),

            const SizedBox(height: 48),
            Text(
              'Designed & Developed with ❤️',
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    required bool isFontAwesome,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.deepSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isFontAwesome
                  ? FaIcon(icon, color: color, size: 22)
                  : Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white12,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
