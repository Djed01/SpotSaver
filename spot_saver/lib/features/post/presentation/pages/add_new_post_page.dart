import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:spot_saver/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:spot_saver/core/common/widgets/loader.dart';
import 'package:spot_saver/core/theme/app_pallete.dart';
import 'package:spot_saver/core/utils/pick_image.dart';
import 'package:spot_saver/core/utils/show_snackbar.dart';
import 'package:spot_saver/features/post/presentation/bloc/post_bloc.dart';
import 'package:spot_saver/features/post/presentation/pages/posts_page.dart';
import 'package:spot_saver/features/post/presentation/widgets/post_category_widget.dart';
import 'package:spot_saver/features/post/presentation/widgets/post_editor.dart';
import 'package:spot_saver/features/location/presentation/widgets/location_input.dart';
import 'package:dotted_border/dotted_border.dart';

class AddNewPostPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const AddNewPostPage(),
      );
  const AddNewPostPage({super.key});

  @override
  State<AddNewPostPage> createState() => _AddNewPostPageState();
}

class _AddNewPostPageState extends State<AddNewPostPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  List<String> selectedCategories = [];
  File? image;
  double? latitude;
  double? longitude;

  void selectImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a photo'),
            onTap: () async {
              Navigator.of(context).pop();
              final pickedImage = await pickImage(ImageSource.camera);
              if (pickedImage != null) {
                setState(() {
                  image = pickedImage;
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () async {
              Navigator.of(context).pop();
              final pickedImage = await pickImage(ImageSource.gallery);
              if (pickedImage != null) {
                setState(() {
                  image = pickedImage;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void uploadPost() {
    if (formKey.currentState!.validate() &&
        selectedCategories.isNotEmpty &&
        image != null &&
        latitude != null &&
        longitude != null) {
      final posterId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
      context.read<PostBloc>().add(PostUpload(
            posterId: posterId,
            title: titleController.text.trim(),
            content: contentController.text.trim(),
            image: image!,
            categories: selectedCategories,
            latitude: latitude!,
            longitude: longitude!,
          ));
    } else {
      showSnackBar(context, "Please fill all fields correctly.");
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new post'),
        centerTitle: true,
        actions: [
          BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              return IconButton(
                onPressed: state is PostLoading ? null : uploadPost,
                icon: const Icon(Icons.done_rounded),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<PostBloc, PostState>(
        listener: (context, state) {
          if (state is PostFailure) {
            showSnackBar(context, state.error);
          } else if (state is PostUploadSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              PostsPage.route(),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is PostLoading) {
            return const Loader(); // Display the loader
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    image != null
                        ? GestureDetector(
                            onTap: selectImage,
                            child: SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    image!,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                          )
                        : GestureDetector(
                            onTap: selectImage,
                            child: DottedBorder(
                              color: AppPallete.borderColor,
                              dashPattern: const [10, 4],
                              radius: const Radius.circular(10),
                              borderType: BorderType.RRect,
                              strokeCap: StrokeCap.round,
                              child: const SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder_open,
                                      size: 40,
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      'Select your image',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                    PostCategoryWidget(
                      selectedCategories: selectedCategories,
                      onCategorySelected: (category) {
                        selectedCategories.add(category);
                        setState(() {});
                      },
                      onCategoryDeselected: (category) {
                        selectedCategories.remove(category);
                        setState(() {});
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    LocationInput(
                      onSelectLocation: (lat, lng) {
                        setState(() {
                          latitude = lat;
                          longitude = lng;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    PostEditor(
                        controller: titleController, hintText: 'Post title'),
                    const SizedBox(
                      height: 10,
                    ),
                    PostEditor(
                        controller: contentController,
                        hintText: 'Post content'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
