import 'package:flutter/material.dart';

/// Which theme the gallery is rendering.
///
/// The design system ships both modes, so the gallery has to be able to show
/// either one: a component is only validated once it has been looked at in the
/// light theme as well as in the dark one, which is the product's default.
///
/// It is a [ValueNotifier] rather than plain state so the toggle and the
/// application shell can be in different subtrees without passing callbacks
/// through every page.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController([super.initial = ThemeMode.dark]);

  bool get isDark => value == ThemeMode.dark;

  /// Switches to the other mode.
  void toggle() => value = isDark ? ThemeMode.light : ThemeMode.dark;
}
