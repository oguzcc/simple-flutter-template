part of '../view/home_screen.dart';

mixin HomeMixin<T extends StatefulWidget> on State<T> {
  final cTag = TextEditingController();

  Future<void> addTag() async {
    if (cTag.text.isEmpty) return;
    await context.read<TagCubit>().addTag(TagModel(name: cTag.text));
    await fetchTags();
    cTag.clear();
  }

  Future<void> deleteTag(String id) async {
    await context.read<TagCubit>().deleteTag(id);
    await fetchTags();
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
    // fetchSingleTag("8Nt6c4oDlLXFTVid72Vc");
    // fetchTagListByQuery('name', 'books');
    // fetchTagListByArrayContains('name', 'books');
  }

  Future<void> updateTag(String id) async {
    Navigator.of(context).pop();
    await context.read<TagCubit>().updateTag(TagModel(name: cTag.text, id: id));
    await fetchTags();
    cTag.clear();
  }
}
