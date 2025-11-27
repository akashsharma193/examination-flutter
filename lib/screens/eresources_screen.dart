import 'package:crackitx/controllers/eresouces_controller.dart';
import 'package:crackitx/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/core/constants/textstyles_constants.dart';
import 'package:feather_icons/feather_icons.dart';

class EResourcesScreen extends StatelessWidget {
  const EResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EResourcesController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Resources', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF5038ED),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => controller.searchResources(value),
              decoration: InputDecoration(
                hintText: 'Search resources...',
                prefixIcon:
                    const Icon(FeatherIcons.search, color: Color(0xFF5038ED)),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => controller.clearSearch(),
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF5038ED), width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF5038ED)),
                  ),
                );
              }

              if (controller.filteredResources.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FeatherIcons.fileText,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'No Resources Found'
                            : 'No Resources Available',
                        style: AppTextStyles.heading.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'Try searching with different keywords'
                            : 'No resources are currently available',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.getResources(),
                color: const Color(0xFF5038ED),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredResources.length +
                      (controller.hasNextPage &&
                              controller.searchQuery.value.isEmpty
                          ? 1
                          : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.filteredResources.length) {
                      if (controller.isLoadingMore.value) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF5038ED)),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final resource = controller.filteredResources[index];
                    final hasFile = resource.fileName != null &&
                        resource.fileName!.isNotEmpty;
                    final hasUrl =
                        resource.url != null && resource.url!.isNotEmpty;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          if (hasFile && hasUrl) {
                            _showResourceOptionsDialog(
                                context, controller, resource);
                          } else if (hasFile) {
                            controller.downloadResource(resource.id);
                          } else if (hasUrl) {
                            controller.openUrl(resource.url!);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5038ED)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      hasFile
                                          ? FeatherIcons.file
                                          : FeatherIcons.link,
                                      color: const Color(0xFF5038ED),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          resource.name ?? '-',
                                          style: AppTextStyles.heading.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (hasFile)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      FeatherIcons.file,
                                                      size: 12,
                                                      color:
                                                          Colors.green.shade700,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'File',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .green.shade700,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (hasFile && hasUrl)
                                              const SizedBox(width: 8),
                                            if (hasUrl)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      FeatherIcons.link,
                                                      size: 12,
                                                      color:
                                                          Colors.blue.shade700,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'URL',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .blue.shade700,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (resource.description != null &&
                                  resource.description!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  resource.description!,
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoChip(
                                      icon: FeatherIcons.bookmark,
                                      label: resource.topic ?? '-',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildInfoChip(
                                      icon: FeatherIcons.users,
                                      label: resource.batch ?? '-',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: AppTheme.gradientStart,
        heroTag: "refresh",
        onPressed: controller.getResources,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showResourceOptionsDialog(
    BuildContext context,
    EResourcesController controller,
    dynamic resource,
  ) {
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
                FeatherIcons.fileText,
                size: 48,
                color: Color(0xFF5038ED),
              ),
              const SizedBox(height: 16),
              Text(
                resource.name ?? 'Resource',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose how to access this resource',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  controller.downloadResource(resource.id);
                },
                icon: const Icon(FeatherIcons.download, size: 20),
                label: const Text('Download File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5038ED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  controller.openUrl(resource.url!);
                },
                icon: const Icon(FeatherIcons.externalLink, size: 20),
                label: const Text('Open URL'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5038ED),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Color(0xFF5038ED)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
