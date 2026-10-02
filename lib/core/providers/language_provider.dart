import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether the UI is currently in Hindi or English.
/// false = English, true = Hindi
final isHindiProvider = StateProvider<bool>((ref) => false);
