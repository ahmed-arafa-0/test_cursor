part of 'language_cubit.dart';

@immutable
sealed class LanguageState {}

final class LanguageInitial extends LanguageState {}

final class EnglishLanguageState extends LanguageState {}

final class ArabicLanguageState extends LanguageState {}

final class ItalianLanguageState extends LanguageState {}

final class GreekLanguageState extends LanguageState {}
