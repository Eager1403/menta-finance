import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/theme_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/page_header.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final storage = controller.storage;

    return AppShell(
      title: 'Settings',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(title: 'Settings', subtitle: 'Mipangilio ya akaunti yako na mfumo.'),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Taarifa za Akaunti',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Jina', storage.fullName),
                  _infoRow('Email', storage.email),
                  _infoRow('Role', storage.role),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Muonekano (Appearance)',
              child: Obx(() => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Badilisha kati ya muonekano mweusi na mweupe.'),
                    value: themeCtrl.isDark,
                    onChanged: (_) => themeCtrl.toggle(),
                  )),
            ),
            if (storage.isSuperAdmin) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Usimamizi wa Mfumo',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kama SUPERADMIN, unaweza kusimamia akaunti za watumiaji wa mfumo.',
                        style: TextStyle(color: Colors.grey, fontSize: 12.5)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.users),
                      icon: const Icon(Icons.people_alt_outlined, size: 18),
                      label: const Text('Fungua Usimamizi wa Watumiaji'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Session',
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Toka (Logout)'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Text(value.isEmpty ? '-' : value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
