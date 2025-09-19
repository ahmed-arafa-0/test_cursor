import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(EnglishLanguageState());

  String _currentLanguage = 'English';

  String get currentLanguage => _currentLanguage;

  void changeLanguage(String language) {
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
      default:
        emit(EnglishLanguageState());
    }
  }

  void toggleLanguage() {
    switch (_currentLanguage) {
      case 'English':
        changeLanguage('Arabic');
        break;
      case 'Arabic':
        changeLanguage('Italian');
        break;
      case 'Italian':
        changeLanguage('Greek');
        break;
      case 'Greek':
        changeLanguage('English');
        break;
      default:
        changeLanguage('English');
    }
  }

  String getLanguageFlag() {
    switch (_currentLanguage) {
      case 'English':
        return '🇺🇸';
      case 'Arabic':
        return '🇸🇦';
      case 'Italian':
        return '🇮🇹';
      case 'Greek':
        return '🇬🇷';
      default:
        return '🇺🇸';
    }
  }
}
