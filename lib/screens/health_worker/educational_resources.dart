import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/auth_viewmodel.dart';
import 'package:immunicare/controllers/health_worker/educ_res_viewmodel.dart';
import 'package:immunicare/models/educ_res_model.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/drawer_menu.dart';
import 'package:provider/provider.dart';

class EducationalResources extends StatefulWidget {
  const EducationalResources({super.key});

  @override
  State<EducationalResources> createState() => _EducationalResourcesState();
}

class _EducationalResourcesState extends State<EducationalResources> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _contentController = TextEditingController();
  String? _docId;
  EducResViewmodel? educProv;
  AuthViewModel? authProv;
  String _selectedSortOption = 'title';

  void _showEducationalResourceDialog(
    BuildContext context,
    EducResViewmodel? viewmodel,
    bool isEditing,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(appPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditing ? 'Edit article' : 'Add new article',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Gap(appPadding),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.title),
                        prefixIconColor: primaryColor,
                      ),
                      validator:
                          (value) => value == null ? 'Required field' : null,
                    ),
                    Gap(appPadding),
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.category),
                        prefixIconColor: primaryColor,
                      ),
                      validator:
                          (value) => value == null ? 'Required field' : null,
                    ),
                    Gap(appPadding),
                    TextFormField(
                      maxLines: 5,
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator:
                          (value) => value == null ? 'Required field' : null,
                    ),
                    Gap(appPadding),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        if (_titleController.text.trim().isNotEmpty &&
                            _categoryController.text.trim().isNotEmpty &&
                            _contentController.text.trim().isNotEmpty) {
                          EducResModel data = EducResModel(
                            id: _docId,
                            title: _titleController.text.trim(),
                            category: _categoryController.text.trim(),
                            content: _contentController.text.trim(),
                          );

                          if (isEditing) {
                            viewmodel?.editArticle(data);
                          } else {
                            viewmodel?.uploadNewArticle(data);
                          }
                        }
                        _titleController.clear();
                        _categoryController.clear();
                        _contentController.clear();
                        Navigator.of(context).pop();
                      },
                      child:
                          isEditing
                              ? const Text(
                                'Save Article',
                                style: TextStyle(color: Colors.white),
                              )
                              : const Text(
                                'Add Article',
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _fullContent(EducResModel article) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: primaryColor),
            const Gap(16),
            Expanded(
              child: Text(
                article.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        const Gap(8),
        Text(
          article.category,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const Gap(8),
        Text(
          article.content,
          style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
      ],
    );
  }

  Widget _buildArticleCard(EducResModel article) {
    final authProv = Provider.of<AuthViewModel>(context, listen: false);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(250),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                content: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: _fullContent(article),
                ),
              );
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: primaryColor),
                      Gap(appPadding),
                      Expanded(
                        child: Text(
                          article.title,
                          style: const TextStyle(
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Text(
                    article.category,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Gap(8),
                  Text(
                    article.content,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
            if (authProv.role == 'health_worker' ||
                authProv.role == 'super_admin')
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _docId = article.id;
                        _titleController.text = article.title;
                        _categoryController.text = article.category;
                        _contentController.text = article.content;
                        _showEducationalResourceDialog(context, educProv, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[500],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child: Icon(Icons.edit),
                    ),
                    const Gap(8),
                    ElevatedButton(
                      onPressed: () {
                        _docId = article.id;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text('Confirm delete?'),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    educProv?.deleteArticle(_docId ?? '');
                                    Navigator.pop(context);
                                  },
                                  child: Text('Confirm'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[500],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child: Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(List<EducResModel> filteredArticles) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          filteredArticles
              .map((article) => _buildArticleCard(article))
              .toList(),
    );
  }

  Widget _buildDesktopLayout(List<EducResModel> filteredArticles) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children:
          filteredArticles
              .map(
                (article) =>
                    SizedBox(width: 250, child: _buildArticleCard(article)),
              )
              .toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    educProv = Provider.of<EducResViewmodel>(context, listen: false);
    authProv = Provider.of<AuthViewModel>(context, listen: false);
    educProv?.getAllArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EducResViewmodel>(
      builder:
          (context, value, child) => Scaffold(
            drawer: DrawerMenu(),
            body: Padding(
              padding: const EdgeInsets.all(appPadding),
              child: Row(
                children: [
                  if (Responsive.isDesktop(context))
                    Expanded(child: DrawerMenu()),
                  Expanded(
                    flex: 5,
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomAppbar(),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Educational Articles',
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('Sort by:'),
                                  Gap(8),
                                  DropdownButton<String>(
                                    focusColor: Colors.transparent,
                                    dropdownColor: Colors.white,
                                    value: _selectedSortOption,
                                    items: [
                                      DropdownMenuItem(
                                        value: 'title',
                                        child: Text('Title'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'category',
                                        child: Text('Category'),
                                      ),
                                    ],
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedSortOption = newValue;
                                          value.sortArticles(newValue);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (value.filteredArticles.isEmpty)
                            Expanded(
                              child: Center(
                                child: Text(
                                  'No articles found.',
                                  style: Theme.of(context).textTheme.labelLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          if (Responsive.isDesktop(context))
                            _buildDesktopLayout(value.filteredArticles),
                          if (Responsive.isMobile(context))
                            _buildMobileLayout(value.filteredArticles),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton:
                authProv?.role == 'super_admin'
                    ? FloatingActionButton(
                      shape: const CircleBorder(),
                      backgroundColor: primaryColor,
                      onPressed:
                          () => _showEducationalResourceDialog(
                            context,
                            value,
                            false,
                          ),
                      child: const Icon(Icons.add, color: Colors.white),
                    )
                    : null,
          ),
    );
  }
}
