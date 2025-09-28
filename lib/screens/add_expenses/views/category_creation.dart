import 'package:finflow/screens/add_expenses/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../expense_repository.dart';

Future getCategoryCreation(BuildContext context) {
  List<String> myCategoryIcons = [
    'bills',
    'food',
    'miscelaneous',
    'shopping',
    'study',
    'travel',
    'bills2',
    'food2',
    'friend',
    'health',
    'health_2',
    'hidden',
    'home',
    'internet',
    'love',
    'photo',
    'renewal',
    'rent',
    'shopping_2',
    'study2',
    'tech',
    'tech_2',
    'user',
    'utility'
  ];

  return showDialog(
    context: context,
    builder: (ctx) {
      bool isExpanded = false;
      String selectedIcon = '';
      Color categoryColor = Colors.white;
      TextEditingController categoryNameController = TextEditingController();
      TextEditingController categoryIconController = TextEditingController();
      TextEditingController categoryColorController = TextEditingController();
      bool isLoading = false;
      Category category = Category.empty;

      return BlocProvider.value(
        value: context.read<CreateCategoryBloc>(),
        child: StatefulBuilder(
          builder: (ctx, setState) {
            return BlocListener<CreateCategoryBloc, CreateCategoryState>(
              listener: (context, state) {
                if (state is CreateCategorySuccess) {
                  Navigator.pop(ctx , category);
                } else if (state is CreateCategoryLoading) {
                  setState(() => isLoading = true);
                }
              },
              child: AlertDialog(
                backgroundColor: const Color.fromARGB(255, 175, 218, 223),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Create a Category',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Category Name Input
                      TextFormField(
                        controller: categoryNameController,
                        decoration: InputDecoration(
                          label: const Text('Name', style: TextStyle(color: Colors.black)),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(
                            FontAwesomeIcons.cat,
                            size: 20,
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Icon Selection Field
                      StatefulBuilder(
                        builder: (context, setStateIcon) {
                          return Column(
                            children: [
                              TextFormField(
                                controller: categoryIconController,
                                readOnly: true,
                                onTap: () => setStateIcon(() => isExpanded = !isExpanded),
                                decoration: InputDecoration(
                                  hintText: 'Icon',
                                  hintStyle: const TextStyle(color: Colors.black),
                                  suffixIcon: const Icon(FontAwesomeIcons.chevronDown),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: selectedIcon.isNotEmpty
                                      ? Image.asset(
                                          'assets/icons/$selectedIcon.png',
                                          width: 24,
                                          height: 24,
                                        )
                                      : const Icon(
                                          FontAwesomeIcons.icons,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: isExpanded
                                        ? const BorderRadius.vertical(top: Radius.circular(12))
                                        : BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: isExpanded ? 200 : 0,
                                width: MediaQuery.of(context).size.width,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                ),
                                child: isExpanded
                                    ? GridView.builder(
                                        padding: const EdgeInsets.all(8),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                        ),
                                        itemCount: myCategoryIcons.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () => setStateIcon(() {
                                              selectedIcon = myCategoryIcons[index];
                                              isExpanded = false;
                                            }),
                                            child: Image.asset(
                                              'assets/icons/${myCategoryIcons[index]}.png',
                                              width: 32,
                                              height: 32,
                                            ),
                                          );
                                        },
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Color Picker Field
                      StatefulBuilder(
                        builder: (context, setState) {
                          return TextFormField(
                            controller: categoryColorController,
                            readOnly: true,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx2) {
                                  return AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ColorPicker(
                                          pickerColor: categoryColor,
                                          onColorChanged: (value) {
                                            setState(() => categoryColor = value);
                                          },
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () => Navigator.pop(ctx2),
                                            child: const Text(
                                              'Ok',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            decoration: InputDecoration(
                              hintText: "Color",
                              hintStyle: const TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: categoryColor,
                              prefixIcon: const Icon(
                                FontAwesomeIcons.paintbrush,
                                size: 20,
                                color: Colors.black,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Save Category Button
                      SizedBox(
                        width: double.infinity,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  if (categoryNameController.text.isNotEmpty && selectedIcon.isNotEmpty) {
                                    setState(() {                                   
                                      category.categoryId = const Uuid().v1();
                                      category.name = categoryNameController.text;
                                      category.icon = selectedIcon;
                                      category.color = categoryColor.value;                                  
                                    });
                                    context.read<CreateCategoryBloc>().add(CreateCategory(category));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please fill both icon and name fields properly'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },

                                child: const Text(
                                  'Save Color',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
