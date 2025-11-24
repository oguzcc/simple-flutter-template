part of '{{name.snakeCase()}}_cubit.dart';

@freezed
class {{name.pascalCase()}}State with _${{name.pascalCase()}}State {
  const factory {{name.pascalCase()}}State({
    @Default(Status.initial) Status status,
    @Default([]) List<{{name.pascalCase()}}Model> {{name.snakeCase()}}List,
    {{name.pascalCase()}}Model? current{{name.pascalCase()}},
  }) = _{{name.pascalCase()}}State;
}
