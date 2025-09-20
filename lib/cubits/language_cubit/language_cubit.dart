// lib/cubits/language_cubit/language_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(EnglishLanguageState());

  String _currentLanguage = 'English';

  String get currentLanguage => _currentLanguage;

  // Language flags mapping
  final Map<String, String> languageFlags = {
    'English': '🇺🇸',
    'Arabic': '🇸🇦',
    'Italian': '🇮🇹',
    'Greek': '🇬🇷',
  };

  final List<String> availableLanguages = [
    'English',
    'Arabic',
    'Italian',
    'Greek',
  ];

  // Fixed method name to match your existing code
  String getLanguageFlag(String language) {
    return languageFlags[language] ?? '🇺🇸';
  }

  void changeLanguage(String language) {
    if (!availableLanguages.contains(language)) return;

    _currentLanguage = language;

    switch (language) {
      case 'English':
        emit(EnglishLanguageState());
        break;
      case 'Arabic':
        emit(ArabicLanguageState());
        break;
      case 'Italian':
        emit(ItalianLanguageState());
        break;
      case 'Greek':
        emit(GreekLanguageState());
        break;
    }
  }

  void nextLanguage() {
    final currentIndex = availableLanguages.indexOf(_currentLanguage);
    final nextIndex = (currentIndex + 1) % availableLanguages.length;
    changeLanguage(availableLanguages[nextIndex]);
  }
}
