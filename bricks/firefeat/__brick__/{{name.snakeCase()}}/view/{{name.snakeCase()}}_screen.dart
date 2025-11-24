import 'package:daisy/feature/{{name.snakeCase()}}/cubit/{{name.snakeCase()}}_cubit.dart';
import 'package:daisy/feature/{{name.snakeCase()}}/model/{{name.snakeCase()}}_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../mixin/{{name.snakeCase()}}_mixin.dart';

class {{name.pascalCase()}}Screen extends StatelessWidget {
  const {{name.pascalCase()}}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{name.pascalCase()}} Screen'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('{{name.pascalCase()}} Screen')],
        ),
      ),
    );
  }
}
