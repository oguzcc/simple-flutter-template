part of '../view/{{name.snakeCase()}}_screen.dart';

mixin HomeMixin<T extends StatefulWidget> on State<T> {
  final c{{name.pascalCase()}} = TextEditingController();

  void init() async {
    fetch{{name.pascalCase()}}List();
  }

  Future<void> fetch{{name.pascalCase()}}List() async {
    await context.read<{{name.pascalCase()}}Cubit>().fetch{{name.pascalCase()}}List();
  }

  Future<void> fetchSingle{{name.pascalCase()}}(String id) async {
    await context.read<{{name.pascalCase()}}Cubit>().fetchSingle{{name.pascalCase()}}(id);
  }

  Future<void> fetch{{name.pascalCase()}}ListByQuery(String field, dynamic value) async {
    await context.read<{{name.pascalCase()}}Cubit>().fetch{{name.pascalCase()}}ListByQuery(field, value);
  }

  Future<void> add{{name.pascalCase()}}() async {
    await context.read<{{name.pascalCase()}}Cubit>().add{{name.pascalCase()}}({{name.pascalCase()}}Model(name: c{{name.pascalCase()}}.text));
    fetch{{name.pascalCase()}}List();
    c{{name.pascalCase()}}.clear();
  }

  Future<void> update{{name.pascalCase()}}(String id) async {
    Navigator.of(context).pop();
    await context.read<{{name.pascalCase()}}Cubit>().update{{name.pascalCase()}}({{name.pascalCase()}}Model(name: c{{name.pascalCase()}}.text, id: id));
    fetch{{name.pascalCase()}}List();
    c{{name.pascalCase()}}.clear();
  }

  Future<void> delete{{name.pascalCase()}}(String id) async {
    await context.read<{{name.pascalCase()}}Cubit>().delete{{name.pascalCase()}}(id);
    fetch{{name.pascalCase()}}List();
  }
}
