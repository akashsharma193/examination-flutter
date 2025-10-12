import 'package:crackitx/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/core/constants/textstyles_constants.dart';
import 'package:crackitx/core/extensions/app_string_extensions.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/screens/admin_screen/admin_exam_dashboard.dart';
import 'package:crackitx/screens/student_exam_history.dart';
import 'package:crackitx/screens/ranking_screen.dart';
import 'package:feather_icons/feather_icons.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Map<String, IconData> drawerItems = {};
  late HomeController homeController;

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomeController>();

    if (!AppLocalStorage.instance.user.isAdmin) {
      drawerItems['Exam History'] = FeatherIcons.clock;
      drawerItems['Ranking'] = FeatherIcons.award;
      drawerItems['Feedback'] = FeatherIcons.messageSquare;
    }
    if (AppLocalStorage.instance.user.isAdmin) {
      drawerItems['Create Exam'] = FeatherIcons.plus;
    }
    drawerItems.addAll({
      'Log Out': FeatherIcons.logOut,
    });
  }

  void _showLogoutConfirmationDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                FeatherIcons.logOut,
                size: 48,
                color: Color(0xFF5038ED),
              ),
              const SizedBox(height: 16),
              const Text(
                'Logout Confirmation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Color(0xFF5038ED)),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF5038ED),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        final homeController = Get.find<HomeController>();
                        homeController.logOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5038ED),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();
    final RxBool isSubmitting = false.obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    FeatherIcons.messageSquare,
                    size: 28,
                    color: Color(0xFF5038ED),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Submit Feedback',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'We value your feedback! Please share your thoughts with us.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter your feedback here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF5038ED), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                        Future.delayed(const Duration(milliseconds: 300), () {
                          feedbackController.dispose();
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Color(0xFF5038ED)),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF5038ED),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: isSubmitting.value
                              ? null
                              : () async {
                                  if (feedbackController.text.trim().isEmpty) {
                                    Get.snackbar(
                                      'Error',
                                      'Please enter your feedback',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  isSubmitting.value = true;
                                  final success =
                                      await homeController.submitFeedback(
                                    feedbackController.text.trim(),
                                  );
                                  isSubmitting.value = false;

                                  if (success) {
                                    Get.back();
                                    Future.delayed(
                                        const Duration(milliseconds: 300), () {
                                      feedbackController.dispose();
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5038ED),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isSubmitting.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        feedbackController.dispose();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AppLocalStorage.instance.user;
    return GetBuilder<HomeController>(builder: (controller) {
      return Drawer(
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(160),
                  ),
                  child: Image.asset(
                    'assets/cropped_wavy_bg.png',
                    height: 240,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Obx(() {
                      final userProfile = controller.userProfile.value;
                      final displayName =
                          !userProfile.isEmpty && userProfile.name.isNotEmpty
                              ? userProfile.name
                              : user.name;

                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: Text(
                          displayName.getInitials,
                          style: AppTextStyles.heading.copyWith(
                            color: Colors.deepPurple,
                            fontSize: 36,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
              child: Obx(() {
                final userProfile = controller.userProfile.value;
                final displayEmail =
                    !userProfile.isEmpty && userProfile.email.isNotEmpty
                        ? userProfile.email
                        : user.email;
                final displayName =
                    !userProfile.isEmpty && userProfile.name.isNotEmpty
                        ? userProfile.name
                        : user.name;
                final displayBatch =
                    !userProfile.isEmpty && userProfile.batch.isNotEmpty
                        ? userProfile.batch
                        : user.batch;
                final displayOrgCode =
                    !userProfile.isEmpty && userProfile.orgCode.isNotEmpty
                        ? userProfile.orgCode
                        : user.orgCode;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email : $displayEmail',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Name : $displayName',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    if (displayBatch.trim().isNotEmpty)
                      Text('Batch : $displayBatch',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Organization : $displayOrgCode',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                );
              }),
            ),
            const SizedBox(height: 8),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: drawerItems.entries.map((entry) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(entry.key, style: AppTextStyles.body),
                        trailing: Icon(entry.value, color: Colors.black87),
                        onTap: () {
                          Get.back();
                          switch (entry.key) {
                            case 'Exam History':
                              Get.to(() => StudentExamHistory(
                                    userId: user.userId,
                                  ));
                              break;
                            case 'Ranking':
                              Get.to(() => const RankingScreen());
                              break;
                            case 'Feedback':
                              _showFeedbackDialog();
                              break;
                            case 'Log Out':
                              _showLogoutConfirmationDialog();
                              break;
                            case 'Create Exam':
                              Get.to(() => const AdminExamDashboard());
                              break;
                          }
                        },
                      ),
                      const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }
}
