part of 'lang_cubit.dart';

class LangState extends Equatable {
  const LangState(this.locale);

  factory LangState.fromJson(Map<String, dynamic> json) => LangState(
        Locale(json['languageCode'] as String, json['countryCode'] as String),
      );

  factory LangState.initial() => const LangState(Locale('en', 'US'));

  final Locale locale;

  @override
  List<Object> get props => [locale];

  LangState copyWith({Locale? locale}) => LangState(locale ?? this.locale);

  Map<String, dynamic> toJson() =>
      {'languageCode': locale.languageCode, 'countryCode': locale.countryCode};
}
