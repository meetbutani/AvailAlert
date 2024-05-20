// import 'package:flutter/material.dart';

// class ThemeManager with ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.dark;

//   get themeMode => _themeMode;

//   toggleTheme(bool isDark) {
//     if (isDark) {
//       _themeMode = ThemeMode.dark;
//     } else {
//       _themeMode = ThemeMode.light;
//     }
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class MyTheme {
  static late GetStorage storage;

  // Initialize the _prefs variable
  static void init() {
    storage = GetStorage();
  }

  static Color get primary => _primaryColor();
  static Color get accent => _accentColor();
  static Color get background => _backgroundColor();
  static Color get cardBackground => _cardBackgroundColor();
  static Color get buttonBackground => _buttonBackgroundColor();
  static Color get buttonRippleEffectColor => _buttonRippleEffectColor();
  static Color get textColor => _textColor();
  static TextStyle get buttonTextStyle => _buttonTextStyle();
  static get toggleTheme => _toggleTheme();

  static Color _primaryColor() {
    return (storage.read("darkMode") ?? true)
        ? Colors.deepOrangeAccent
        : Colors.deepOrangeAccent;
  }

  static Color _accentColor() {
    return (storage.read("darkMode") ?? true) ? Color(0xFFFF9800) : Colors.orange;
  }

  static Color _backgroundColor() {
    return (storage.read("darkMode") ?? true)
        ? const Color(0xFF161823)
        : const Color(0xFFF1F3F6);
  }

  static Color _cardBackgroundColor() {
    return (storage.read("darkMode") ?? true)
        ? const Color(0xFF202331)
        : const Color(0xffF1F3F6);
  }

  static Color _buttonBackgroundColor() {
    return (storage.read("darkMode") ?? true)
        ? const Color(0xFF202331)
        : const Color(0xFF202331);
  }

  static Color _buttonRippleEffectColor() {
    return (storage.read("darkMode") ?? true)
        ? const Color(0xFF2D3141)
        : const Color(0xFF2D3141);
  }

  static Color _textColor() {
    return (storage.read("darkMode") ?? true) ? Colors.white : Colors.black;
  }

  static TextStyle _buttonTextStyle() {
    return (storage.read("darkMode") ?? true)
        ? const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)
        : const TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500);
  }

  static void _toggleTheme() {
    storage.write('darkMode', !(storage.read("darkMode") ?? true));
  }
}
