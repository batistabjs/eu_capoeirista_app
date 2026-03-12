import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final AuthService authService;

  const UserAvatar({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'logout') {
          await authService.signOut();
        }
      },
      color: AppTheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.border),
      ),
      offset: const Offset(0, 44),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authService.userDisplayName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                authService.userEmail,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 15, color: AppTheme.danger),
              SizedBox(width: 8),
              Text(
                'Sair',
                style: TextStyle(fontSize: 13, color: AppTheme.danger),
              ),
            ],
          ),
        ),
      ],
      child: _buildAvatar(),
    );
  }

  Widget _buildAvatar() {
    final photoUrl = authService.userPhotoUrl;
    final name = authService.userDisplayName;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border, width: 1.5),
      ),
      child: ClipOval(
        child: photoUrl != null
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitials(name),
              )
            : _buildInitials(name),
      ),
    );
  }

  Widget _buildInitials(String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').take(2).map((p) => p[0].toUpperCase()).join()
        : '?';

    return Container(
      color: AppTheme.accentBlue,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
