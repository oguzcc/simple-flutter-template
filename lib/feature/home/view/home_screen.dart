import 'package:daisy/core/extension/string_extension.dart';
import 'package:daisy/core/mixin/image_picker_mixin.dart';
import 'package:daisy/feature/home/cubit/tag_cubit.dart';
import 'package:daisy/feature/home/model/tag_model.dart';
import 'package:daisy/localization/locale_keys/locale_keys.g.dart';
import 'package:daisy/ui/modal/show.dart';
import 'package:daisy/ui/widget/button/button.dart';
import 'package:daisy/ui/widget/gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../mixin/home_mixin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with HomeMixin, ImagePickerMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.common_home.t),
      ),
      body: BlocBuilder<TagCubit, TagState>(
        builder: (context, state) {
          return Column(
            children: [
              Flexible(
                child: ListView(
                  children: [
                    Text(
                      'Current Tag: ${state.currentTag?.id ?? 'No Id'} - '
                      '${state.currentTag?.name ?? 'No Name'}',
                    ),
                    TextField(controller: cTag),
                    const Gap.xs(),
                    Button.elevated(
                      onPressed: addTag,
                      label: 'Add Tag',
                    ),
                    const Gap.xs(),
                    Button.elevated(
                      onPressed: () => onTapGallery(context),
                      label: 'Pick Image',
                    ),
                    const Gap.xs(),
                    if (image != null) ...[
                      Image.file(image!),
                      const Gap.xs(),
                    ],
                    Button.elevated(
                      onPressed: uploadImage,
                      label: 'Upload Image',
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: state.tagList.length,
                  itemBuilder: (context, index) {
                    final tag = state.tagList[index];
                    return ListTile(
                      title: Text(tag.name ?? 'No Name'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Show.modal<void>(
                                context,
                                SizedBox(
                                  height: 200,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        TextField(
                                          controller: cTag..text = tag.name!,
                                        ),
                                        const Gap.lg(),
                                        Button.elevated(
                                          onPressed: () => updateTag(tag.id!),
                                          label: 'Update Tag',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteTag(tag.id!),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    init();
  }
}
