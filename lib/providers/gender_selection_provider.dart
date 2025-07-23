import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Gender { male, female, none }

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

class GenderSelectionNotifier extends StateNotifier<GenderSelectionState> {
  GenderSelectionNotifier() : super(const GenderSelectionState());

  void selectGender(Gender gender) {
    state = state.copyWith(selectedGender: gender);
  }

  void clearSelection() {
    state = state.copyWith(selectedGender: Gender.none);
  }

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

  bool isMaleSelected() {
    return state.selectedGender == Gender.male;
  }

  bool isFemaleSelected() {
    return state.selectedGender == Gender.female;
  }
}

final genderSelectionProvider =
    StateNotifierProvider<GenderSelectionNotifier, GenderSelectionState>(
      (ref) => GenderSelectionNotifier(),
    );
