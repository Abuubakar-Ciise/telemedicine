import 'package:tele/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  /// Function to open links
  void _launchURL(String url, bool inApp) async {
    Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: inApp ? LaunchMode.inAppWebView : LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print("Error launching URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light background for contrast
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// App Logo
                Center(
                  child: Image.asset(
                    'assets/images/app_icon.jpg', // Ensure this image exists in your assets folder
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),

                /// App Name
                Text(
                  "Tayo Health Care",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 20),

                /// Title
                Text(
                  "contact_us".tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                /// Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "contact_us_subtitle".tr(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 30),

                /// Contact Items
                contactItem(Icons.chat, "whatsapp".tr(), "whatsapp_hours".tr(), () {
                  _launchURL("https://wa.me/+252610736551?text=Hello!%20I%20need%20assistance.", false);
                }),
                const SizedBox(height: 15),

                contactItem(Icons.phone, "phone_number".tr(), "+252 610736551", () {
                  _launchURL("tel:+252610736551", false);
                }),
                const SizedBox(height: 15),

                contactItem(Icons.email, "email".tr(), "info@tayocare.com", () {
                  _launchURL("mailto:abuubakarciise4@gmail.com?subject=Support%20Request&body=Hello,%20I%20need%20assistance.", false);
                }),
                const SizedBox(height: 15),

                contactItem(Icons.facebook, "facebook".tr(), "follow_us_updates".tr(), () {
                  _launchURL("https://www.facebook.com/abuubakar.ciise.14?mibextid=ZbWKwL", false);
                }),
                const SizedBox(height: 15),

                // contactItem(Icons.video_call, "Teleconsultation", "Schedule a virtual doctor visit", () {
                //   _launchURL("https://www.tayocare.com/teleconsultation", false);
                // }),
                const SizedBox(height: 20),

                /// Footer
                Text(
                  "© 2025 Tayo Health Care",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Clickable Contact List Item Widget
  Widget contactItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      splashColor: AppColors.brand.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 2),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.teal.shade700),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
