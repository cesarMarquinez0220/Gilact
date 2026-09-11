import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';
import '../../../chatbot/presentation/bloc/chatbot_bloc.dart';

/// Widget responsive para mostrar ayuda y soporte
class HelpSupportCardWidget extends StatelessWidget {
  final VoidCallback? onContactSupport;
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;

  const HelpSupportCardWidget({
    super.key,
    this.onContactSupport,
    this.onTerms,
    this.onPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        final maxWidth = constraints.maxWidth > 600
            ? 600.0
            : constraints.maxWidth;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600
                ? (constraints.maxWidth - 600) / 2
                : 0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingTile(
                context,
                'helpSupport.helpCenter'.tr(),
                'helpSupport.helpCenterDescription'.tr(),
                Icons.help_outline,
                () => _navigateToChatbot(context),
                isSmallScreen,
              ),
              const Divider(height: 1),
              _buildSettingTile(
                context,
                'helpSupport.contactSupport'.tr(),
                'helpSupport.supportEmail'.tr(),
                Icons.support_agent,
                onContactSupport ?? () => _showContactSupport(context),
                isSmallScreen,
              ),
              const Divider(height: 1),
              _buildSettingTile(
                context,
                'helpSupport.terms'.tr(),
                'helpSupport.termsDescription'.tr(),
                Icons.description_outlined,
                onTerms ?? () => _showTerms(context),
                isSmallScreen,
              ),
              const Divider(height: 1),
              _buildSettingTile(
                context,
                'helpSupport.privacy'.tr(),
                'helpSupport.privacyDescription'.tr(),
                Icons.privacy_tip_outlined,
                onPrivacy ?? () => _showPrivacyPolicy(context),
                isSmallScreen,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isSmallScreen,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 8 : 12,
      ),
      leading: Icon(icon, color: const Color(0xFF03A696)),
      title: Text(
        title,
        style: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: isSmallScreen ? 14 : 16,
          color: const Color(0xFF2C3E50),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.quicksand(
          fontSize: isSmallScreen ? 11 : 12,
          color: const Color(0xFF7F8C8D),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _navigateToChatbot(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => GetIt.instance<ChatbotBloc>(),
          child: const ChatbotPage(),
        ),
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'helpSupport.contactDialogTitle'.tr(),
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'helpSupport.contactDialogMessage'.tr(),
          style: GoogleFonts.quicksand(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'helpSupport.close'.tr(),
              style: GoogleFonts.quicksand(
                color: const Color(0xFF03A696),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTerms(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('helpSupport.terms'.tr(), style: GoogleFonts.quicksand()),
        backgroundColor: const Color(0xFF03A696),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'helpSupport.privacy'.tr(),
          style: GoogleFonts.quicksand(),
        ),
        backgroundColor: const Color(0xFF03A696),
      ),
    );
  }
}
