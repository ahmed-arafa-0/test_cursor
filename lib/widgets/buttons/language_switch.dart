// lib/widgets/buttons/language_switch.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/language_cubit/language_cubit.dart';

class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        final languageCubit = context.read<LanguageCubit>();
        final currentLanguage = languageCubit.currentLanguage;
        final currentFlag =
            languageCubit.languageFlags[currentLanguage] ?? '🇺🇸';

        return Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: PopupMenuButton<String>(
            color: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (language) {
              context.read<LanguageCubit>().changeLanguage(language);
            },
            itemBuilder: (BuildContext context) {
              return languageCubit.languageFlags.entries.map((entry) {
                final isSelected = entry.key == currentLanguage;
                return PopupMenuItem<String>(
                  value: entry.key,
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Row(
                      children: [
                        Text(entry.value, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: isSelected ? Colors.yellow : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            color: Colors.yellow,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList();
            },
            child: Center(
              child: Text(currentFlag, style: const TextStyle(fontSize: 18)),
            ),
            tooltip: 'Switch Language',
          ),
        );
      },
    );
  }
}
