import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget responsive para mostrar la información del usuario
class UserInfoCardWidget extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onEditProfile;

  const UserInfoCardWidget({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        final padding = isSmallScreen ? 20.0 : 32.0;
        final avatarRadius = isSmallScreen ? 50.0 : 70.0;
        final fontSize = isSmallScreen ? 24.0 : 28.0;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: 600, // Limitar ancho máximo para tablets
          ),
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
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: const Color(0xFF03A696),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  userName,
                  style: GoogleFonts.quicksand(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  userEmail,
                  style: GoogleFonts.quicksand(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: const Color(0xFF7F8C8D),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onEditProfile,
                    icon: const Icon(Icons.edit, size: 20),
                    label: Text(
                      'Editar Perfil',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03A696),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 24 : 32,
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

