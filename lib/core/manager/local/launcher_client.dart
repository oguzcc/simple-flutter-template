import 'package:url_launcher/url_launcher.dart';

class LauncherClient {
  static Future<void> callTel({required String phoneNumber}) async {
    final callUrl = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(callUrl)) {
      await launchUrl(callUrl);
    } else {
      throw Exception('Could not launch $callUrl');
    }
  }

  static Future<void> launchWhatsApp({
    required String phoneNumber,
    String? message,
  }) async {
    final whatsappUrl = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message ?? '')}',
    );
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      throw Exception('Could not launch $whatsappUrl');
    }
  }

  static Future<void> sendEmail({required String email}) async {
    final emailUrl = Uri.parse('mailto:$email');
    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    } else {
      throw Exception('Could not launch $emailUrl');
    }
  }
}
