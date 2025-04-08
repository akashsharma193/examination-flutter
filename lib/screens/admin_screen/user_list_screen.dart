import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/controllers/user_list_controller.dart';
import 'package:offline_test_app/core/constants/app_route_name_constants.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/screens/exam_history_screen.dart';
import 'package:offline_test_app/widgets/custom_dropdown_widget.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final controller = Get.put(UserListController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserListController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(color: AppColors.error),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Check screen width to determine layout
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    _buildSearchAndFilterBar(controller),
                    const SizedBox(height: 10),
                    Expanded(
                        child: Obx(() => _buildMobileUserList(controller))),
                  ],
                );
              } else {
                // Web layout
                return Column(
                  children: [
                    _buildSearchAndFilterBar(controller),
                    const SizedBox(height: 10),
                    Expanded(child: Obx(() => _buildWebUserList(controller))),
                  ],
                );
              }
            },
          ),
        );
      },
    );
  }

  // Mobile Layout
  Widget _buildMobileUserList(UserListController controller) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: List.generate(
            controller.filteredUsers.length,
            (index) {
              final user = controller.filteredUsers[index];
              return Card(
                color: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        user.isAdmin ? AppColors.success : AppColors.secondary,
                    child: Icon(
                      user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color:
                          user.isAdmin ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email: ${user.email}',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      if (user.batch != null && user.batch!.isNotEmpty)
                        Text(
                          'Batch: ${user.batch}',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                    ],
                  ),
                  trailing: Icon(Icons.edit, color: AppColors.textPrimary),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Web Layout
  Widget _buildWebUserList(UserListController controller) {
    return SingleChildScrollView(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400, // Maximum card width
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.8, // Card aspect ratio
        ),
        itemCount: controller.filteredUsers.length,
        itemBuilder: (context, index) {
          final user = controller.filteredUsers[index];
          return InkWell(
            onTap: () {
              Get.to(() => PastExamScreen(
                    userId: user.userId,
                  ));
            },
            child: Card(
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: user.isAdmin
                              ? AppColors.success
                              : AppColors.secondary,
                          child: Icon(
                            user.isAdmin
                                ? Icons.admin_panel_settings
                                : Icons.person,
                            color: user.isAdmin
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          user.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: ${user.email}',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    if (user.batch != null && user.batch!.isNotEmpty)
                      Text(
                        'Batch: ${user.batch}',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    // const Spacer(),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                          onPressed: () {
                            Get.toNamed(AppRoutesNames.editUserScreen,
                                arguments: {"user": user});
                          },
                          icon: Icon(Icons.edit, color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilterBar(UserListController controller) {
    final textController = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 🔍 Search bar
            Expanded(
              flex: 3,
              child: TextField(
                controller: textController,
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 🔎 Batch Filter
            Expanded(
                flex: 2,
                child: MyDropdownMenuStateful(
                    batches: controller.batches,
                    onSelect: (s) => controller.selectedBatch.value = s ?? '')),
            const SizedBox(width: 10),

            // 🏢 Organization Filter
            // Expanded(
            //   flex: 2,
            //   child: Obx(() {
            //     return DropdownButtonFormField<String>(
            //       value: controller.selectedOrganization.value.isEmpty
            //           ? null
            //           : controller.selectedOrganization.value,
            //       onChanged: (value) =>
            //           controller.selectedOrganization.value = value ?? '',
            //       decoration: InputDecoration(
            //         hintText: 'Organization',
            //         border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(10)),
            //         contentPadding: const EdgeInsets.symmetric(
            //             horizontal: 16, vertical: 12),
            //       ),
            //       items: controller.organizationCodes
            //           .map((org) =>
            //               DropdownMenuItem(value: org, child: Text(org)))
            //           .toList(),
            //     );
            //   }),
            // ),

            const SizedBox(width: 10),

            // ❌ Clear Filters
            ElevatedButton.icon(
              onPressed: () {
                controller.searchQuery.value = '';
                controller.selectedBatch.value = '';
                controller.selectedOrganization.value = '';
                textController.clear();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
