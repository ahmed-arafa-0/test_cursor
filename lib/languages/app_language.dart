import 'package:test_cursor/models/sentence.dart';

class AppLanguage {
  static const Sentence title = Sentence(
    english: 'Counting down to Veuolla\'s Birthday 🎂',
    arabic: 'العد التنازلي لعيد ميلاد فيولا 🎂',
    italian: 'Conto alla rovescia per il compleanno di Veuolla 🎂',
    greek: 'Αντίστροφη μέτρηση για τα γενέθλια της Veuolla 🎂',
  );

  static const Sentence counterDay = Sentence(
    english: 'Days',
    arabic: 'أيام',
    italian: 'Giorni',
    greek: 'Μέρες',
  );
  static const Sentence counterHour = Sentence(
    english: 'Hours',
    arabic: 'ساعات',
    italian: 'Ore',
    greek: 'Ώρες',
  );
  static const Sentence counterMin = Sentence(
    english: 'Minutes',
    arabic: 'دقائق',
    italian: 'Minuti',
    greek: 'Λεπτά',
  );
  static const Sentence counterSec = Sentence(
    english: 'Seconds',
    arabic: 'ثواني',
    italian: 'Secondi',
    greek: 'Δευτερόλεπτα',
  );

  static const Sentence defaultQuote = Sentence(
    english: 'You are amazing every single day. 🌟',
    arabic: 'أنتِ رائعة في كل يوم. 🌟',
    italian: 'Sei fantastica ogni giorno. 🌟',
    greek: 'Είσαι υπέροχη κάθε μέρα. 🌟',
  );
}
