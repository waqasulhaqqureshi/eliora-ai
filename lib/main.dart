import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:connectivity_plus/connectivity_plus.dart';
import 'firebase_options.dart';
import 'package:flutter_local_agent_kit/flutter_local_agent_kit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mcp_dart/mcp_dart.dart' as mcp;
import 'package:markdown/markdown.dart' as md;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 0: LICENSE SERVICE
// ══════════════════════════════════════════════════════════════════════════════

class LicenseService {
  LicenseService._();
  static final instance = LicenseService._();

  final _db = FirebaseFirestore.instance;
  final ValueNotifier<bool> isLocked = ValueNotifier(false);
  StreamSubscription? _sub;

  Future<void> init() async {
    try {
      // Listen for changes in real-time
      _sub = _db.collection('license').doc('status').snapshots().listen((snap) {
        if (snap.exists) {
          isLocked.value = snap.data()?['is_locked'] ?? false;
        } else {
          isLocked.value = false; // Default to unlocked if doc doesn't exist
        }
      });
    } catch (e) {
      debugPrint('LicenseService init error: $e');
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR TOKENS
// ══════════════════════════════════════════════════════════════════════════════

abstract final class ElioraColors {
  static const List<Color> ringDark = [
    Color(0xFF3174F1),
    Color(0xFF85B1F8),
    Color(0xFFFF8A65),
    Color(0xFFE53935),
    Color(0xFF7FCFFF),
    Color(0xFFD3E3FD),
    Color(0xFFFF6B35),
    Color(0xFF3174F1),
  ];
  static const List<Color> ringLight = [
    Color(0xFF0B57D0),
    Color(0xFF669DF6),
    Color(0xFFFF9800),
    Color(0xFFE53935),
    Color(0xFFA8C7FA),
    Color(0xFFFF7043),
    Color(0xFF0B57D0),
  ];
  static List<Color> ringForBrightness(Brightness b) =>
      b == Brightness.dark ? ringDark : ringLight;
}

abstract final class DarkTokens {
  static const primary = Color(0xFFA8C7FA);
  static const onPrimary = Color(0xFF062E6F);
  static const primaryContainer = Color(0xFF0842A0);
  static const onPrimaryContainer = Color(0xFFD3E3FD);
  static const secondary = Color(0xFF7FCFFF);
  static const onSecondary = Color(0xFF003355);
  static const secondaryContainer = Color(0xFF004A77);
  static const onSecondaryContainer = Color(0xFFC2E7FF);
  static const tertiary = Color(0xFF6DD58C);
  static const onTertiary = Color(0xFF0A3818);
  static const tertiaryContainer = Color(0xFF0F5223);
  static const onTertiaryContainer = Color(0xFFC4EED0);
  static const error = Color(0xFFF2B8B5);
  static const onError = Color(0xFF601410);
  static const errorContainer = Color(0xFF8C1D18);
  static const onErrorContainer = Color(0xFFF9DEDC);
  static const surface = Color(0xFF131314);
  static const onSurface = Color(0xFFE3E3E3);
  static const onSurfaceVariant = Color(0xFFC4C7C5);
  static const outline = Color(0xFF8E918F);
  static const outlineVariant = Color(0xFF444746);
  static const inverseSurface = Color(0xFFE3E3E3);
  static const onInverseSurface = Color(0xFF303030);
  static const inversePrimary = Color(0xFF0B57D0);
  static const surfaceDim = Color(0xFF131314);
  static const surfaceBright = Color(0xFF37393B);
  static const surfaceContainerLowest = Color(0xFF0E0E0E);
  static const surfaceContainerLow = Color(0xFF1B1B1B);
  static const surfaceContainer = Color(0xFF1E1F20);
  static const surfaceContainerHigh = Color(0xFF282A2C);
  static const surfaceContainerHighest = Color(0xFF333537);
  static const gradientStart = Color(0xFF85B1F8);
  static const gradientEnd = Color(0xFF3174F1);
  static const tabBlue = Color(0xFF3174F1);
  static const userBubble = Color(0xFF1F3760);
  static const success = Color(0xFFA1CE83);
}

abstract final class LightTokens {
  static const primary = Color(0xFF0B57D0);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFD3E3FD);
  static const onPrimaryContainer = Color(0xFF0842A0);
  static const secondary = Color(0xFF00639B);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFC2E7FF);
  static const onSecondaryContainer = Color(0xFF004A77);
  static const tertiary = Color(0xFF146C2E);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFC4EED0);
  static const onTertiaryContainer = Color(0xFF0F5223);
  static const error = Color(0xFFB3261E);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFF9DEDC);
  static const onErrorContainer = Color(0xFF8C1D18);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1F1F1F);
  static const onSurfaceVariant = Color(0xFF444746);
  static const outline = Color(0xFF747775);
  static const outlineVariant = Color(0xFFC4C7C5);
  static const inverseSurface = Color(0xFF303030);
  static const onInverseSurface = Color(0xFFF2F2F2);
  static const inversePrimary = Color(0xFFA8C7FA);
  static const surfaceDim = Color(0xFFD3DBE5);
  static const surfaceBright = Color(0xFFFFFFFF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF8FAFD);
  static const surfaceContainer = Color(0xFFF0F4F9);
  static const surfaceContainerHigh = Color(0xFFE9EEF6);
  static const surfaceContainerHighest = Color(0xFFDDE3EA);
  static const gradientStart = Color(0xFF3174F1);
  static const gradientEnd = Color(0xFF85B1F8);
  static const success = Color(0xFF146C2E);
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: THEME BUILDERS
// ══════════════════════════════════════════════════════════════════════════════

ThemeData _buildDark() {
  const cs = ColorScheme(
    brightness: Brightness.dark,
    primary: DarkTokens.primary,
    onPrimary: DarkTokens.onPrimary,
    primaryContainer: DarkTokens.primaryContainer,
    onPrimaryContainer: DarkTokens.onPrimaryContainer,
    secondary: DarkTokens.secondary,
    onSecondary: DarkTokens.onSecondary,
    secondaryContainer: DarkTokens.secondaryContainer,
    onSecondaryContainer: DarkTokens.onSecondaryContainer,
    tertiary: DarkTokens.tertiary,
    onTertiary: DarkTokens.onTertiary,
    tertiaryContainer: DarkTokens.tertiaryContainer,
    onTertiaryContainer: DarkTokens.onTertiaryContainer,
    error: DarkTokens.error,
    onError: DarkTokens.onError,
    errorContainer: DarkTokens.errorContainer,
    onErrorContainer: DarkTokens.onErrorContainer,
    surface: DarkTokens.surface,
    onSurface: DarkTokens.onSurface,
    surfaceDim: DarkTokens.surfaceDim,
    surfaceBright: DarkTokens.surfaceBright,
    surfaceContainerLowest: DarkTokens.surfaceContainerLowest,
    surfaceContainerLow: DarkTokens.surfaceContainerLow,
    surfaceContainer: DarkTokens.surfaceContainer,
    surfaceContainerHigh: DarkTokens.surfaceContainerHigh,
    surfaceContainerHighest: DarkTokens.surfaceContainerHighest,
    onSurfaceVariant: DarkTokens.onSurfaceVariant,
    outline: DarkTokens.outline,
    outlineVariant: DarkTokens.outlineVariant,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: DarkTokens.inverseSurface,
    onInverseSurface: DarkTokens.onInverseSurface,
    inversePrimary: DarkTokens.inversePrimary,
  );
  final tt = GoogleFonts.nunitoTextTheme(
    ThemeData.dark().textTheme,
  ).apply(bodyColor: DarkTokens.onSurface, displayColor: DarkTokens.onSurface);
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: cs,
    textTheme: tt,
    scaffoldBackgroundColor: DarkTokens.surface,
    cardColor: DarkTokens.surfaceContainerLow,
    drawerTheme: const DrawerThemeData(
      backgroundColor: DarkTokens.surfaceContainer,
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: DarkTokens.surface,
      foregroundColor: DarkTokens.onSurface,
      titleTextStyle: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    dividerTheme: const DividerThemeData(
      color: DarkTokens.outlineVariant,
      thickness: 1,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: DarkTokens.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: DarkTokens.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: DarkTokens.surfaceContainerHighest,
      contentTextStyle: tt.bodyMedium?.copyWith(color: DarkTokens.onSurface),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: DarkTokens.primary,
      linearTrackColor: DarkTokens.surfaceContainerHighest,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: DarkTokens.primaryContainer,
        foregroundColor: DarkTokens.onPrimaryContainer,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DarkTokens.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DarkTokens.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DarkTokens.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DarkTokens.primary, width: 2),
      ),
    ),
  );
}

ThemeData _buildLight() {
  const cs = ColorScheme(
    brightness: Brightness.light,
    primary: LightTokens.primary,
    onPrimary: LightTokens.onPrimary,
    primaryContainer: LightTokens.primaryContainer,
    onPrimaryContainer: LightTokens.onPrimaryContainer,
    secondary: LightTokens.secondary,
    onSecondary: LightTokens.onSecondary,
    secondaryContainer: LightTokens.secondaryContainer,
    onSecondaryContainer: LightTokens.onSecondaryContainer,
    tertiary: LightTokens.tertiary,
    onTertiary: LightTokens.onTertiary,
    tertiaryContainer: LightTokens.tertiaryContainer,
    onTertiaryContainer: LightTokens.onTertiaryContainer,
    error: LightTokens.error,
    onError: LightTokens.onError,
    errorContainer: LightTokens.errorContainer,
    onErrorContainer: LightTokens.onErrorContainer,
    surface: LightTokens.surface,
    onSurface: LightTokens.onSurface,
    surfaceDim: LightTokens.surfaceDim,
    surfaceBright: LightTokens.surfaceBright,
    surfaceContainerLowest: LightTokens.surfaceContainerLowest,
    surfaceContainerLow: LightTokens.surfaceContainerLow,
    surfaceContainer: LightTokens.surfaceContainer,
    surfaceContainerHigh: LightTokens.surfaceContainerHigh,
    surfaceContainerHighest: LightTokens.surfaceContainerHighest,
    onSurfaceVariant: LightTokens.onSurfaceVariant,
    outline: LightTokens.outline,
    outlineVariant: LightTokens.outlineVariant,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: LightTokens.inverseSurface,
    onInverseSurface: LightTokens.onInverseSurface,
    inversePrimary: LightTokens.inversePrimary,
  );
  final tt = GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme).apply(
    bodyColor: LightTokens.onSurface,
    displayColor: LightTokens.onSurface,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: cs,
    textTheme: tt,
    scaffoldBackgroundColor: LightTokens.surface,
    cardColor: LightTokens.surfaceContainerLow,
    drawerTheme: const DrawerThemeData(
      backgroundColor: LightTokens.surfaceContainer,
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: LightTokens.surface,
      foregroundColor: LightTokens.onSurface,
      titleTextStyle: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    dividerTheme: const DividerThemeData(
      color: LightTokens.outlineVariant,
      thickness: 1,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: LightTokens.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: LightTokens.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: LightTokens.surfaceContainerHighest,
      contentTextStyle: tt.bodyMedium?.copyWith(color: LightTokens.onSurface),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: LightTokens.primary,
      linearTrackColor: LightTokens.surfaceContainerHighest,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: LightTokens.primaryContainer,
        foregroundColor: LightTokens.onPrimaryContainer,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LightTokens.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: LightTokens.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: LightTokens.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: LightTokens.primary, width: 2),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: GRADIENT TITLE
// ══════════════════════════════════════════════════════════════════════════════

class GradientTitle extends StatelessWidget {
  const GradientTitle({super.key, required this.text, this.style, this.align});
  final String text;
  final TextStyle? style;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base =
        style ??
        Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ) ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
    final colors = dark
        ? const [DarkTokens.gradientStart, DarkTokens.gradientEnd]
        : const [LightTokens.gradientStart, LightTokens.gradientEnd];
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (b) => LinearGradient(colors: colors).createShader(b),
      child: Text(
        text,
        textAlign: align,
        style: base.copyWith(color: Colors.white),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: DEVICE RAM
// ══════════════════════════════════════════════════════════════════════════════

Future<double?> _readDeviceRamGb() async {
  try {
    if (Platform.isAndroid || Platform.isLinux) {
      final raw = await File('/proc/meminfo').readAsString();
      for (final line in raw.split('\n')) {
        if (line.startsWith('MemTotal:')) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length >= 2) {
            final kb = int.tryParse(parts[1]);
            if (kb != null) return kb / (1024 * 1024);
          }
        }
      }
    } else if (Platform.isMacOS || Platform.isIOS) {
      final r = await Process.run('sysctl', ['-n', 'hw.memsize']);
      if (r.exitCode == 0) {
        final bytes = int.tryParse(r.stdout.toString().trim());
        if (bytes != null) return bytes / (1024 * 1024 * 1024);
      }
    } else if (Platform.isWindows) {
      final r = await Process.run('wmic', [
        'computersystem',
        'get',
        'TotalPhysicalMemory',
      ]);
      if (r.exitCode == 0) {
        for (final line in r.stdout.toString().split('\n')) {
          final t = line.trim();
          if (t.isEmpty || t.contains('TotalPhysicalMemory')) continue;
          final bytes = int.tryParse(t);
          if (bytes != null) return bytes / (1024 * 1024 * 1024);
        }
      }
    }
  } catch (_) {}
  return null;
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: SYSTEM PROMPT ENGINE
// The root cause of the HTML hallucination: no system prompt + wrong context.
// Each model family needs a specific, carefully crafted system prompt that
// explicitly tells the model what it is and what NOT to do.
// ══════════════════════════════════════════════════════════════════════════════

class SystemPromptEngine {
  SystemPromptEngine._();

  /// Returns the correct system prompt for the given model id/name.
  /// Tiny models (SmolLM, TinyLlama, Qwen 0.5B) need very short, direct prompts.
  /// Larger models can handle richer instructions.
  static String forModel(String modelId, String modelName) {
    final id = modelId.toLowerCase();
    final n = modelName.toLowerCase();

    // ── Ultra-tiny: SmolLM family ──────────────────────────────────────────
    // SmolLM2 uses HuggingFaceTB chat template. Very short prompt is critical.
    if (id.contains('smollm')) {
      return 'You are a helpful assistant. Answer questions clearly and concisely. '
          'Do not generate HTML, XML, code, or web content unless the user explicitly asks for it. '
          'Respond only to what the user says.';
    }

    // ── Ultra-tiny: TinyLlama ─────────────────────────────────────────────
    // TinyLlama uses Zephyr/ChatML template. Keep it very brief.
    if (id.contains('tinyllama') || n.contains('tinyllama')) {
      return 'You are a helpful AI assistant. Give short, direct answers. '
          'Never generate HTML or web code unless asked. '
          'Only respond to what the user asks.';
    }

    // ── Tiny: Qwen 0.5B ───────────────────────────────────────────────────
    if (n.contains('0.5b') || id.contains('0.5b')) {
      return 'You are Eliora AI, a helpful assistant running locally on the user\'s device. '
          'Answer questions directly and helpfully. '
          'Do not output HTML, XML, markdown code blocks, or web content unless the user requests it. '
          'Keep answers concise.';
    }

    // ── Small: Qwen 1.5B ──────────────────────────────────────────────────
    if ((n.contains('qwen') && n.contains('1.5')) ||
        (id.contains('qwen') && id.contains('1.5'))) {
      return _standardPrompt('Eliora AI');
    }

    // ── Small/Mid: Gemma 2B ───────────────────────────────────────────────
    if (n.contains('gemma') || id.contains('gemma')) {
      return _standardPrompt('Eliora AI');
    }

    // ── Mid: Phi family ───────────────────────────────────────────────────
    if (n.contains('phi') || id.contains('phi')) {
      return _standardPrompt('Eliora AI');
    }

    // ── Large: Mistral 7B+ ────────────────────────────────────────────────
    if (n.contains('mistral') || id.contains('mistral')) {
      return _fullPrompt('Eliora AI');
    }

    // ── Large: Llama 3+ ───────────────────────────────────────────────────
    if (n.contains('llama') || id.contains('llama')) {
      return _fullPrompt('Eliora AI');
    }

    // ── Default fallback ──────────────────────────────────────────────────
    return _standardPrompt('Eliora AI');
  }

  static String _standardPrompt(String name) =>
      'You are $name, a helpful AI assistant running entirely on the user\'s '
      'device with full privacy. '
      'Answer questions clearly, accurately, and helpfully. '
      'Do not generate HTML, XML, or web page content unless the user explicitly requests it. '
      'Do not repeat the user\'s question back to them. '
      'Respond directly and conversationally.';

  static String _fullPrompt(String name) =>
      'You are $name, a powerful local AI assistant running entirely on-device. '
      'Your capabilities include: answering questions, summarizing text, writing assistance, '
      'code help, analysis, and general conversation. '
      '\n\nGuidelines:\n'
      '- Be helpful, accurate, and concise\n'
      '- Do NOT generate HTML, XML, or web markup unless the user explicitly asks\n'
      '- Do NOT repeat or paraphrase the user\'s question before answering\n'
      '- Use markdown formatting (bold, lists, code blocks) when it helps clarity\n'
      '- If you don\'t know something, say so honestly\n'
      '- Keep responses focused on what was actually asked\n'
      '\nYou run completely offline — no data leaves the device.';

  /// Returns a short capability description for the UI.
  static String tagline(String modelId) {
    final id = modelId.toLowerCase();
    if (id.contains('smollm')) return 'SmolLM2 · Ultra-compact assistant';
    if (id.contains('tinyllama')) return 'TinyLlama · Fast on-device chat';
    if (id.contains('0.5b')) return 'Qwen · Nano assistant';
    if (id.contains('1.5b')) return 'Qwen · Compact assistant';
    if (id.contains('gemma')) return 'Gemma 2 · Balanced assistant';
    if (id.contains('phi')) return 'Phi · Efficient assistant';
    if (id.contains('mistral')) return 'Mistral · Powerful assistant';
    if (id.contains('llama')) return 'Llama · Powerful assistant';
    return 'Local AI assistant';
  }

  /// Max tokens appropriate for model size — prevents runaway generation.
  static int maxTokensFor(String modelId) {
    final id = modelId.toLowerCase();
    if (id.contains('smollm')) return 200;
    if (id.contains('tinyllama') || id.contains('0.5b')) return 256;
    if (id.contains('1.5b')) return 400;
    if (id.contains('gemma') || id.contains('phi')) return 512;
    return 768;
  }

  /// Temperature — lower = more deterministic, less hallucination.
  static double temperatureFor(String modelId) {
    final id = modelId.toLowerCase();
    if (id.contains('smollm') ||
        id.contains('tinyllama') ||
        id.contains('0.5b')) {
      return 0.3; // Very low temp for tiny models = fewer hallucinations
    }
    if (id.contains('1.5b') || id.contains('gemma')) return 0.5;
    return 0.7;
  }
}

/// Kit [FlutterLocalAgentKit.initialize] takes a [PromptTemplate], not arbitrary system text.
PromptTemplate elioraPromptTemplateForModel(String modelId, String modelName) {
  final id = modelId.toLowerCase();
  final n = modelName.toLowerCase();
  if (id.contains('gemma') || n.contains('gemma')) return GemmaTemplate();
  if (id.contains('mistral') || n.contains('mistral')) return MistralTemplate();
  if (id.contains('qwen') || id.contains('smollm')) return ChatMlTemplate();
  if (id.contains('tinyllama')) return ChatMlTemplate();
  if (id.contains('llama')) return Llama3Template();
  if (id.contains('phi')) return ChatMlTemplate();
  return Llama3Template();
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 6: MODEL CATALOG
// ══════════════════════════════════════════════════════════════════════════════

enum DeviceTier { lowest, low, mid, flagship }

extension DeviceTierX on DeviceTier {
  String get label => switch (this) {
    DeviceTier.lowest => 'Smallest Mobiles',
    DeviceTier.low => 'Small Mobiles',
    DeviceTier.mid => 'Mid Range',
    DeviceTier.flagship => 'Flagship',
  };
  int get gpuLayers => switch (this) {
    DeviceTier.lowest => 8,
    DeviceTier.low => 16,
    DeviceTier.mid => 28,
    DeviceTier.flagship => 32,
  };
  Color get color => switch (this) {
    DeviceTier.lowest => const Color(0xFF6DD58C),
    DeviceTier.low => const Color(0xFF7FCFFF),
    DeviceTier.mid => const Color(0xFFFFD54F),
    DeviceTier.flagship => const Color(0xFFFF8A65),
  };
}

class ModelCapabilities {
  const ModelCapabilities({
    this.supportsVision = false,
    this.supportsFiles = true,
    this.supportsVoice = true,
    this.supportsRAG = true,
    this.supportsMCP = true,
    this.contextWindow = 2048,
    this.maxOutputTokens = 512,
  });
  final bool supportsVision;
  final bool supportsFiles;
  final bool supportsVoice;
  final bool supportsRAG;
  final bool supportsMCP;
  final int contextWindow;
  final int maxOutputTokens;
}

class CatalogEntry {
  const CatalogEntry({
    required this.definition,
    required this.tier,
    required this.minRamGb,
    required this.capabilities,
    required this.tag,
    required this.description,
  });
  final ModelDefinition definition;
  final DeviceTier tier;
  final int minRamGb;
  final ModelCapabilities capabilities;
  final String tag;
  final String description;

  String get sizeLabel {
    final mb = definition.estimatedSizeInBytes ~/ (1024 * 1024);
    return mb >= 1024 ? '${(mb / 1024).toStringAsFixed(1)} GB' : '$mb MB';
  }
}

class ElioraCatalog {
  ElioraCatalog._();

  static List<CatalogEntry> get all {
    final seen = <String>{};
    final raw = <CatalogEntry>[
      ..._custom,
      ...ModelManager.recommendedModels.map(_wrapKit),
    ];
    final out = <CatalogEntry>[];
    for (final e in raw) {
      if (seen.add(e.definition.id)) out.add(e);
    }
    out.sort(
      (a, b) => a.definition.estimatedSizeInBytes.compareTo(
        b.definition.estimatedSizeInBytes,
      ),
    );
    return out;
  }

  static CatalogEntry? byId(String id) {
    for (final e in all) {
      if (e.definition.id == id) return e;
    }
    return null;
  }

  static DeviceTier _tierFor(int bytes) {
    const mb = 1024 * 1024;
    if (bytes < 800 * mb) return DeviceTier.lowest;
    if (bytes < 2 * 1024 * mb) return DeviceTier.low;
    if (bytes < 5 * 1024 * mb) return DeviceTier.mid;
    return DeviceTier.flagship;
  }

  static int _minRam(int bytes) {
    final gb = bytes / (1024 * 1024 * 1024);
    return ((gb * 1.4).ceil() + 1).clamp(2, 16);
  }

  static CatalogEntry _wrapKit(ModelDefinition d) => CatalogEntry(
    definition: d,
    tier: _tierFor(d.estimatedSizeInBytes),
    minRamGb: _minRam(d.estimatedSizeInBytes),
    capabilities: _caps(d.id, d.name),
    tag: _tag(d.id, d.name),
    description: 'Recommended by flutter_local_agent_kit',
  );

  static ModelCapabilities _caps(String id, String name) {
    final n = name.toLowerCase();
    final vision =
        n.contains('vision') || id.contains('vision') || n.contains('llava');
    final textOnly =
        id.contains('smollm') || id.contains('tinyllama') || n.contains('0.5b');
    return ModelCapabilities(
      supportsVision: vision,
      supportsFiles: !textOnly,
      supportsVoice: !textOnly,
      supportsRAG: !textOnly,
      supportsMCP: !textOnly,
      contextWindow: _ctx(n),
      maxOutputTokens: textOnly ? 256 : 512,
    );
  }

  static int _ctx(String n) {
    if (n.contains('mistral') || n.contains('7b')) return 8192;
    if (n.contains('gemma')) return 8192;
    if (n.contains('qwen') && n.contains('1.5')) return 4096;
    if (n.contains('phi')) return 4096;
    return 2048;
  }

  static String _tag(String id, String name) {
    final n = name.toLowerCase();
    if (n.contains('vision') || id.contains('vision')) return 'Vision LLM';
    if (id.contains('smollm')) return 'SmolLM';
    if (n.contains('0.5b')) return 'Nano LLM';
    if (n.contains('tinyllama')) return 'Tiny LLM';
    if (n.contains('phi')) return 'Phi LLM';
    if (n.contains('gemma') && n.contains('2b')) return 'Gemma 2B';
    if (n.contains('qwen') && n.contains('1.5')) return 'Qwen 1.5B';
    if (n.contains('mistral')) return 'Mistral 7B';
    if (n.contains('llama') && n.contains('3')) return 'Llama 3';
    return 'LLM';
  }

  static final List<CatalogEntry> _custom = [
    CatalogEntry(
      definition: ModelDefinition(
        id: 'smollm2-360m-instruct-q4_k_m',
        name: 'SmolLM2 360M Instruct · Q4_K_M',
        url:
            'https://huggingface.co/bartowski/SmolLM2-360M-Instruct-GGUF'
            '/resolve/main/SmolLM2-360M-Instruct-Q4_K_M.gguf',
        estimatedSizeInBytes: 285 * 1024 * 1024,
      ),
      tier: DeviceTier.lowest,
      minRamGb: 2,
      capabilities: const ModelCapabilities(
        supportsVision: false,
        supportsFiles: false,
        supportsVoice: false,
        supportsRAG: false,
        supportsMCP: false,
        contextWindow: 2048,
        maxOutputTokens: 200,
      ),
      tag: 'SmolLM · Nano',
      description: 'Smallest possible — works on any Android with ≥ 2 GB RAM',
    ),
    CatalogEntry(
      definition: ModelDefinition(
        id: 'qwen2.5-0.5b-instruct-q4_k_m',
        name: 'Qwen 2.5 0.5B Instruct · Q4_K_M',
        url:
            'https://huggingface.co/bartowski/Qwen2.5-0.5B-Instruct-GGUF'
            '/resolve/main/Qwen2.5-0.5B-Instruct-Q4_K_M.gguf',
        estimatedSizeInBytes: 420 * 1024 * 1024,
      ),
      tier: DeviceTier.lowest,
      minRamGb: 2,
      capabilities: const ModelCapabilities(
        supportsVision: false,
        supportsFiles: false,
        supportsVoice: false,
        supportsRAG: false,
        supportsMCP: false,
        contextWindow: 2048,
        maxOutputTokens: 256,
      ),
      tag: 'Qwen · Nano',
      description: 'Ultra-compact multilingual model from Alibaba',
    ),
    CatalogEntry(
      definition: ModelDefinition(
        id: 'tinyllama-1.1b-chat-q4_k_m',
        name: 'TinyLlama 1.1B Chat · Q4_K_M',
        url:
            'https://huggingface.co/bartowski/TinyLlama-1.1B-Chat-v1.0-GGUF'
            '/resolve/main/TinyLlama-1.1B-Chat-v1.0-Q4_K_M.gguf',
        estimatedSizeInBytes: 650 * 1024 * 1024,
      ),
      tier: DeviceTier.lowest,
      minRamGb: 2,
      capabilities: const ModelCapabilities(
        supportsVision: false,
        supportsFiles: false,
        supportsVoice: false,
        supportsRAG: false,
        supportsMCP: false,
        contextWindow: 2048,
        maxOutputTokens: 256,
      ),
      tag: 'TinyLlama · Compact',
      description: 'Fast Llama-arch chat model for low-end phones',
    ),
    CatalogEntry(
      definition: ModelDefinition(
        id: 'qwen2.5-1.5b-instruct-q4_k_m',
        name: 'Qwen 2.5 1.5B Instruct · Q4_K_M',
        url:
            'https://huggingface.co/bartowski/Qwen2.5-1.5B-Instruct-GGUF'
            '/resolve/main/Qwen2.5-1.5B-Instruct-Q4_K_M.gguf',
        estimatedSizeInBytes: 980 * 1024 * 1024,
      ),
      tier: DeviceTier.low,
      minRamGb: 3,
      capabilities: const ModelCapabilities(
        contextWindow: 4096,
        maxOutputTokens: 400,
      ),
      tag: 'Qwen · Small',
      description: 'Strong 1.5B reasoning — good balance for 3 GB phones',
    ),
    CatalogEntry(
      definition: ModelDefinition(
        id: 'gemma-2-2b-it-q4_k_m',
        name: 'Gemma 2 2B IT · Q4_K_M',
        url:
            'https://huggingface.co/bartowski/gemma-2-2b-it-GGUF'
            '/resolve/main/gemma-2-2b-it-Q4_K_M.gguf',
        estimatedSizeInBytes: 1550 * 1024 * 1024,
      ),
      tier: DeviceTier.low,
      minRamGb: 4,
      capabilities: const ModelCapabilities(
        contextWindow: 8192,
        maxOutputTokens: 512,
      ),
      tag: 'Gemma 2 · Balanced',
      description: "Google's efficient 2B — excellent for mid-range devices",
    ),
    CatalogEntry(
      definition: ModelDefinition(
        id: 'qwen2-vl-2b-instruct-q4_k_m',
        name: 'Qwen2 VL 2B Instruct · Q4_K_M',
        url:
            'https://huggingface.co/bartowski/Qwen2-VL-2B-Instruct-GGUF'
            '/resolve/main/Qwen2-VL-2B-Instruct-Q4_K_M.gguf',
        estimatedSizeInBytes: 1680 * 1024 * 1024,
      ),
      tier: DeviceTier.low,
      minRamGb: 4,
      capabilities: const ModelCapabilities(
        supportsVision: true,
        supportsFiles: true,
        supportsVoice: true,
        supportsRAG: true,
        supportsMCP: true,
        contextWindow: 8192,
        maxOutputTokens: 512,
      ),
      tag: 'Qwen2-VL · Vision',
      description:
          'Compact Vision-Language Model — supports image input and text chat',
    ),
    CatalogEntry(
      definition: ModelDefinition(
        id: 'mistral-7b-instruct-v0.2-q4_k_m',
        name: 'Mistral 7B Instruct v0.2 · Q4_K_M',
        url:
            'https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF'
            '/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf',
        estimatedSizeInBytes: 4100 * 1024 * 1024,
      ),
      tier: DeviceTier.mid,
      minRamGb: 8,
      capabilities: const ModelCapabilities(
        contextWindow: 8192,
        maxOutputTokens: 768,
      ),
      tag: 'Mistral · Large',
      description: 'Near-GPT-3.5 quality on flagship phones or desktops',
    ),
  ];
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 7: SESSION MANAGER
// ══════════════════════════════════════════════════════════════════════════════

class SessionManager {
  static const _kTitles = 'ElioraAI_session_titles_v2';
  static const _kLast = 'ElioraAI_last_session';
  static const _kActiveModel = 'ElioraAI_active_model_id';

  final SharedPreferences _prefs;
  final Map<String, String> _titles = {};

  SessionManager._(this._prefs) {
    _loadTitles();
  }

  static Future<SessionManager> create() async {
    final p = await SharedPreferences.getInstance();
    return SessionManager._(p);
  }

  void _loadTitles() {
    final raw = _prefs.getString(_kTitles);
    if (raw == null) return;
    try {
      final m = json.decode(raw) as Map<String, dynamic>;
      for (final e in m.entries) {
        _titles[e.key] = e.value.toString();
      }
    } catch (_) {}
  }

  Future<void> _saveTitles() =>
      _prefs.setString(_kTitles, json.encode(_titles));

  String title(String id) => _titles[id] ?? _fallback(id);

  String _fallback(String id) {
    final m = RegExp(r'^(\d{13})$').firstMatch(id);
    if (m != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(int.parse(m.group(1)!));
      return 'Chat · ${_fmt(dt)}';
    }
    return 'New conversation';
  }

  static String _fmt(DateTime dt) {
    const mo = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${mo[dt.month - 1]} ${dt.day}, $h:$min $ampm';
  }

  Future<void> setTitle(String id, String t) async {
    _titles[id] = t;
    await _saveTitles();
  }

  Future<void> addSession(String id, String placeholder) async {
    if (!_titles.containsKey(id)) {
      _titles[id] = placeholder;
      await _saveTitles();
    }
  }

  Future<void> ensureIds(Iterable<String> ids) async {
    var dirty = false;
    for (final id in ids) {
      if (!_titles.containsKey(id)) {
        _titles[id] = _fallback(id);
        dirty = true;
      }
    }
    if (dirty) await _saveTitles();
  }

  Future<void> remove(String id) async {
    _titles.remove(id);
    await _saveTitles();
  }

  bool isGeneric(String id) {
    final t = _titles[id];
    if (t == null || t.isEmpty) return true;
    if (t.startsWith('New chat') ||
        t.startsWith('Chat ·') ||
        t == 'New conversation') {
      return true;
    }
    return false;
  }

  String get lastSessionId => _prefs.getString(_kLast) ?? 'default';
  Future<void> setLastSession(String id) => _prefs.setString(_kLast, id);

  String? get savedModelId => _prefs.getString(_kActiveModel);
  Future<void> setModelId(String id) => _prefs.setString(_kActiveModel, id);
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 8: DOWNLOAD NOTIFIER
// ══════════════════════════════════════════════════════════════════════════════

@pragma('vm:entry-point')
void _bgNotificationTap(NotificationResponse response) async {
  if (response.actionId == 'cancel_download') {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ElioraAI_cancel_bg', true);
    } catch (e) {
      debugPrint('_bgNotificationTap error: $e');
    }
  }
}

class DownloadNotifier {
  DownloadNotifier._();
  static final instance = DownloadNotifier._();

  static const _notifId = 772001;
  static const _chanId = 'ElioraAI_downloads';
  static const _chanName = 'Model Downloads';

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  String? _name;
  int? _lastPct;
  static VoidCallback? onCancelAction;
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> init() async {
    if (kIsWeb || _ready) return;
    AndroidInitializationSettings? android;
    WindowsInitializationSettings? windows;
    if (defaultTargetPlatform == TargetPlatform.android) {
      android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      windows = const WindowsInitializationSettings(
        appName: 'Eliora AI',
        appUserModelId: 'com.example.ElioraAI',
        guid: 'a4c3d2e1-b0a9-8f7e-6d5c-4b3a2918f0e7',
      );
    }
    await _plugin.initialize(
      settings: InitializationSettings(android: android, windows: windows),
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == 'cancel_download') {
          onCancelAction?.call();
        }
      },
      onDidReceiveBackgroundNotificationResponse: _bgNotificationTap,
    );
    _ready = true;
  }

  Future<void> requestPermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await impl?.requestNotificationsPermission();
  }

  Future<void> start(String modelName) async {
    await init();
    _name = modelName;
    _lastPct = null;
    await _notify('Downloading model', 'Starting $modelName…', null, false);
  }

  Future<void> progress(double frac) async {
    if (_name == null) return;
    final pct = (frac.clamp(0.0, 1.0) * 100).floor();
    final now = DateTime.now();
    if (_lastPct == pct &&
        now.difference(_lastAt) < const Duration(milliseconds: 450)) {
      return;
    }
    _lastPct = pct;
    _lastAt = now;
    await _notify('Downloading ${_name!}', '$pct% complete', frac, false);
  }

  Future<void> done({required bool ok, String? msg}) async {
    if (_name == null) return;
    final n = _name!;
    _name = null;
    _lastPct = null;
    if (ok) {
      await _notify('Model ready ✓', '$n downloaded successfully', 1.0, true);
      await Future<void>.delayed(const Duration(seconds: 3));
    } else {
      await _notify(
        'Download failed',
        msg ?? 'Could not download $n',
        null,
        true,
      );
      await Future<void>.delayed(const Duration(seconds: 5));
    }
    try {
      await _plugin.cancel(id: _notifId);
    } catch (_) {}
  }

  /// Immediately cancel any lingering notification (e.g. on app kill).
  Future<void> cancelIfActive() async {
    _name = null;
    _lastPct = null;
    try {
      if (_ready) {
        final impl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await impl?.stopForegroundService();
        await _plugin.cancel(id: _notifId);
      }
    } catch (_) {}
  }

  Future<void> _notify(
    String title,
    String body,
    double? prog,
    bool fin,
  ) async {
    if (!_ready || kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final det = AndroidNotificationDetails(
      _chanId,
      _chanName,
      channelDescription: 'Eliora AI model download progress',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      playSound: false,
      enableVibration: false,
      ongoing: !fin,
      autoCancel: fin,
      showProgress: prog != null && !fin,
      maxProgress: 100,
      progress: prog != null ? (prog * 100).round() : 0,
      indeterminate: prog == null && !fin,
      actions: null,
    );
    try {
      if (fin) {
        final impl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await impl?.stopForegroundService();
        await _plugin.show(
          id: _notifId,
          title: title,
          body: body,
          notificationDetails: NotificationDetails(android: det),
        );
      } else {
        final impl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await impl?.startForegroundService(
          id: _notifId,
          title: title,
          body: body,
          notificationDetails: det,
        );
      }
    } catch (e) {
      debugPrint('DownloadNotifier._notify: $e');
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 8B: SHARED TTS SINGLETON
// ══════════════════════════════════════════════════════════════════════════════

/// Shared TTS instance — avoids creating per-view FlutterTts objects.
FlutterTts? _sharedTtsInstance;
FlutterTts get sharedTts {
  _sharedTtsInstance ??= FlutterTts()
    ..setLanguage('en-US')
    ..setPitch(1.0)
    ..setSpeechRate(0.5);
  return _sharedTtsInstance!;
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 9: PILL TEXT FIELD
// ══════════════════════════════════════════════════════════════════════════════

class PillTextField extends StatelessWidget {
  const PillTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.rotation,
    required this.enabled,
    required this.hint,
    this.minLines = 1,
    this.maxLines = 6,
    this.onSubmit,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final AnimationController rotation;
  final bool enabled;
  final String hint;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onSubmit;
  final ValueChanged<String>? onChanged;

  static const _outerR = 26.0;
  static const _ring = 2.5;
  static double get _innerR => _outerR - _ring;

  Widget _field(ColorScheme cs) => TextField(
    controller: controller,
    focusNode: focusNode,
    enabled: enabled,
    minLines: minLines,
    maxLines: maxLines,
    textAlignVertical: TextAlignVertical.center,
    style: TextStyle(
      color: cs.onSurface,
      fontFamily: GoogleFonts.nunito().fontFamily,
    ),
    cursorColor: cs.primary,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: enabled ? hint : 'Please wait…',
      isDense: true,
      filled: true,
      fillColor: cs.surface,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    ),
    textInputAction: TextInputAction.send,
    onSubmitted: onSubmit,
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ring = ElioraColors.ringForBrightness(Theme.of(context).brightness);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 120),
      child: AnimatedBuilder(
        animation: focusNode,
        builder: (_, _) {
          final focused = focusNode.hasFocus && enabled;
          if (!focused) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(_outerR),
                border: Border.all(
                  color: cs.outlineVariant.withAlpha(100),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_outerR - 1),
                child: Material(color: cs.surface, child: _field(cs)),
              ),
            );
          }
          return AnimatedBuilder(
            animation: rotation,
            builder: (_, _) {
              final t = rotation.value * 2 * math.pi;
              return Container(
                padding: const EdgeInsets.all(_ring),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_outerR),
                  gradient: SweepGradient(
                    colors: [...ring, ring.first],
                    stops: List.generate(
                      ring.length + 1,
                      (i) => i / ring.length,
                    ),
                    transform: GradientRotation(t),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_innerR),
                  child: Material(color: cs.surface, child: _field(cs)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 10: INTENT
// ══════════════════════════════════════════════════════════════════════════════

class _SendIntent extends Intent {
  const _SendIntent();
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 11: CODE BLOCK BUILDER
// ══════════════════════════════════════════════════════════════════════════════

class CodeBlockBuilder extends MarkdownElementBuilder {
  CodeBlockBuilder(this.ctx);
  final BuildContext ctx;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = element.textContent;
    final isBlock =
        element.tag == 'pre' || (element.tag == 'code' && text.contains('\n'));
    if (!isBlock) return null;
    final th = Theme.of(ctx);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: th.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: th.colorScheme.onSurface.withAlpha(13),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'code',
                  style: th.textTheme.labelSmall?.copyWith(
                    color: th.colorScheme.onSurfaceVariant,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Copied'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          size: 13,
                          color: th.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 11,
                            color: th.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              text,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 12: CITATION WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _CitationChip extends StatelessWidget {
  const _CitationChip({required this.label, required this.accent});
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withAlpha(40)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _CitationsBody extends StatelessWidget {
  const _CitationsBody({
    required this.chips,
    required this.accent,
    required this.th,
  });
  final List<Widget> chips;
  final Color accent;
  final ThemeData th;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: th.colorScheme.outlineVariant.withAlpha(50)),
          Row(
            children: [
              Icon(Icons.auto_stories_rounded, size: 13, color: accent),
              const SizedBox(width: 6),
              Text(
                'Sources',
                style: th.textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: chips),
        ],
      ),
    );
  }
}

class _LiveCitations extends StatelessWidget {
  const _LiveCitations({required this.citations, required this.accent});
  final List<RetrievalResult> citations;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (citations.isEmpty) return const SizedBox.shrink();
    final th = Theme.of(context);
    return _CitationsBody(
      accent: accent,
      th: th,
      chips: citations.map((c) {
        final j = c.toJson();
        final src = j['source'];
        final title = src is Map
            ? (src['title'] ?? 'Source').toString()
            : 'Source';
        return _CitationChip(label: title, accent: accent);
      }).toList(),
    );
  }
}

class _JsonCitations extends StatelessWidget {
  const _JsonCitations({required this.data, required this.accent});
  final dynamic data;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (data is! List || (data as List).isEmpty) return const SizedBox.shrink();
    final th = Theme.of(context);
    return _CitationsBody(
      accent: accent,
      th: th,
      chips: (data as List).map((c) {
        final src = c is Map ? c['source'] : null;
        final title = src is Map
            ? (src['title'] ?? 'Source').toString()
            : 'Source';
        return _CitationChip(label: title, accent: accent);
      }).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 13: CHAT BUBBLE
// ══════════════════════════════════════════════════════════════════════════════

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isStreaming,
    required this.streamingContent,
    required this.streamingCitations,
    required this.accentColor,
    required this.onSpeak,
    required this.onStopSpeaking,
    required this.onCopy,
    required this.speakingMessageId,
  });

  final AgentChatMessage message;
  final bool isStreaming;
  final ValueNotifier<String> streamingContent;
  final ValueNotifier<List<RetrievalResult>> streamingCitations;
  final Color accentColor;
  final VoidCallback onSpeak;
  final VoidCallback onStopSpeaking;
  final VoidCallback onCopy;
  final ValueNotifier<String?> speakingMessageId;

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final dark = th.brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;

    final bubbleBg = _isUser
        ? (dark ? DarkTokens.userBubble : LightTokens.primaryContainer)
        : (dark
              ? DarkTokens.surfaceContainerHigh
              : LightTokens.surfaceContainerHigh);

    final textColor = _isUser
        ? (dark
              ? DarkTokens.onPrimaryContainer
              : LightTokens.onPrimaryContainer)
        : th.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: _isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isUser) ...[
            _Avatar(
              icon: Icons.auto_awesome_rounded,
              bg: accentColor.withAlpha(40),
              fg: accentColor,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: width * (width > 700 ? 0.6 : 0.82),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: bubbleBg,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(_isUser ? 18 : 4),
                    bottomRight: Radius.circular(_isUser ? 4 : 18),
                  ),
                  border: Border.all(
                    color: _isUser
                        ? accentColor.withAlpha(60)
                        : th.colorScheme.outlineVariant.withAlpha(80),
                    width: 0.8,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.imageBytes != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            Uint8List.fromList(message.imageBytes!),
                            fit: BoxFit.cover,
                            height: 180,
                          ),
                        ),
                      ),
                    if (isStreaming)
                      ValueListenableBuilder<String>(
                        valueListenable: streamingContent,
                        builder: (_, content, _) => _Markdown(
                          data: content.isEmpty ? '●' : content,
                          textColor: textColor,
                          accentColor: accentColor,
                          th: th,
                        ),
                      )
                    else
                      _Markdown(
                        data: message.content,
                        textColor: textColor,
                        accentColor: accentColor,
                        th: th,
                      ),
                    if (isStreaming)
                      ValueListenableBuilder<List<RetrievalResult>>(
                        valueListenable: streamingCitations,
                        builder: (_, cits, _) => _LiveCitations(
                          citations: cits,
                          accent: accentColor,
                        ),
                      )
                    else if (message.metadata?['citations'] != null)
                      _JsonCitations(
                        data: message.metadata!['citations'],
                        accent: accentColor,
                      ),
                    if (!_isUser && !isStreaming) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MiniBtn(
                            icon: Icons.copy_rounded,
                            label: 'Copy',
                            onTap: onCopy,
                          ),
                          const SizedBox(width: 4),
                          ValueListenableBuilder<String?>(
                            valueListenable: speakingMessageId,
                            builder: (_, speakingId, _) {
                              final isSpeaking = speakingId == message.id;
                              return _MiniBtn(
                                icon: isSpeaking
                                    ? Icons.stop_rounded
                                    : Icons.volume_up_rounded,
                                label: isSpeaking ? 'Stop' : 'Speak',
                                onTap: isSpeaking ? onStopSpeaking : onSpeak,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_isUser) ...[
            const SizedBox(width: 8),
            _Avatar(
              icon: Icons.person_rounded,
              bg: th.colorScheme.secondaryContainer,
              fg: th.colorScheme.onSecondaryContainer,
            ),
          ],
        ],
      ),
    );
  }
}

class _Markdown extends StatelessWidget {
  const _Markdown({
    required this.data,
    required this.textColor,
    required this.accentColor,
    required this.th,
  });
  final String data;
  final Color textColor, accentColor;
  final ThemeData th;

  @override
  Widget build(BuildContext context) {
    final sheet = MarkdownStyleSheet.fromTheme(th).copyWith(
      p: th.textTheme.bodyMedium?.copyWith(color: textColor, height: 1.5),
      code: th.textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: Colors.transparent,
      ),
      codeblockDecoration: BoxDecoration(
        color: th.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      blockquoteDecoration: BoxDecoration(
        color: th.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: accentColor, width: 3)),
      ),
    );
    return Builder(
      builder: (ctx) => MarkdownBody(
        data: data,
        selectable: true,
        styleSheet: sheet,
        builders: {'code': CodeBlockBuilder(ctx)},
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.icon, required this.bg, required this.fg});
  final IconData icon;
  final Color bg, fg;
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 15,
    backgroundColor: bg,
    child: Icon(icon, size: 17, color: fg),
  );
}

class _MiniBtn extends StatelessWidget {
  const _MiniBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: cs.onSurfaceVariant.withAlpha(180)),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurfaceVariant.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 14: WELCOME / PRE-MODEL VIEW
// ══════════════════════════════════════════════════════════════════════════════

class WelcomeView extends StatefulWidget {
  const WelcomeView({
    super.key,
    required this.onAttempt,
    this.loading = false,
    this.loadingText,
    this.downloadBusy = false,
    this.downloadProgress = 0,
    this.downloadStatusText,
  });

  final ValueChanged<String> onAttempt;
  final bool loading;
  final String? loadingText;
  final bool downloadBusy;
  final double downloadProgress;
  final String? downloadStatusText;

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  late AnimationController _ring;

  static const _suggestions = [
    '✨ Who are you?',
    '📱 What runs on-device?',
    '🔍 Summarize a short note',
    '💡 Explain on-device AI',
    '🖼 What can you see?',
    '🔌 What is MCP?',
  ];

  @override
  void initState() {
    super.initState();
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _focus.addListener(() {
      if (_focus.hasFocus) {
        _ring.repeat();
      } else {
        _ring.stop();
        _ring.reset();
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ring.dispose();
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  bool get _busy => widget.loading || widget.downloadBusy;

  void _submit([String? override]) {
    final t = (override ?? _ctrl.text).trim();
    if (t.isEmpty || _busy) return;
    _ctrl.clear();
    widget.onAttempt(t);
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final cs = th.colorScheme;
    return Column(
      children: [
        if (_busy)
          _StatusBanner(
            text: widget.loading
                ? (widget.loadingText ?? 'Checking for models…')
                : (widget.downloadStatusText ?? 'Downloading model…'),
            progress: widget.downloadBusy ? widget.downloadProgress : null,
            cs: cs,
          ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHero(th, cs)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final raw = _suggestions[i];
                    // Strip leading emoji + spaces for the actual query
                    final query = raw
                        .replaceFirst(
                          RegExp(
                            r'^[\S\u{1F000}-\u{1FFFF}]+\s*',
                            unicode: true,
                          ),
                          '',
                        )
                        .trim();
                    return _SuggestionCard(
                      text: raw,
                      enabled: !_busy,
                      onTap: () => _submit(query.isEmpty ? raw : query),
                    );
                  }, childCount: _suggestions.length),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: 60,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildComposer(cs),
      ],
    );
  }

  Widget _buildHero(ThemeData th, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DarkTokens.gradientEnd.withAlpha(80),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/Eliora Ai assits-2/Eliora Ai assits/playstore-icon.png',
                fit: BoxFit.cover,
                errorBuilder: (_, e, s) => Icon(
                  Icons.auto_awesome_rounded,
                  size: 40,
                  color: DarkTokens.gradientEnd,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const GradientTitle(
            text: 'Eliora AI',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Local agent studio · 100% on-device',
            style: th.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _FeaturePill(icon: Icons.visibility_rounded, label: 'Vision'),
              _FeaturePill(icon: Icons.auto_stories_rounded, label: 'RAG'),
              _FeaturePill(icon: Icons.power_rounded, label: 'MCP Tools'),
              _FeaturePill(icon: Icons.lock_rounded, label: '100% Private'),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Tap a suggestion below or type your own message.\nYou\'ll need to install a model first.',
            style: th.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildComposer(ColorScheme cs) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: PillTextField(
              controller: _ctrl,
              focusNode: _focus,
              rotation: _ring,
              enabled: !_busy,
              hint: _busy ? 'Please wait…' : 'Ask something…',
              onSubmit: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          _SendButton(onTap: _submit, enabled: !_busy),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.text, required this.cs, this.progress});
  final String text;
  final ColorScheme cs;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          if (progress != null && progress! > 0) ...[
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.text,
    required this.onTap,
    required this.enabled,
  });
  final String text;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: enabled ? cs.onSurface : cs.onSurface.withAlpha(100),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: cs.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap, required this.enabled});
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: enabled ? cs.primary : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(22),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.redAccent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.stop_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 15: FULL CHAT VIEW
// ══════════════════════════════════════════════════════════════════════════════

class AgentChatView extends StatefulWidget {
  const AgentChatView({
    super.key,
    required this.kit,
    required this.capabilities,
    required this.sessionId,
    required this.initialHistory,
    required this.onHistoryChanged,
    required this.accentColor,
    required this.activeModelId,
    required this.activeModelName,
    this.initialPrompt,
  });

  final FlutterLocalAgentKit kit;
  final ModelCapabilities capabilities;
  final String sessionId;
  final List<AgentChatMessage> initialHistory;
  final void Function(List<AgentChatMessage>) onHistoryChanged;
  final Color accentColor;
  final String activeModelId;
  final String activeModelName;
  final String? initialPrompt;

  @override
  State<AgentChatView> createState() => _AgentChatViewState();
}

class _AgentChatViewState extends State<AgentChatView>
    with TickerProviderStateMixin {
  late List<AgentChatMessage> _msgs;
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  late AnimationController _ring;
  final _processing = ValueNotifier(false);
  final _streaming = ValueNotifier('');
  final _citations = ValueNotifier<List<RetrievalResult>>([]);
  final _scrollPos = ValueNotifier(0.0);
  final _listening = ValueNotifier(false);
  final _speakingId = ValueNotifier<String?>(null);
  String? _activeId;
  StreamSubscription<String>? _generationSub;
  bool _useContext = true;
  Uint8List? _pendingImage;
  final _picker = ImagePicker();
  final _voice = VoiceService();
  bool _voiceInitialized = false;

  // ── Derived from model id ──────────────────────────────────────────────
  late final String _systemPrompt;
  late final int _maxTokens;

  @override
  void initState() {
    super.initState();
    _msgs = List.from(widget.initialHistory);
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _focus.addListener(_onFocusChange);
    _scroll.addListener(_onScroll);
    _initVoice();

    // Set up TTS completion handlers on shared instance
    sharedTts.setCompletionHandler(() {
      _speakingId.value = null;
    });
    sharedTts.setCancelHandler(() {
      _speakingId.value = null;
    });

    // Derive system prompt and generation params from model identity
    _systemPrompt = SystemPromptEngine.forModel(
      widget.activeModelId,
      widget.activeModelName,
    );
    _maxTokens = SystemPromptEngine.maxTokensFor(widget.activeModelId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animate: false);
      // Auto-send initial prompt if provided
      if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
        _ctrl.text = widget.initialPrompt!;
        _send();
      }
    });
  }

  void _onFocusChange() {
    if (_focus.hasFocus) {
      _ring.repeat();
    } else {
      _ring.stop();
      _ring.reset();
    }
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (_scroll.hasClients && _scroll.position.hasContentDimensions) {
      _scrollPos.value = _scroll.offset;
    }
  }

  Future<void> _initVoice() async {
    try {
      await _voice.initialize();
      _voiceInitialized = true;
    } catch (_) {}
  }

  @override
  void didUpdateWidget(AgentChatView old) {
    super.didUpdateWidget(old);
    if (old.sessionId != widget.sessionId) {
      _msgs = List.from(widget.initialHistory);
      _streaming.value = '';
      _activeId = null;
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToBottom(animate: false),
      );
    }
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients || !_scroll.position.hasContentDimensions) return;
      final target = _scroll.position.maxScrollExtent;
      if (animate) {
        _scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      } else {
        _scroll.jumpTo(target);
      }
    });
  }

  Future<void> _pickCamera() async {
    try {
      final f = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (f == null) return;
      final b = await f.readAsBytes();
      if (mounted) setState(() => _pendingImage = b);
    } catch (e) {
      _snack('Camera error: $e');
    }
  }

  Future<void> _pickGallery() async {
    try {
      final f = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (f == null) return;
      final b = await f.readAsBytes();
      if (mounted) setState(() => _pendingImage = b);
    } catch (e) {
      _snack('Gallery error: $e');
    }
  }

  Future<void> _attachFile() async {
    try {
      final r = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'json', 'csv'],
        withData: true,
      );
      if (r == null || r.files.isEmpty) return;
      final f = r.files.single;
      final text = f.bytes != null
          ? utf8.decode(f.bytes!, allowMalformed: true)
          : null;
      if (text == null || text.isEmpty) return;
      if (!mounted) return;
      final end = text.length.clamp(0, 4000);
      final wasTruncated = text.length > 4000;
      setState(() {
        final pre = _ctrl.text.trim().isEmpty ? '' : '${_ctrl.text}\n\n';
        _ctrl.text = '$pre--- ${f.name} ---\n${text.substring(0, end)}';
      });
      if (wasTruncated) {
        _snack('File truncated to ~4000 chars for model compatibility');
      }
    } catch (e) {
      _snack('File error: $e');
    }
  }

  Future<void> _toggleVoice() async {
    try {
      await _voice.listen(
        onResult: (t) {
          if (mounted) _ctrl.text = t;
        },
        onListeningChange: (v) {
          _listening.value = v;
        },
      );
    } catch (e) {
      _snack('Voice error: $e');
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    final img = _pendingImage;
    if ((text.isEmpty && img == null) || _processing.value) return;

    final userMsg = AgentChatMessage(
      id: const Uuid().v4(),
      content: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      imageBytes: img,
    );
    final assistId = const Uuid().v4();
    final assistMsg = AgentChatMessage.assistant('', id: assistId);

    setState(() {
      _msgs.add(userMsg);
      _msgs.add(assistMsg);
      _ctrl.clear();
      _pendingImage = null;
      _processing.value = true;
      _streaming.value = '';
      _citations.value = [];
      _activeId = assistId;
    });
    _scrollToBottom();

    // Prior turns without placeholder and current message; system instructions are injected separately
    var priorTurns = _useContext
        ? _msgs
              .where(
                (m) =>
                    m.id != assistId &&
                    m.id != userMsg.id &&
                    m.role != MessageRole.system,
              )
              .toList()
        : <AgentChatMessage>[];

    // Prune history to fit within context window (~4 chars per token)
    if (priorTurns.isNotEmpty) {
      final maxChars = widget.capabilities.contextWindow * 4;
      var totalChars = text.length + _systemPrompt.length;
      final pruned = <AgentChatMessage>[];
      for (final m in priorTurns.reversed) {
        totalChars += m.content.length;
        if (totalChars > maxChars) break;
        pruned.insert(0, m);
      }
      priorTurns = pruned;
    }

    final historyForKit = <AgentChatMessage>[
      if (_systemPrompt.isNotEmpty) AgentChatMessage.system(_systemPrompt),
      ...priorTurns,
    ];

    try {
      final completer = Completer<void>();
      _generationSub = widget.kit
          .askStream(
            text,
            history: historyForKit,
            imageBytes: img,
            onCitations: (c) {
              _citations.value = c;
            },
            maxTokens: _maxTokens,
          )
          .listen(
            (token) {
              _streaming.value += token;
              // Safety guard: if tiny model starts generating HTML/XML, truncate
              if (_isMalformedOutput(_streaming.value)) {
                debugPrint(
                  'Detected malformed output — stopping generation early',
                );
                _generationSub?.cancel();
                if (!completer.isCompleted) completer.complete();
              }
              _scrollToBottom();
            },
            onError: (e) {
              if (!completer.isCompleted) completer.completeError(e);
            },
            onDone: () {
              if (!completer.isCompleted) completer.complete();
            },
            cancelOnError: true,
          );

      await completer.future;

      final finalText = _sanitizeOutput(_streaming.value);
      final finalCits = List<RetrievalResult>.from(_citations.value);
      final idx = _msgs.indexWhere((m) => m.id == assistId);
      if (idx != -1) {
        setState(() {
          _msgs[idx] = AgentChatMessage.assistant(
            finalText,
            id: assistId,
            metadata: finalCits.isNotEmpty
                ? {'citations': finalCits.map((c) => c.toJson()).toList()}
                : null,
          );
          _streaming.value = '';
          _activeId = null;
        });
      }
      widget.onHistoryChanged(List.from(_msgs));
    } catch (e) {
      final idx = _msgs.indexWhere((m) => m.id == assistId);
      if (idx != -1 && mounted) {
        setState(() {
          _msgs[idx] = AgentChatMessage.assistant('⚠️ Error: $e', id: assistId);
          _streaming.value = '';
          _activeId = null;
        });
      }
      _snack('Generation error: $e');
    } finally {
      if (mounted) {
        _processing.value = false;
        _activeId = null;
      }
    }
  }

  /// Detect if a tiny model has started hallucinating web content.
  bool _isMalformedOutput(String text) {
    if (text.length < 40) return false; // too short to judge
    final lower = text.toLowerCase();
    // HTML document patterns — clear sign of hallucination
    if (lower.contains('<!doctype') ||
        lower.contains('<html') ||
        lower.contains('<?xml') ||
        lower.contains('xmlns') ||
        lower.contains('www.w3.org/tr/') ||
        lower.contains('<title>document') ||
        lower.contains('xhtml')) {
      return true;
    }
    return false;
  }

  /// Clean up any stray HTML tags from tiny model outputs.
  String _sanitizeOutput(String text) {
    if (text.trim().isEmpty) {
      return "I'm sorry, I couldn't generate a response. Please try again with a simpler question.";
    }
    // If hallucinated HTML, replace with a helpful message
    if (_isMalformedOutput(text)) {
      return "I'm a tiny model and had trouble with that request. Please try a simpler or shorter question.";
    }
    // Strip obvious stray HTML tags (< ... >) but keep code blocks intact
    final stripped = text.replaceAllMapped(
      RegExp(r'<(?!code|/code|pre|/pre|b|/b|i|/i|br)[^>]{0,80}>'),
      (m) => '',
    );
    return stripped.trim();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final cs = th.colorScheme;
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.enter):
            const _SendIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.enter):
            const _SendIntent(),
      },
      child: Actions(
        actions: {
          _SendIntent: CallbackAction<_SendIntent>(onInvoke: (_) => _send()),
        },
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scroll,
                    cacheExtent: 600,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    itemCount: _msgs.length,
                    itemBuilder: (ctx, i) {
                      final m = _msgs[i];
                      return ChatBubble(
                        message: m,
                        isStreaming: m.id == _activeId,
                        streamingContent: _streaming,
                        streamingCitations: _citations,
                        accentColor: widget.accentColor,
                        speakingMessageId: _speakingId,
                        onSpeak: () {
                          // Stop any currently playing TTS first
                          if (_speakingId.value != null) {
                            sharedTts.stop();
                          }
                          _speakingId.value = m.id;
                          sharedTts.speak(m.content);
                        },
                        onStopSpeaking: () {
                          sharedTts.stop();
                          _speakingId.value = null;
                        },
                        onCopy: () {
                          Clipboard.setData(ClipboardData(text: m.content));
                          _snack('Copied');
                        },
                      );
                    },
                  ),
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _scrollPos,
                      builder: (_, pos, _) {
                        if (!_scroll.hasClients ||
                            !_scroll.position.hasContentDimensions) {
                          return const SizedBox.shrink();
                        }
                        if (_scroll.position.maxScrollExtent - pos <= 300) {
                          return const SizedBox.shrink();
                        }
                        return FloatingActionButton.small(
                          heroTag: 'scroll_${widget.sessionId}',
                          backgroundColor: widget.accentColor.withAlpha(230),
                          onPressed: () => _scrollToBottom(),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _processing,
              builder: (_, proc, _) {
                if (!proc) return const SizedBox.shrink();
                return LinearProgressIndicator(
                  minHeight: 2,
                  color: widget.accentColor,
                  backgroundColor: cs.surfaceContainerHighest,
                );
              },
            ),
            if (_pendingImage != null)
              _ImagePreview(
                bytes: _pendingImage!,
                onRemove: () => setState(() => _pendingImage = null),
              ),
            _buildComposer(cs),
          ],
        ),
      ),
    );
  }

  void _showAttachmentSheet() {
    final cs = Theme.of(context).colorScheme;
    final caps = widget.capabilities;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.paddingOf(ctx).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Attach',
                style: Theme.of(
                  ctx,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AttachOption(
                    icon: Icons.insert_drive_file_rounded,
                    label: 'Document',
                    color: cs.primary,
                    enabled: caps.supportsFiles,
                    onTap: () {
                      Navigator.pop(ctx);
                      _attachFile();
                    },
                  ),
                  _AttachOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: cs.secondary,
                    enabled: caps.supportsVision,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickGallery();
                    },
                  ),
                  _AttachOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: cs.tertiary,
                    enabled: caps.supportsVision,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickCamera();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContextToggle() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 12.0, right: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Use old chat context',
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text(
                    'Context Usage',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  content: const Text(
                    'Using previous chat messages helps the AI understand the ongoing conversation, '
                    'but loading a long chat history may slow down the response rate on some devices.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
            child: Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 24,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch(
                value: _useContext,
                onChanged: (val) => setState(() => _useContext = val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(ColorScheme cs) {
    return Container(
      padding: EdgeInsets.only(
        left: 6,
        right: 6,
        top: 8,
        bottom: MediaQuery.paddingOf(context).bottom + 8,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.initialHistory.isNotEmpty || _msgs.isNotEmpty)
            _buildContextToggle(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _showAttachmentSheet,
                icon: const Icon(Icons.add_rounded, size: 24),
                visualDensity: VisualDensity.compact,
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _listening,
                builder: (_, lst, _) => IconButton(
                  onPressed: widget.capabilities.supportsVoice
                      ? _toggleVoice
                      : null,
                  icon: Icon(
                    lst ? Icons.mic_rounded : Icons.mic_none_rounded,
                    size: 22,
                    color: lst ? Colors.redAccent : null,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: PillTextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  rotation: _ring,
                  enabled: true,
                  hint: 'Message…',
                  maxLines: 4,
                  onSubmit: (_) => _send(),
                ),
              ),
              const SizedBox(width: 6),
              ValueListenableBuilder<bool>(
                valueListenable: _processing,
                builder: (_, proc, _) {
                  if (proc) {
                    return _StopButton(
                      onTap: () {
                        _generationSub?.cancel();
                        final finalText = _sanitizeOutput(_streaming.value);
                        if (_activeId != null) {
                          final idx = _msgs.indexWhere((m) => m.id == _activeId);
                          if (idx != -1) {
                            setState(() {
                              _msgs[idx] = AgentChatMessage.assistant(
                                finalText.isEmpty
                                    ? '⏹ Generation stopped'
                                    : finalText,
                                id: _activeId!,
                              );
                              _streaming.value = '';
                              _activeId = null;
                            });
                          }
                        }
                        _processing.value = false;
                        widget.onHistoryChanged(List.from(_msgs));
                      },
                    );
                  }
                  return _SendButton(onTap: _send, enabled: true);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _generationSub?.cancel();
    _ring.dispose();
    _focus.dispose();
    _ctrl.dispose();
    _scroll.dispose();
    _processing.dispose();
    _streaming.dispose();
    _citations.dispose();
    _scrollPos.dispose();
    _listening.dispose();
    _speakingId.dispose();
    sharedTts.stop();
    try { if (_voiceInitialized) _voice.dispose(); } catch (_) {}
    super.dispose();
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.bytes, required this.onRemove});
  final Uint8List bytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 90,
      color: cs.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  bytes,
                  height: 78,
                  width: 78,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: onRemove,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: cs.error,
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Text(
            'Image attached',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 15B: ATTACHMENT OPTION
// ══════════════════════════════════════════════════════════════════════════════

class _AttachOption extends StatelessWidget {
  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final opacity = enabled ? 1.0 : 0.35;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(30),
                border: Border.all(color: color.withAlpha(80)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 16: INSTALL INTRO SHEET
// ══════════════════════════════════════════════════════════════════════════════

Future<void> showInstallSheet({
  required BuildContext context,
  required VoidCallback onExplore,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.paddingOf(ctx).bottom + 24,
          top: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        DarkTokens.gradientStart,
                        DarkTokens.gradientEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Install an on-device model',
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Eliora AI · Local Agent Studio',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _FeatureRow(
              icon: Icons.privacy_tip_rounded,
              color: DarkTokens.success,
              title: '100% Private',
              subtitle: 'Everything runs on your device. No server, no cloud.',
            ),
            const SizedBox(height: 10),
            const _FeatureRow(
              icon: Icons.auto_stories_rounded,
              color: DarkTokens.gradientStart,
              title: 'RAG with Citations',
              subtitle: 'Ingest your own PDFs and get cited answers.',
            ),
            const SizedBox(height: 10),
            const _FeatureRow(
              icon: Icons.visibility_rounded,
              color: Color(0xFFFF8A65),
              title: 'Multimodal Vision',
              subtitle: 'Vision models can describe images and camera feed.',
            ),
            const SizedBox(height: 10),
            _FeatureRow(
              icon: Icons.power_rounded,
              color: cs.secondary,
              title: 'MCP Tool Calls',
              subtitle: 'Connect to external tools via Model Context Protocol.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                onExplore();
              },
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Browse & install models'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Maybe later'),
            ),
          ],
        ),
      );
    },
  );
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 17: MODEL EXPLORER PAGE
// ══════════════════════════════════════════════════════════════════════════════

class ModelExplorerPage extends StatefulWidget {
  const ModelExplorerPage({
    super.key,
    required this.deviceRamGb,
    required this.onPick,
    required this.modelManager,
    this.showTutorial = false,
  });
  final double? deviceRamGb;
  final ValueChanged<CatalogEntry> onPick;
  final ModelManager modelManager;
  final bool showTutorial;

  @override
  State<ModelExplorerPage> createState() => _ModelExplorerPageState();
}

class _ModelExplorerPageState extends State<ModelExplorerPage> {
  final Set<String> _downloadedIds = {};
  final _keyFirstCard = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkDownloaded();
  }

  Future<void> _checkDownloaded() async {
    final entries = ElioraCatalog.all;
    final results = await Future.wait(
      entries.map((e) async {
        try {
          return await widget.modelManager.isModelDownloaded(e.definition.id)
              ? e.definition.id
              : null;
        } catch (_) {
          return null;
        }
      }),
    );
    if (!mounted) return;
    setState(() {
      for (final id in results) {
        if (id != null) _downloadedIds.add(id);
      }
    });
    // Show tutorial after cards are built
    if (widget.showTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showExplorerTutorial();
      });
    }
  }

  Future<void> _confirmDelete(CatalogEntry entry) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (d) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.delete_forever_rounded, color: cs.error),
                const SizedBox(width: 10),
                const Expanded(child: Text('Delete model?')),
              ],
            ),
            content: Text(
              'Are you sure you want to delete "${entry.definition.name}"?\n\nYou can re-download it later if needed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(d, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(d, true),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    try {
      await widget.modelManager.deleteModel(entry.definition.id);
      if (mounted) {
        setState(() => _downloadedIds.remove(entry.definition.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${entry.definition.name} deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  void _showModelDetails(BuildContext context, CatalogEntry entry) {
    final th = Theme.of(context);
    final cs = th.colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(ctx).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.definition.name,
                      style: th.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  _TagBadge(label: entry.tag, color: entry.tier.color),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entry.description,
                style: th.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Technical Details',
                style: th.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                Icons.storage_rounded,
                'Download Size',
                entry.sizeLabel,
              ),
              _buildDetailRow(
                context,
                Icons.memory_rounded,
                'Minimum RAM Needed',
                '${entry.minRamGb} GB RAM',
              ),
              _buildDetailRow(
                context,
                Icons.chat_bubble_outline_rounded,
                'Context Window',
                '${entry.capabilities.contextWindow} tokens',
              ),
              _buildDetailRow(
                context,
                Icons.output_rounded,
                'Max Output Tokens',
                '${entry.capabilities.maxOutputTokens} tokens',
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Model Capabilities',
                style: th.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCapabilityBadge(context, true, 'Text Chat'),
                  _buildCapabilityBadge(
                    context,
                    entry.capabilities.supportsVision,
                    'Vision (Images)',
                  ),
                  _buildCapabilityBadge(
                    context,
                    entry.capabilities.supportsRAG,
                    'RAG (Files/Knowledge)',
                  ),
                  _buildCapabilityBadge(
                    context,
                    entry.capabilities.supportsMCP,
                    'MCP Tools',
                  ),
                  _buildCapabilityBadge(
                    context,
                    entry.capabilities.supportsVoice,
                    'Voice Output',
                  ),
                  _buildCapabilityBadge(
                    context,
                    entry.capabilities.supportsFiles,
                    'File Analysis',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final cs = Theme.of(context).colorScheme;
    final th = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: th.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: th.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityBadge(
    BuildContext context,
    bool supported,
    String label,
  ) {
    final th = Theme.of(context);
    final cs = th.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: supported
            ? DarkTokens.success.withAlpha(20)
            : cs.error.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: supported
              ? DarkTokens.success.withAlpha(60)
              : cs.error.withAlpha(60),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            supported ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: supported ? DarkTokens.success : cs.error,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: th.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: supported ? DarkTokens.success : cs.error,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final cs = th.colorScheme;

    final downloaded = <CatalogEntry>[];
    final groups = <DeviceTier, List<CatalogEntry>>{};
    for (final t in DeviceTier.values) {
      groups[t] = [];
    }
    for (final e in ElioraCatalog.all) {
      if (_downloadedIds.contains(e.definition.id)) {
        downloaded.add(e);
      } else {
        groups[e.tier]!.add(e);
      }
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose a Model',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            if (widget.deviceRamGb != null)
              Text(
                'Device RAM: ${widget.deviceRamGb!.toStringAsFixed(1)} GB',
                style: th.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 40),
        children: [
          _InfoCard(deviceRamGb: widget.deviceRamGb, cs: cs, th: th),
          const SizedBox(height: 16),

          // Downloaded Models Heading (Always visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.download_done_rounded,
                  color: cs.primary.withAlpha(180),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'DOWNLOADED MODELS',
                  style: th.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary.withAlpha(180),
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // Downloaded list or empty state
          if (downloaded.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh.withAlpha(100),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.outlineVariant.withAlpha(60),
                  width: 0.8,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_download_outlined,
                    size: 32,
                    color: cs.onSurfaceVariant.withAlpha(100),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No model is downloaded',
                    style: th.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant.withAlpha(180),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose a model below to install it offline',
                    style: th.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant.withAlpha(120),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            ...downloaded.map((e) {
              return _ModelCard(
                entry: e,
                deviceRamGb: widget.deviceRamGb,
                isDownloaded: true,
                onTap: () => widget.onPick(e),
                onDelete: () => _confirmDelete(e),
                onInfo: () => _showModelDetails(context, e),
              );
            }),
            const SizedBox(height: 12),
          ],

          const Divider(),
          const SizedBox(height: 8),

          // Available Tiers (available to download header removed)
          for (final tier in DeviceTier.values)
            if ((groups[tier] ?? []).isNotEmpty) ...[
              _TierHeader(tier: tier),
              ...groups[tier]!.asMap().entries.map((mapEntry) {
                final idx = mapEntry.key;
                final e = mapEntry.value;
                // Give the first available (not-downloaded) card the tutorial key
                final isFirstAvailable =
                    downloaded.isEmpty && idx == 0 && tier == groups.keys.firstWhere((t) => (groups[t] ?? []).isNotEmpty, orElse: () => tier);
                return _ModelCard(
                  entry: e,
                  deviceRamGb: widget.deviceRamGb,
                  isDownloaded: false,
                  onTap: () => widget.onPick(e),
                  onDelete: () => _confirmDelete(e),
                  onInfo: () => _showModelDetails(context, e),
                  downloadIconKey: isFirstAvailable ? _keyFirstCard : null,
                );
              }),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  void _showExplorerTutorial() {
    if (_keyFirstCard.currentContext == null) return;
    final cs = Theme.of(context).colorScheme;

    Widget card(String title, String body, IconData icon, Color color) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(title,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  )),
            ]),
            const SizedBox(height: 8),
            Text(body,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12.5,
                  height: 1.4,
                )),
          ],
        ),
      );
    }

    TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'firstModelCard',
          keyTarget: _keyFirstCard,
          shape: ShapeLightFocus.Circle,
          paddingFocus: 6,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (ctx, ctrl) => card(
                'Download a Model',
                'Tap the download icon on any model card to install it. '
                'Once downloaded, you can start chatting offline!',
                Icons.download_rounded,
                cs.primary,
              ),
            ),
          ],
        ),
      ],
      colorShadow: Colors.black,
      opacityShadow: 0.82,
      hideSkip: true,
      paddingFocus: 4,
      onFinish: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('ElioraAI_tutorialDone', true);
      },
      onSkip: () {
        SharedPreferences.getInstance().then((p) {
          p.setBool('ElioraAI_tutorialDone', true);
        });
        return true;
      },
    ).show(context: context);
  }
}

class _InfoCard extends StatefulWidget {
  const _InfoCard({required this.deviceRamGb, this.cs, this.th});
  final double? deviceRamGb;
  final ColorScheme? cs;
  final ThemeData? th;

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Slowly moving, polished
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final cs = th.colorScheme;

    // Vibrant electric cyan, royal blue, and magenta/purple gradient
    const color1 = Color(0xFF00F2FE); // Vibrant Electric Cyan
    const color2 = Color(0xFF4FACFE); // Electric Blue
    const color3 = Color(0xFF9B51E0); // Electric Purple

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * math.pi;
        final begin = Alignment(math.cos(angle), math.sin(angle));
        final end = Alignment(
          math.cos(angle + math.pi),
          math.sin(angle + math.pi),
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: const [color1, color2, color3, color1],
              begin: begin,
              end: end,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(
              2.2,
            ), // Increased border thickness for maximum visibility!
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface.withAlpha(245),
              borderRadius: BorderRadius.circular(
                13.8,
              ), // Rounded to match the 2.2 margin
            ),
            child: child,
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.offline_bolt_rounded, color: cs.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'One-Time Download · Unlimited Offline Use',
                  style: th.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Once downloaded, models run entirely on your device with zero internet connection required. Complete privacy, ultra-low latency, and unlimited local chat.',
                  style: th.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant.withAlpha(220),
                    height: 1.45,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surface.withAlpha(150),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: cs.outlineVariant.withAlpha(80),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.memory_rounded, size: 14, color: cs.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.deviceRamGb == null
                              ? 'RAM unknown — start with the smallest model.'
                              : 'Recommended for you: Models requiring ≤ ${widget.deviceRamGb!.toStringAsFixed(0)} GB RAM.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierHeader extends StatelessWidget {
  const _TierHeader({required this.tier});
  final DeviceTier tier;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: tier.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tier.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface.withAlpha(200),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: 48,
            height: 2.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [tier.color, tier.color.withAlpha(0)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.entry,
    required this.deviceRamGb,
    required this.isDownloaded,
    required this.onTap,
    required this.onDelete,
    required this.onInfo,
    this.downloadIconKey,
  });
  final CatalogEntry entry;
  final double? deviceRamGb;
  final bool isDownloaded;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onInfo;
  final GlobalKey? downloadIconKey;

  bool get _ok => deviceRamGb == null || deviceRamGb! >= entry.minRamGb;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final cs = th.colorScheme;
    final successColor = DarkTokens.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: cs.surfaceContainerHigh,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: _ok ? cs.outlineVariant.withAlpha(60) : cs.error.withAlpha(80),
          width: 0.8,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: isDownloaded ? onTap : onInfo,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 6,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _ok
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: _ok ? successColor : cs.error,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        child: Text(
                                          entry.definition.name,
                                          style: th.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ),
                                    if (isDownloaded) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: successColor.withAlpha(30),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          'Installed',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: successColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 16,
                                      color: cs.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Show details',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: cs.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isDownloaded)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: cs.error,
                          size: 28,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Delete model',
                        visualDensity: VisualDensity.compact,
                      )
                    else
                      IconButton(
                        key: downloadIconKey,
                        icon: Icon(
                          Icons.download_rounded,
                          color: cs.primary,
                          size: 28,
                        ),
                        onPressed: onTap,
                        tooltip: 'Download model',
                        visualDensity: VisualDensity.compact,
                      ),
                    const SizedBox(height: 2),
                    Text(
                      entry.sizeLabel,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurfaceVariant.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _ok
                    ? successColor.withAlpha(20)
                    : cs.error.withAlpha(20),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  topRight: Radius.circular(14),
                ),
                border: Border.all(
                  color: _ok
                      ? successColor.withAlpha(50)
                      : cs.error.withAlpha(50),
                  width: 0.8,
                ),
              ),
              child: Text(
                _ok ? 'Works on this device' : 'May not work',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: _ok ? successColor : cs.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withAlpha(30),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 18: COMPATIBILITY DIALOG
// ══════════════════════════════════════════════════════════════════════════════

Future<bool> showCompatDialog({
  required BuildContext context,
  required CatalogEntry entry,
  required double? deviceRamGb,
  bool showTutorial = false,
}) async {
  final ok = deviceRamGb == null || deviceRamGb >= entry.minRamGb;
  final downloadBtnKey = GlobalKey();
  return await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final th = Theme.of(ctx);
          final cs = th.colorScheme;

          // Show tutorial on the download button after dialog renders
          if (showTutorial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (downloadBtnKey.currentContext == null) return;
              TutorialCoachMark(
                targets: [
                  TargetFocus(
                    identify: 'downloadBtn',
                    keyTarget: downloadBtnKey,
                    shape: ShapeLightFocus.RRect,
                    radius: 10,
                    paddingFocus: 4,
                    contents: [
                      TargetContent(
                        align: ContentAlign.top,
                        builder: (c, ctrl) => Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(children: [
                            Icon(Icons.download_rounded,
                                color: cs.primary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Tap here to start downloading!',
                              style: TextStyle(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ],
                colorShadow: Colors.black,
                opacityShadow: 0.75,
                hideSkip: true,
                paddingFocus: 4,
                onFinish: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('ElioraAI_tutorialDone', true);
                },
              ).show(context: ctx);
            });
          }

          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: ok ? DarkTokens.success : cs.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ok ? 'Compatible' : 'Compatibility warning',
                    style: th.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.definition.name,
                  style: th.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _InfoRow(label: 'Download size', value: entry.sizeLabel),
                _InfoRow(
                  label: 'Min RAM needed',
                  value: '${entry.minRamGb} GB',
                ),
                _InfoRow(
                  label: 'Your RAM',
                  value: deviceRamGb == null
                      ? 'Unknown'
                      : '${deviceRamGb.toStringAsFixed(1)} GB',
                ),
                _InfoRow(
                  label: 'Context window',
                  value: '${entry.capabilities.contextWindow} tokens',
                ),
                const SizedBox(height: 12),
                Text(
                  ok
                      ? 'This model should run well on your device.'
                      : 'Your device may not have enough RAM. Close all other apps and try anyway.',
                  style: th.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                key: downloadBtnKey,
                onPressed: () => Navigator.pop(ctx, true),
                style: ok
                    ? null
                    : FilledButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: cs.onError,
                      ),
                child: Text(ok ? 'Download' : 'Install anyway'),
              ),
            ],
          );
        },
      ) ??
      false;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 19: DOWNLOAD OVERLAY
// ══════════════════════════════════════════════════════════════════════════════

class DownloadOverlay extends StatelessWidget {
  const DownloadOverlay({
    super.key,
    required this.status,
    required this.progress,
    required this.modelName,
    this.speed,
    this.onCancel,
    this.onMinimize,
  });
  final String status;
  final double progress;
  final String modelName;
  final String? speed;
  final VoidCallback? onCancel;
  final VoidCallback? onMinimize;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final cs = th.colorScheme;
    return Material(
      color: Colors.black.withAlpha(140),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress > 0 ? progress : null,
                      strokeWidth: 4,
                      color: cs.primary,
                      backgroundColor: cs.surfaceContainerHighest,
                    ),
                    Icon(Icons.download_rounded, color: cs.primary, size: 22),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Downloading Model',
                style: th.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                modelName,
                style: th.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  minHeight: 8,
                  color: cs.primary,
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                progress > 0
                    ? '${(progress * 100).toStringAsFixed(1)}%  ·  $status'
                    : status,
                style: th.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (speed != null && speed!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  speed!,
                  style: th.textTheme.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onCancel != null || onMinimize != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (onCancel != null)
                      TextButton(
                        onPressed: onCancel,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: th.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (onMinimize != null)
                      FilledButton.icon(
                        onPressed: onMinimize,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          backgroundColor: cs.primary,
                        ),
                        icon: const Icon(Icons.arrow_drop_down_circle_outlined, size: 18),
                        label: const Text('Background'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 20: MCP SHEET
// ══════════════════════════════════════════════════════════════════════════════

Future<void> showMcpSheet({
  required BuildContext context,
  required Future<void> Function(String url) onConnect,
}) {
  final ctrl = TextEditingController();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom:
              MediaQuery.viewInsetsOf(ctx).bottom +
              MediaQuery.paddingOf(ctx).bottom +
              24,
          top: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.power_rounded,
                    color: cs.onSecondaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect MCP Server',
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Model Context Protocol · SSE/HTTP',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Connect to an MCP-compatible server to give your agent access to external tools.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Server SSE URL',
                hintText: 'http://192.168.x.x:3001/sse',
                prefixIcon: const Icon(Icons.link_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                final url = ctrl.text.trim();
                if (url.isEmpty) return;
                Navigator.pop(ctx);
                onConnect(url);
              },
              icon: const Icon(Icons.connect_without_contact_rounded),
              label: const Text('Connect'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    },
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 21: KNOWLEDGE BASE SHEET
// ══════════════════════════════════════════════════════════════════════════════

Future<void> showKnowledgeSheet({
  required BuildContext context,
  required Future<void> Function(String path, String name) onIngest,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.paddingOf(ctx).bottom + 24,
          top: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: cs.onTertiaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Knowledge Base',
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'RAG · Hybrid search + citations',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FeatureRow(
              icon: Icons.format_quote_rounded,
              color: cs.tertiary,
              title: 'Live Citations',
              subtitle:
                  'See exactly which chunk of your document the answer came from.',
            ),
            const SizedBox(height: 10),
            _FeatureRow(
              icon: Icons.search_rounded,
              color: cs.secondary,
              title: 'Hybrid Search',
              subtitle:
                  'Semantic vector search + BM25 keyword search combined.',
            ),
            const SizedBox(height: 10),
            _FeatureRow(
              icon: Icons.phonelink_lock_rounded,
              color: cs.primary,
              title: 'On-Device',
              subtitle: 'Your documents never leave your phone.',
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () async {
                final r = await FilePicker.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'txt', 'json', 'md'],
                );
                if (r == null || r.files.single.path == null) return;
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                onIngest(r.files.single.path!, r.files.single.name);
              },
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Pick file to ingest'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    },
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 22: SESSION DRAWER
// ══════════════════════════════════════════════════════════════════════════════

class SessionDrawer extends StatelessWidget {
  const SessionDrawer({
    super.key,
    required this.sessions,
    required this.activeId,
    required this.getTitle,
    required this.activeModelTag,
    required this.kitReady,
    required this.onNewChat,
    required this.onSelectSession,
    required this.onDeleteSession,
    required this.onRenameSession,
    required this.onBrowseModels,
    required this.onRetry,
    required this.onToggleTheme,
    required this.isDark,
  });

  final List<String> sessions;
  final String activeId;
  final String Function(String) getTitle;
  final String? activeModelTag;
  final bool kitReady;
  final VoidCallback onNewChat;
  final void Function(String) onSelectSession;
  final void Function(String) onDeleteSession;
  final void Function(String, String) onRenameSession;
  final VoidCallback onBrowseModels;
  final VoidCallback onRetry;
  final VoidCallback onToggleTheme;
  final bool isDark;

  Future<void> _showRenameDialog(BuildContext context, String id) async {
    final ctrl = TextEditingController(text: getTitle(id));
    final result = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Rename conversation'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter a new title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (v) => Navigator.pop(d, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(d, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      onRenameSession(id, result.trim());
    }
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (d) => AlertDialog(
            title: const Text('Delete conversation?'),
            content: Text(
              'Are you sure you want to delete "${getTitle(id)}"?\n\nThis action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(d, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(d, true),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) onDeleteSession(id);
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final cs = th.colorScheme;
    return Drawer(
      backgroundColor: cs.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 12,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [DarkTokens.tabBlue, DarkTokens.primaryContainer],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/Eliora Ai assits-2/Eliora Ai assits/playstore-icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, s) => const Icon(
                            Icons.auto_awesome_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: Colors.white,
                      ),
                      onPressed: onToggleTheme,
                      tooltip: 'Toggle theme',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Eliora AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Local Agent Studio',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 12,
                  ),
                ),
                if (activeModelTag != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          activeModelTag!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: FilledButton.icon(
              onPressed: onNewChat,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New conversation'),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primaryContainer,
                foregroundColor: cs.onPrimaryContainer,
                minimumSize: const Size(double.infinity, 42),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.explore_rounded, color: cs.secondary),
            title: const Text(
              'Browse models',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              kitReady
                  ? 'Switch or install models'
                  : 'Install an on-device LLM',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
            onTap: () {
              Navigator.pop(context);
              onBrowseModels();
            },
          ),
          ListTile(
            leading: Icon(Icons.refresh_rounded, color: cs.primary),
            title: const Text(
              'Retry detection',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              onRetry();
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Text(
              'Conversations',
              style: th.textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: sessions.isEmpty
                ? Center(
                    child: Text(
                      'No conversations yet',
                      style: th.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (ctx, i) {
                      final id = sessions[i];
                      final active = id == activeId;
                      return ListTile(
                        selected: active,
                        selectedTileColor: cs.secondaryContainer.withAlpha(80),
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          right: 4,
                        ),
                        leading: Icon(
                          active
                              ? Icons.chat_bubble_rounded
                              : Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: active
                              ? cs.secondary
                              : cs.onSurfaceVariant.withAlpha(150),
                        ),
                        title: Text(
                          getTitle(id),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: th.textTheme.bodyMedium?.copyWith(
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: active
                                ? cs.onSurface
                                : cs.onSurface.withAlpha(200),
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: cs.onSurfaceVariant.withAlpha(150),
                          ),
                          padding: EdgeInsets.zero,
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'rename',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_rounded, size: 18),
                                  SizedBox(width: 10),
                                  Text('Rename'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: cs.error,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: cs.error),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (action) {
                            if (action == 'rename') {
                              _showRenameDialog(ctx, id);
                            } else if (action == 'delete') {
                              _confirmDelete(ctx, id);
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          onSelectSession(id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 23: APP ENTRY POINT
// ══════════════════════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await LicenseService.instance.init();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  runApp(const ElioraAIApp());
}

class ElioraAIApp extends StatefulWidget {
  const ElioraAIApp({super.key});

  @override
  State<ElioraAIApp> createState() => _ElioraAIAppState();
}

class _ElioraAIAppState extends State<ElioraAIApp> {
  ThemeMode _mode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _restoreTheme();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(DownloadNotifier.instance.init());
    });
  }

  Future<void> _restoreTheme() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString('ElioraAI_theme');
    if (!mounted) return;
    setState(() {
      if (s == 'light') {
        _mode = ThemeMode.light;
      } else if (s == 'dark') {
        _mode = ThemeMode.dark;
      } else {
        _mode = ThemeMode.system;
      }
    });
  }

  Future<void> _toggleTheme() async {
    final systemDark =
        View.of(context).platformDispatcher.platformBrightness ==
        Brightness.dark;
    final currentThemeIsDark =
        _mode == ThemeMode.dark || (_mode == ThemeMode.system && systemDark);
    final next = currentThemeIsDark ? ThemeMode.light : ThemeMode.dark;
    setState(() => _mode = next);
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'ElioraAI_theme',
      next == ThemeMode.light ? 'light' : 'dark',
    );
  }

  @override
  Widget build(BuildContext context) {
    final systemDark =
        View.of(context).platformDispatcher.platformBrightness ==
        Brightness.dark;
    final isDark = _mode == ThemeMode.system
        ? systemDark
        : (_mode == ThemeMode.dark);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eliora AI',
      themeMode: _mode,
      theme: _buildLight(),
      darkTheme: _buildDark(),
      home: ValueListenableBuilder<bool>(
        valueListenable: LicenseService.instance.isLocked,
        builder: (context, locked, child) {
          if (locked) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'contact the original developer who holders the lisence of this app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }
          return MainPage(onToggleTheme: _toggleTheme, isDark: isDark);
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 24: MAIN PAGE ORCHESTRATOR
// ══════════════════════════════════════════════════════════════════════════════

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });
  final VoidCallback onToggleTheme;
  final bool isDark;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final _kit = FlutterLocalAgentKit();
  SessionManager? _sm;
  double? _ramGb;

  bool _booting = true;
  bool _kitReady = false;
  bool _downloading = false;
  bool _downloadCancelled = false;
  double _dlProgress = 0;
  String _dlStatus = '';
  String _dlModel = '';
  String _dlSpeed = '';

  String? _activeModelId;
  String _activeModelName = '';
  CatalogEntry? get _activeEntry =>
      _activeModelId == null ? null : ElioraCatalog.byId(_activeModelId!);

  String _sessionId = 'default';
  List<String> _sessions = [];
  List<AgentChatMessage> _history = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Tutorial keys ─────────────────────────────────────────────────────────
  final _keyAppTitle = GlobalKey();
  final _keyMenuButton = GlobalKey();
  final _keyThemeToggle = GlobalKey();
  bool _tutorialShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _boot();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Stop any active TTS playback
      sharedTts.stop();
      // Notice: We removed DownloadNotifier.instance.cancelIfActive() here
      // so the notification persists and download continues in background.
    }
  }

  Future<void> _boot() async {
    if (mounted) setState(() => _booting = true);
    try {
      _ramGb = await _readDeviceRamGb();
      _sm = await SessionManager.create();

      // ── Clean up partially downloaded models ──────────────────────
      final prefs = await SharedPreferences.getInstance();
      final partialId = prefs.getString('ElioraAI_downloading');
      if (partialId != null) {
        debugPrint('Cleaning up partial download: $partialId');
        try {
          await _kit.models.deleteModel(partialId);
        } catch (_) {}
        await prefs.remove('ElioraAI_downloading');
      }

      await _scanDisk();
    } catch (e) {
      debugPrint('Boot error: $e');
    } finally {
      if (mounted) setState(() => _booting = false);
    }

    // ── Show onboarding tutorial on first launch ─────────────────
    if (mounted && !_tutorialShown) {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool('ElioraAI_tutorialDone') ?? false;
      if (!done) {
        _tutorialShown = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) _showTutorial();
        });
      }
    }
  }

  Future<void> _scanDisk() async {
    final preferred = _sm?.savedModelId;
    final order = <String>[];
    if (preferred != null) order.add(preferred);
    for (final e in ElioraCatalog.all) {
      if (!order.contains(e.definition.id)) order.add(e.definition.id);
    }
    for (final id in order) {
      try {
        if (await _kit.models.isModelDownloaded(id)) {
          await _initRuntime(id);
          return;
        }
      } catch (_) {}
    }
  }

  Future<void> _initRuntime(String id, {int retries = 3}) async {
    for (var attempt = 1; attempt <= retries; attempt++) {
      try {
        final path = await _kit.models.getLocalPath(id);
        final entry = ElioraCatalog.byId(id);
        final gpu = entry?.tier.gpuLayers ?? 24;

        await _kit.initialize(
          modelPath: path,
          gpuLayers: gpu,
          template: elioraPromptTemplateForModel(
            id,
            entry?.definition.name ?? '',
          ),
        );

        final sessions = await _kit.persistence.listSessions();
        final lastSid = _sm?.lastSessionId ?? 'default';
        final history = await _tryLoad(lastSid);
        final allSids = sessions.isEmpty ? <String>[] : List<String>.from(sessions);
        await _sm?.ensureIds(allSids);
        await _sm?.setModelId(id);

        if (!mounted) return;
        setState(() {
          _kitReady = true;
          _activeModelId = id;
          _activeModelName = entry?.definition.name ?? id;
          _sessionId = lastSid;
          _sessions = allSids;
          _history = history;
        });
        return; // success — exit retry loop
      } catch (e) {
        debugPrint('_initRuntime attempt $attempt/$retries failed: $e');
        if (attempt < retries) {
          await Future<void>.delayed(const Duration(seconds: 2));
        } else {
          if (mounted) _snack('Could not load model: $e', error: true);
        }
      }
    }
  }

  Future<List<AgentChatMessage>> _tryLoad(String id) async {
    try {
      return await _kit.loadSession(id);
    } catch (_) {
      return [];
    }
  }

  Future<void> _downloadAndInit(CatalogEntry entry) async {
    _downloadCancelled = false;
    DownloadNotifier.onCancelAction = () {
      if (mounted) _cancelDownload();
    };
    try {
      await DownloadNotifier.instance.init();
      await DownloadNotifier.instance.requestPermission();
    } catch (_) {}

    // Track active download so partial files can be cleaned on reboot
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ElioraAI_downloading', entry.definition.id);
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _downloading = true;
      _dlProgress = 0;
      _dlStatus = 'Connecting…';
      _dlModel = entry.definition.name;
      _dlSpeed = '';
    });

    var lastPct = -1;
    var lastUIAt = DateTime.fromMillisecondsSinceEpoch(0);
    var lastSpeedProg = 0.0;
    var lastSpeedTime = DateTime.now();
    final totalBytes = entry.definition.estimatedSizeInBytes;
    double smoothedBps = 0; // EMA-smoothed bytes/sec

    try {
      await DownloadNotifier.instance.start(entry.definition.name);
      await _kit.models.downloadModel(
        entry.definition,
        onProgress: (p) {
          final clamped = p.clamp(0.0, 1.0);
          final pct = (clamped * 100).floor();
          final now = DateTime.now();

          // Periodically check if background cancellation was requested (every 1.5s)
          if (now.difference(lastSpeedTime).inMilliseconds >= 1500) {
            SharedPreferences.getInstance().then((prefs) {
              prefs.reload().then((_) {
                if (prefs.getBool('ElioraAI_cancel_bg') == true) {
                  prefs.remove('ElioraAI_cancel_bg');
                  if (mounted) _cancelDownload();
                }
              });
            });
          }

          if (_downloadCancelled) return;
          if (clamped < 1.0 &&
              pct == lastPct &&
              now.difference(lastUIAt) < const Duration(milliseconds: 300)) {
            return;
          }
          lastPct = pct;
          lastUIAt = now;

          // Calculate download speed with exponential smoothing
          var speedText = _dlSpeed;
          final elapsed = now.difference(lastSpeedTime);
          if (elapsed.inMilliseconds >= 1500) {
            final deltaBytes =
                (clamped - lastSpeedProg) * totalBytes;
            final instantBps =
                deltaBytes / (elapsed.inMilliseconds / 1000);
            // EMA: 70% old + 30% new for smooth transitions
            smoothedBps = smoothedBps <= 0
                ? instantBps
                : smoothedBps * 0.7 + instantBps * 0.3;
            if (smoothedBps > 0) {
              final mbPerSec = smoothedBps / (1024 * 1024);
              speedText = mbPerSec >= 1.0
                  ? '${mbPerSec.toStringAsFixed(1)} MB/s'
                  : '${(smoothedBps / 1024).toStringAsFixed(0)} KB/s';
            }
            lastSpeedProg = clamped;
            lastSpeedTime = now;
          }

          if (mounted) {
            setState(() {
              _dlProgress = clamped;
              _dlStatus = '$pct%';
              _dlSpeed = speedText;
            });
          }
          unawaited(DownloadNotifier.instance.progress(clamped));
        },
      );

      // If cancelled while download was in progress, clean up
      if (_downloadCancelled) {
        try {
          await _kit.models.deleteModel(entry.definition.id);
        } catch (_) {}
        await DownloadNotifier.instance.done(ok: false, msg: 'Cancelled');
        return;
      }

      if (mounted) setState(() => _dlStatus = 'Initializing…');
      await _initRuntime(entry.definition.id);
      await DownloadNotifier.instance.done(ok: true);
      _snack('${entry.definition.name} is ready!');
    } catch (e) {
      if (_downloadCancelled) return;
      await DownloadNotifier.instance.done(ok: false, msg: e.toString());
      _snack('Download failed: $e', error: true);
    } finally {
      // Clear download tracking
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('ElioraAI_downloading');
      } catch (_) {}
      if (mounted && !_downloadCancelled) {
        setState(() => _downloading = false);
      }
    }
  }

  void _cancelDownload() {
    _downloadCancelled = true;
    DownloadNotifier.instance.cancelIfActive();
    // Clean up partial download tracking
    SharedPreferences.getInstance().then((p) {
      final id = p.getString('ElioraAI_downloading');
      if (id != null) {
        _kit.models.deleteModel(id).catchError((_) => null);
        p.remove('ElioraAI_downloading');
      }
    }).catchError((_) => null);
    if (mounted) {
      setState(() => _downloading = false);
    }
    _snack('Download cancelled');
  }

  Future<void> _switchSession(String id) async {
    final h = await _tryLoad(id);
    await _sm?.setLastSession(id);
    if (!mounted) return;
    setState(() {
      _sessionId = id;
      _history = h;
    });
  }

  Future<void> _newSession() async {
    // Lazy session — only added to the sidebar list when user sends a message
    final id = const Uuid().v4();
    await _sm?.setLastSession(id);
    if (!mounted) return;
    setState(() {
      _sessionId = id;
      _history = [];
    });
  }

  Future<void> _deleteSession(String id) async {
    try {
      await _kit.persistence.deleteSession(id);
    } catch (_) {}
    await _sm?.remove(id);
    if (!mounted) return;
    final wasActive = _sessionId == id;
    setState(() {
      _sessions = List<String>.from(_sessions)..remove(id);
      if (wasActive) {
        // Go to a fresh blank state (lazy — no new session in sidebar yet)
        final newId = const Uuid().v4();
        _sm?.setLastSession(newId);
        _sessionId = newId;
        _history = [];
      }
    });
  }

  Future<void> _renameSession(String id, String newTitle) async {
    await _sm?.setTitle(id, newTitle);
    if (mounted) setState(() {});
  }

  String? _deriveTitle(List<AgentChatMessage> history) {
    for (final m in history) {
      if (m.role != MessageRole.user) continue;
      var t = m.content.trim();
      if (t.isEmpty && m.imageBytes != null) return 'Image conversation';
      if (t.isEmpty) continue;
      t = t.split(RegExp(r'[\r\n]+')).first.trim();
      if (t.length > 50) return '${t.substring(0, 47)}…';
      if (t.isNotEmpty) return t;
    }
    return null;
  }

  void _onHistoryChanged(List<AgentChatMessage> h) {
    _history = h;
    unawaited(_kit.saveSession(_sessionId, h));

    // Lazy session: add to sidebar on first message
    if (!_sessions.contains(_sessionId)) {
      _sessions = [_sessionId, ..._sessions];
      unawaited(_sm?.addSession(_sessionId, 'New conversation'));
    }

    final derived = _deriveTitle(h);
    if (derived != null && (_sm?.isGeneric(_sessionId) ?? true)) {
      unawaited(_sm?.setTitle(_sessionId, derived));
    }
    if (mounted) setState(() {});
  }

  // ignore: unused_element — kept for future re-enablement
  Future<void> _connectMcp(String url) async {
    try {
      final transport = mcp.StreamableHttpClientTransport(Uri.parse(url));
      await _kit.useMcpServer(transport);
      _snack('MCP connected — tools synchronized');
    } catch (e) {
      _snack('MCP error: $e', error: true);
    }
  }

  // ignore: unused_element — kept for future re-enablement
  Future<void> _ingest(String path, String name) async {
    _snack('Ingesting $name…');
    try {
      await _kit.ingestFile(path);
      _snack('✓ $name added to knowledge base');
    } catch (e) {
      _snack('Ingest failed: $e', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? cs.errorContainer : null,
      ),
    );
  }


  void _openExplorer({bool showTutorial = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => ModelExplorerPage(
          deviceRamGb: _ramGb,
          modelManager: _kit.models,
          showTutorial: showTutorial,
          onPick: (entry) async {
            Navigator.pop(ctx);
            // If already downloaded, just switch to it
            try {
              if (await _kit.models.isModelDownloaded(
                entry.definition.id,
              )) {
                await _initRuntime(entry.definition.id);
                _snack('Switched to ${entry.definition.name}');
                return;
              }
            } catch (_) {}
            if (!mounted) return;
            final go = await showCompatDialog(
              context: context,
              entry: entry,
              deviceRamGb: _ramGb,
              showTutorial: showTutorial,
            );
            if (go && mounted) await _downloadAndInit(entry);
          },
        ),
      ),
    );
  }

  void _onWelcomeAttempt(String _) {
    showInstallSheet(context: context, onExplore: _openExplorer);
  }

  Color get _accent => Theme.of(context).colorScheme.primary;

  Widget _appBarTitle() {
    final cs = Theme.of(context).colorScheme;
    final entry = _activeEntry;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          key: _keyAppTitle,
          onTap: _openExplorer,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GradientTitle(
                  text: 'Eliora AI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 1),
                if (_kitReady && entry != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 12,
                        color: DarkTokens.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.tag} · active',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFFFFC107),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Tap to browse models',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: cs.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sm = _sm;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: cs.surface,
      drawer: sm == null
          ? null
          : SessionDrawer(
              sessions: _sessions,
              activeId: _sessionId,
              getTitle: sm.title,
              activeModelTag: _activeEntry?.tag,
              kitReady: _kitReady,
              onNewChat: () {
                Navigator.pop(context);
                _newSession();
              },
              onSelectSession: _switchSession,
              onDeleteSession: _deleteSession,
              onRenameSession: _renameSession,
              onBrowseModels: _openExplorer,
              onRetry: _boot,
              onToggleTheme: widget.onToggleTheme,
              isDark: widget.isDark,
            ),
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          key: _keyMenuButton,
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: _appBarTitle(),
        actions: [
          IconButton(
            key: _keyThemeToggle,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            icon: Icon(
              widget.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_downloading)
            Positioned.fill(
              child: DownloadOverlay(
                status: _dlStatus,
                progress: _dlProgress,
                modelName: _dlModel,
                speed: _dlSpeed,
                onCancel: _cancelDownload,
                onMinimize: () {
                  const MethodChannel('com.eliora_ai/app_control')
                      .invokeMethod('moveToBackground');
                },
              ),
            ),
        ],
      ),
    );
  }

  String? _pendingPrompt;

  Widget _buildBody() {
    if (_booting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_kitReady && _sm != null) {
      // Show welcome screen when chat is empty (new conversation)
      if (_history.isEmpty && _pendingPrompt == null) {
        return WelcomeView(
          onAttempt: (prompt) {
            setState(() => _pendingPrompt = prompt);
          },
        );
      }
      final prompt = _pendingPrompt;
      // Consume _pendingPrompt in a post-frame callback to avoid
      // mutating state inside build() — prevents losing the prompt
      // on unexpected rebuilds (theme change, keyboard, etc.)
      if (prompt != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pendingPrompt = null;
        });
      }
      return AgentChatView(
        key: ValueKey(_sessionId),
        kit: _kit,
        capabilities: _activeEntry?.capabilities ?? const ModelCapabilities(),
        sessionId: _sessionId,
        initialHistory: _history,
        onHistoryChanged: _onHistoryChanged,
        accentColor: _accent,
        activeModelId: _activeModelId ?? '',
        activeModelName: _activeModelName,
        initialPrompt: prompt,
      );
    }
    return WelcomeView(
      onAttempt: _onWelcomeAttempt,
      downloadBusy: _downloading,
      downloadProgress: _dlProgress,
      downloadStatusText: _dlStatus.isNotEmpty ? _dlStatus : null,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ONBOARDING TUTORIAL
  // ══════════════════════════════════════════════════════════════════════════════

  void _showTutorial() {
    final cs = Theme.of(context).colorScheme;

    TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'browseModels',
          keyTarget: _keyAppTitle,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          paddingFocus: 4,
          enableTargetTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (ctx, ctrl) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.touch_app_rounded,
                          color: cs.primary, size: 20),
                      const SizedBox(width: 10),
                      Text('Welcome! Tap here',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          )),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      'Browse & download AI models.\n'
                      'You need at least one model to start chatting.',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      hideSkip: false,
      textSkip: 'Dismiss',
      alignSkip: Alignment.topLeft,
      textStyleSkip: TextStyle(
        color: cs.onSurface.withAlpha(160),
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      paddingFocus: 4,
      onClickTarget: (target) {
        // Navigate to explorer with tutorial
        _openExplorer(showTutorial: true);
      },
      onFinish: () {},
      onSkip: () {
        SharedPreferences.getInstance().then((p) {
          p.setBool('ElioraAI_tutorialDone', true);
        });
        return true;
      },
    ).show(context: context);
  }
}
