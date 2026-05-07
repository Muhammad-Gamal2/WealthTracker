import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/features/settings/presentation/settings_signals.dart';

class ObsidianTheme {
  ObsidianTheme._();

  // ─── Dark palette ──────────────────────────────────────────────
  static const Color _darkBg = Color(0xFF07090F);
  static const Color _darkSurface = Color(0xFF0D1119);
  static const Color _darkSurface2 = Color(0xFF141B28);
  static const Color _darkCard = Color(0x09FFFFFF);
  static const Color _darkCardHover = Color(0x10FFFFFF);
  static const Color _darkBorder = Color(0x13FFFFFF);
  static const Color _darkText1 = Color(0xFFEEF2FF);
  static const Color _darkText2 = Color(0x9EEEF2FF);
  static const Color _darkText3 = Color(0x57EEF2FF);
  static const Color _darkAccentBg = Color(0x215B9BFF);
  static const Color _darkAccentGlow = Color(0x615B9BFF);
  static const Color _darkHeaderBg = Color(0xB807090F);
  static const Color _darkNavBg = Color(0xF007090F);
  static const Color _darkInputFill = Color(0x0DFFFFFF);

  // ─── Light palette ─────────────────────────────────────────────
  static const Color _lightBg = Color(0xFFF5F6FA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurface2 = Color(0xFFF0F1F5);
  static const Color _lightCard = Color(0x08000000);
  static const Color _lightCardHover = Color(0x0F000000);
  static const Color _lightBorder = Color(0x1F000000);
  static const Color _lightText1 = Color(0xFF1A1D26);
  static const Color _lightText2 = Color(0x991A1D26);
  static const Color _lightText3 = Color(0x571A1D26);
  static const Color _lightAccentBg = Color(0x1A5B9BFF);
  static const Color _lightAccentGlow = Color(0x335B9BFF);
  static const Color _lightHeaderBg = Color(0xDDF5F6FA);
  static const Color _lightNavBg = Color(0xF0F5F6FA);
  static const Color _lightInputFill = Color(0x0A000000);

  // ─── Reactive getters ──────────────────────────────────────────
  static bool get _isDark => isDarkModeSignal.value;

  static Color get bg => _isDark ? _darkBg : _lightBg;
  static Color get surface => _isDark ? _darkSurface : _lightSurface;
  static Color get surface2 => _isDark ? _darkSurface2 : _lightSurface2;
  static Color get card => _isDark ? _darkCard : _lightCard;
  static Color get cardHover => _isDark ? _darkCardHover : _lightCardHover;
  static Color get border => _isDark ? _darkBorder : _lightBorder;

  static Color get text1 => _isDark ? _darkText1 : _lightText1;
  static Color get text2 => _isDark ? _darkText2 : _lightText2;
  static Color get text3 => _isDark ? _darkText3 : _lightText3;

  static Color get accentBg => _isDark ? _darkAccentBg : _lightAccentBg;
  static Color get accentGlow => _isDark ? _darkAccentGlow : _lightAccentGlow;
  static Color get headerBg => _isDark ? _darkHeaderBg : _lightHeaderBg;
  static Color get navBg => _isDark ? _darkNavBg : _lightNavBg;
  static Color get inputFill => _isDark ? _darkInputFill : _lightInputFill;

  // ─── Accent (same in both themes) ──────────────────────────────
  static const Color accent = Color(0xFF5B9BFF);

  // ─── Category colors (same in both themes) ────────────────────
  static const Color gold = Color(0xFFFFCA28);
  static const Color goldBg = Color(0x1FFFCA28);
  static const Color green = Color(0xFF34D399);
  static const Color greenBg = Color(0x1F34D399);
  static const Color cyan = Color(0xFF38BDF8);
  static const Color cyanBg = Color(0x1F38BDF8);
  static const Color orange = Color(0xFFFB923C);
  static const Color orangeBg = Color(0x1FFB923C);

  // ─── Status colors (same in both themes) ──────────────────────
  static const Color gainGreen = Color(0xFF34D399);
  static const Color gainGreenBg = Color(0x1F34D399);
  static const Color lossRed = Color(0xFFF87171);
  static const Color lossRedBg = Color(0x1FF87171);

  // ─── Shape ─────────────────────────────────────────────────────
  static const double radius = 14.0;

  // ─── Text style helpers ────────────────────────────────────────

  static TextStyle displayStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? text1,
    );
  }

  static TextStyle bodyStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? text1,
    );
  }

  static TextStyle monoStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.dmMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? text1,
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
              ? accent.withValues(alpha: 0.20)
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

  // ─── Dark theme data ──────────────────────────────────────────

  static ThemeData darkTheme() {
    return _buildTheme(
      brightness: Brightness.dark,
      bg: _darkBg,
      surface: _darkSurface,
      surface2: _darkSurface2,
      card: _darkCard,
      border: _darkBorder,
      text1: _darkText1,
      text2: _darkText2,
      text3: _darkText3,
      accentBg: _darkAccentBg,
      navBg: _darkNavBg,
      inputFill: _darkInputFill,
    );
  }

  // ─── Light theme data ─────────────────────────────────────────

  static ThemeData lightTheme() {
    return _buildTheme(
      brightness: Brightness.light,
      bg: _lightBg,
      surface: _lightSurface,
      surface2: _lightSurface2,
      card: _lightCard,
      border: _lightBorder,
      text1: _lightText1,
      text2: _lightText2,
      text3: _lightText3,
      accentBg: _lightAccentBg,
      navBg: _lightNavBg,
      inputFill: _lightInputFill,
    );
  }

  // ─── Shared theme builder ─────────────────────────────────────

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surface2,
    required Color card,
    required Color border,
    required Color text1,
    required Color text2,
    required Color text3,
    required Color accentBg,
    required Color navBg,
    required Color inputFill,
  }) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark()
        : ThemeData.light();

    final dmSansBase = GoogleFonts.dmSansTextTheme(base.textTheme);

    final textTheme = dmSansBase.copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 57, fontWeight: FontWeight.w700, color: text1,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 45, fontWeight: FontWeight.w700, color: text1,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 36, fontWeight: FontWeight.w600, color: text1,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32, fontWeight: FontWeight.w600, color: text1,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28, fontWeight: FontWeight.w600, color: text1,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 24, fontWeight: FontWeight.w500, color: text1,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22, fontWeight: FontWeight.w600, color: text1,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w600, color: text1,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w600, color: text1,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w400, color: text1,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w400, color: text1,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w400, color: text2,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w600, color: text1,
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w500, color: text2,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11, fontWeight: FontWeight.w500, color: text3,
      ),
    );

    final colorScheme = ColorScheme(
      brightness: brightness,
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
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      fontFamily: GoogleFonts.dmSans().fontFamily,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20, fontWeight: FontWeight.w600, color: text1,
        ),
        iconTheme: IconThemeData(color: text2, size: 22),
        actionsIconTheme: IconThemeData(color: text2, size: 22),
      ),

      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navBg,
        elevation: 0,
        height: 68,
        indicatorColor: accentBg,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accent, size: 22);
          }
          return IconThemeData(color: text3, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.dmSans(
              fontSize: 11, fontWeight: FontWeight.w600, color: accent,
            );
          }
          return GoogleFonts.dmSans(
            fontSize: 11, fontWeight: FontWeight.w500, color: text3,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

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

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: border, width: 1),
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
          fontSize: 14, fontWeight: FontWeight.w400, color: text2,
        ),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w400, color: text3,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border, width: 1),
        ),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20, fontWeight: FontWeight.w600, color: text1,
        ),
        contentTextStyle: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w400, color: text2,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(accent),
          foregroundColor: WidgetStatePropertyAll(bg),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
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

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(text2),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: surface2,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border, width: 1),
        ),
        textStyle: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w400, color: text1,
        ),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return accentBg;
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return accent;
            return text3;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: border, width: 1),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface2,
        contentTextStyle: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w400, color: text1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return text3;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentBg;
          return border;
        }),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: text2,
        textColor: text1,
        subtitleTextStyle: GoogleFonts.dmSans(
          fontSize: 12, fontWeight: FontWeight.w400, color: text2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
