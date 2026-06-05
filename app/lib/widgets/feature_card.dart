import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Card fitur yang responsif terhadap sentuhan.
/// Menggunakan [Material] + [InkWell] agar ripple effect terlihat.
/// [onTap] bersifat opsional — jika null, card tetap tampil tapi non-interaktif.
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? bgColor;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: AppTheme.softGreen,
        highlightColor: AppTheme.softGreen.withValues(alpha: 0.6),
        child: Container(
          decoration: AppTheme.cardDecoration(borderRadius: 28, color: bgColor),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.softGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 28, color: AppTheme.primaryGreen),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
