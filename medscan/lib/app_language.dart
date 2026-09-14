```dart
import 'package:flutter/material.dart';

class AppLanguage {
  static String selectedLanguage = 'English';

  static const List<String> languages = [
    'English',
    'Malayalam',
    'Hindi',
    'Tamil',
  ];

  static void setLanguage(String language) {
    selectedLanguage = language;
  }

  static String getLanguageCode() {
    switch (selectedLanguage) {
      case 'Malayalam':
        return 'ml';

      case 'Hindi':
        return 'hi';

      case 'Tamil':
        return 'ta';

      case 'English':
      default:
        return 'en';
    }
  }

  static Locale getLocale() {
    return Locale(getLanguageCode());
  }
}
```

