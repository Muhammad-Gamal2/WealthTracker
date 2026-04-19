import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ObsidianTheme {
  ObsidianTheme._();

  // ─── Core surfaces ──────────────────────────────────────────────
  static const Color bg = Color(0xFF07090F);
  static const Color surface = Color(0xFF0D1119);
  static const Color surface2 = Color(0xFF141B28);
  static const Color card = Color(0x09FFFFFF); // rgba(255,255,255,0.035)
  static const Color cardHover = Color(0x10FFFFFF); // rgba(255,255,255,0.062)
  static const Color border = Color(0x13FFFFFF); // rgba(255,255,255,0.075)

  // ─── Text ───────────────────────────────────────────────────────
  static const Color text1 = Color(0xFFEEF2FF);
  static const Color text2 = Color(0x9EEEF2FF); // rgba(238,242,255,0.62)
  static const Color text3 = Color(0x57EEF2FF); // rgba(238,242,255,0.34)

  // ─── Accent (electric blue) ─────────────────────────────────────
  static const Color accent = Color(0xFF5B9BFF);
  static const Color accentBg = Color(0x215B9BFF); // rgba(91,155,255,0.13)
  static const Color accentGlow = Color(0x615B9BFF); // rgba(91,155,255,0.38)

  // ─── Category colors ───────────────────────────────────────────
  static const Color gold = Color(0xFFFFCA28);
  static const Color goldBg = Color(0x1FFFCA28); // rgba(255,202,40,0.12)
  static const Color green = Color(0xFF34D399);
  static const Color greenBg = Color(0x1F34D399); // rgba(52,211,153,0.12)
  static const Color cyan = Color(0xFF38BDF8);
  static const Color cyanBg = Color(0x1F38BDF8); // rgba(56,189,248,0.12)
  static const Color orange = Color(0xFFFB923C);
  static const Color orangeBg = Color(0x1FFB923C); // rgba(251,146,60,0.12)

  // ─── Status colors ─────────────────────────────────────────────
  static const Color gainGreen = Color(0xFF34D399);
  static const Color gainGreenBg = Color(0x1F34D399);
  static const Color lossRed = Color(0xFFF87171);
  static const Color lossRedBg = Color(0x1FF87171); // rgba(248,113,113,0.12)

  // ─── Shape ─────────────────────────────────────────────────────
  static const double radius = 14.0;

  // ─── Text style helpers ────────────────────────────────────────

  /// Space Grotesk for display / headings (weight 500-700)
  static TextStyle displayStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    Color color = text1,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// DM Sans for body text (weight 400-700)
  static TextStyle bodyStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = text1,
  }) {
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// DM Mono for numbers / monospaced (weight 400-500)
  static TextStyle monoStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = text1,
  }) {
    return GoogleFonts.dmMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // ─── Glass card decoration ─────────────────────────────────────

  static BoxDecoration cardDecoration({Color? accent}) {
    return BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(radius),
      border: Border(
        top: BorderSide(
          color: accent != null
              ? accent.withValues(alpha: 0.33)
              : border,
          width: 1,
        ),
        left: BorderSide(
          color: accent != null
              ? accent.withValues(alpha: 0.20)
              : border,
          width: 1,
        ),
        right: BorderSide(
          color: accent != null
              ? accent.withValues(alpha: 0.20)
              : border,
          width: 1,
        ),
        bottom: BorderSide(
          color: accent != null
              ? accent.withValues(alpha: 0.20)
              : border,
          width: 1,
        ),
      ),
    );
  }

  // ─── Theme data ────────────────────────────────────────────────

  static ThemeData darkTheme() {
    final dmSansBase = GoogleFonts.dmSansTextTheme(
      ThemeData.dark().textTheme,
    );

    final textTheme = dmSansBase.copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: text1,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: text1,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: text1,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: text1,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: text1,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: text1,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: text1,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: text1,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: text1,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: text1,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: text1,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: text2,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: text1,
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: text2,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: text3,
      ),
    );

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: accent,
      onPrimary: bg,
      primaryContainer: accentBg,
      onPrimaryContainer: accent,
      secondary: cyan,
      onSecondary: bg,
      secondaryContainer: cyanBg,
      onSecondaryContainer: cyan,
      tertiary: gold,
      onTertiary: bg,
      tertiaryContainer: goldBg,
      onTertiaryContainer: gold,
      error: lossRed,
      onError: bg,
      errorContainer: lossRedBg,
      onErrorContainer: lossRed,
      surface: surface,
      onSurface: text1,
      onSurfaceVariant: text2,
      outline: border,
      outlineVariant: border,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: text1,
      onInverseSurface: bg,
      inversePrimary: const Color(0xFF1A3A6E),
      surfaceContainerHighest: surface2,
      surfaceContainerHigh: surface2,
      surfaceContainer: surface,
      surfaceContainerLow: bg,
      surfaceContainerLowest: bg,
      surfaceDim: bg,
      surfaceBright: surface2,
      surfaceTint: accent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      fontFamily: GoogleFonts.dmSans().fontFamily,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: text1,
        ),
        iconTheme: const IconThemeData(color: text2, size: 22),
        actionsIconTheme: const IconThemeData(color: text2, size: 22),
      ),

      // Card
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // NavigationBar (bottom nav for mobile)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xF007090F), // rgba(7,9,15,0.94)
        elevation: 0,
        height: 68,
        indicatorColor: accentBg,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accent, size: 22);
          }
          return const IconThemeData(color: text3, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: accent,
            );
          }
          return GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: text3,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: bg,
        elevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x0DFFFFFF), // rgba(255,255,255,0.05)
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: lossRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: lossRed, width: 1.5),
        ),
        labelStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: text2,
        ),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: text3,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: surface2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: border, width: 1),
        ),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: text1,
        ),
        contentTextStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: text2,
        ),
      ),

      // FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(accent),
          foregroundColor: WidgetStatePropertyAll(bg),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(text2),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        color: surface2,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: border, width: 1),
        ),
        textStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: text1,
        ),
      ),

      // SegmentedButton
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accentBg;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accent;
            }
            return text3;
          }),
          side: const WidgetStatePropertyAll(
            BorderSide(color: border, width: 1),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface2,
        contentTextStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: text1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: border, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accent;
          }
          return text3;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentBg;
          }
          return border;
        }),
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        iconColor: text2,
        textColor: text1,
        subtitleTextStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: text2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
