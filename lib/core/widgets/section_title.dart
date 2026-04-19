import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? right;

  const SectionTitle({
    super.key,
    required this.title,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ObsidianTheme.text3,
              letterSpacing: 0.07 * 11, // 0.07em
            ),
          ),
          if (right != null) ...[
            const Spacer(),
            right!,
          ],
        ],
      ),
    );
  }
}
