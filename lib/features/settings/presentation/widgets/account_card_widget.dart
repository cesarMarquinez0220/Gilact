import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

/// Widget responsive para mostrar opciones de cuenta
class AccountCardWidget extends StatelessWidget {
  final VoidCallback? onDeleteAccount;
  final VoidCallback? onSignOut;

  const AccountCardWidget({
    super.key,
    this.onDeleteAccount,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        final maxWidth = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600 ? (constraints.maxWidth - 600) / 2 : 0,
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
                'account.deleteAccount'.tr(),
                'account.deleteAccountDescription'.tr(),
                Icons.delete_outline,
                onDeleteAccount ?? () => _showDeleteAccount(context),
                isSmallScreen,
                isDestructive: true,
              ),
              const Divider(height: 1),
              _buildSettingTile(
                context,
                'account.signOut'.tr(),
                'account.signOutDescription'.tr(),
                Icons.logout,
                onSignOut ?? () => _showSignOut(context),
                isSmallScreen,
                isDestructive: true,
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
    bool isSmallScreen, {
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 8 : 12,
      ),
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF03A696),
      ),
      title: Text(
        title,
        style: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: isSmallScreen ? 14 : 16,
          color: isDestructive ? Colors.red : const Color(0xFF2C3E50),
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

  void _showDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'account.deleteAccountConfirmTitle'.tr(),
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'account.deleteAccountConfirmMessage'.tr(),
          style: GoogleFonts.quicksand(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'account.cancel'.tr(),
              style: GoogleFonts.quicksand(
                color: const Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'account.featureInDevelopment'.tr(),
                    style: GoogleFonts.quicksand(),
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'account.delete'.tr(),
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'account.signOutConfirmTitle'.tr(),
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        content: Text(
          'account.signOutConfirmMessage'.tr(),
          style: GoogleFonts.quicksand(
            fontSize: 16,
            color: const Color(0xFF7F8C8D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'account.cancel'.tr(),
              style: GoogleFonts.quicksand(
                color: const Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onSignOut?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'account.signOut'.tr(),
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

