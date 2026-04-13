part of '../view/home_screen.dart';

mixin HomeMixin<T extends StatefulWidget> on State<T> {
  final cTag = TextEditingController();

  @override
  void dispose() {
    cTag.dispose();
    super.dispose();
  }

  Future<void> addTag() async {
    if (cTag.text.isEmpty) return;
    final cubit = context.read<TagCubit>();
    await cubit.addTag(TagModel(name: cTag.text));
    await cubit.fetchTagList();
    cTag.clear();
  }

  Future<void> deleteTag(String id) async {
    final cubit = context.read<TagCubit>();
    await cubit.deleteTag(id);
    await cubit.fetchTagList();
  }

  Future<void> fetchSingleTag(String id) async {
    await context.read<TagCubit>().fetchSingleTag(id);
  }

  Future<void> fetchTagListByArrayContains(String field, dynamic value) async {
    await context.read<TagCubit>().fetchTagListByArrayContains(field, value);
  }

  Future<void> fetchTagListByQuery(String field, dynamic value) async {
    await context.read<TagCubit>().fetchTagListByQuery(field, value);
  }

  Future<void> fetchTags() async {
    await context.read<TagCubit>().fetchTagList();
  }

  Future<void> init() async {
    await fetchTags();
  }

  Future<void> updateTag(String id) async {
    final cubit = context.read<TagCubit>();
    Navigator.of(context).pop();
    await cubit.updateTag(TagModel(name: cTag.text, id: id));
    await cubit.fetchTagList();
    cTag.clear();
  }
}
