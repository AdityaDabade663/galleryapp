import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'tabs/upload_tab_view.dart';
import 'tabs/images_tab_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => IndexedStack(
          index: controller.currentTabIndex.value,
          children: const [
            UploadTabView(),
            ImagesTabView(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() {
      final currentIndex = controller.currentTabIndex.value;
      const activeColor = Color(0xFF16A34A);
      const inactiveColor = Color(0xFF374151);

      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                // Tab 1: Upload
                Expanded(
                  child: InkWell(
                    onTap: () => controller.changeTabIndex(0),
                    splashColor: activeColor.withValues(alpha: 0.1),
                    highlightColor: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_rounded,
                          size: 26,
                          color: currentIndex == 0 ? activeColor : inactiveColor,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Upload',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: currentIndex == 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: currentIndex == 0
                                ? activeColor
                                : inactiveColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab 2: Images
                Expanded(
                  child: InkWell(
                    onTap: () => controller.changeTabIndex(1),
                    splashColor: activeColor.withValues(alpha: 0.1),
                    highlightColor: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_circle,
                          size: 26,
                          color: currentIndex == 1 ? activeColor : inactiveColor,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Images',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: currentIndex == 1
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: currentIndex == 1
                                ? activeColor
                                : inactiveColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
