import 'package:flutter_riverpod/flutter_riverpod.dart';

// Cinsiyet seçenekleri enum'u
enum Gender { male, female, none }

// Cinsiyet seçimi state class'ı
class GenderSelectionState {
  final Gender selectedGender;
  final bool isLoading;

  const GenderSelectionState({
    this.selectedGender = Gender.male,
    this.isLoading = false,
  });

  GenderSelectionState copyWith({Gender? selectedGender, bool? isLoading}) {
    return GenderSelectionState(
      selectedGender: selectedGender ?? this.selectedGender,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Cinsiyet seçimi notifier
class GenderSelectionNotifier extends StateNotifier<GenderSelectionState> {
  GenderSelectionNotifier() : super(const GenderSelectionState());

  // Cinsiyet seçimi
  void selectGender(Gender gender) {
    state = state.copyWith(selectedGender: gender);
  }

  // Seçimi temizle
  void clearSelection() {
    state = state.copyWith(selectedGender: Gender.none);
  }

  // Seçili cinsiyeti string olarak al
  String getSelectedGenderString() {
    switch (state.selectedGender) {
      case Gender.male:
        return 'Erkek';
      case Gender.female:
        return 'Kadın';
      case Gender.none:
        return '';
    }
  }

  // Erkek seçili mi kontrol et
  bool isMaleSelected() {
    return state.selectedGender == Gender.male;
  }

  // Kadın seçili mi kontrol et
  bool isFemaleSelected() {
    return state.selectedGender == Gender.female;
  }
}

// Provider tanımı
final genderSelectionProvider =
    StateNotifierProvider<GenderSelectionNotifier, GenderSelectionState>(
      (ref) => GenderSelectionNotifier(),
    );
