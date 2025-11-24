part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  const SettingsState(this.settings);

  const SettingsState.initial() : settings = const SettingsModel();

  factory SettingsState.fromJson(Map<String, dynamic> json) => SettingsState(
        SettingsModel(isSetting1: json['isSetting1'] as bool),
      );

  final SettingsModel settings;

  @override
  List<Object> get props => [settings];

  SettingsState copyWith({SettingsModel? settings}) =>
      SettingsState(settings ?? this.settings);

  Map<String, dynamic> toJson() => {'settings': settings};
}

class SettingsModel {
  const SettingsModel({
    this.isSetting1 = false,
  });
  final bool isSetting1;
}
