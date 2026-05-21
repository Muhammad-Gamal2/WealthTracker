import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? titleEn;
  final Widget? right;

  const SectionTitle({
    super.key,
    required this.title,
    this.titleEn,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.reemKufi(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ObsidianTheme.text1,
              ),
            ),
            if (titleEn != null) ...[
              const SizedBox(width: 8),
              Text(
                titleEn!.toUpperCase(),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: ObsidianTheme.text3,
                  letterSpacing: 0.18 * 9, // 0.18em
                ),
              ),
            ],
            if (right != null) ...[
              const Spacer(),
              right!,
            ],
          ],
        ),
      ),
    );
  }
}
