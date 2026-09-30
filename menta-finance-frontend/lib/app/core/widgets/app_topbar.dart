import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../storage/storage_service.dart';
import '../theme/app_colors.dart';

class AppTopbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenu;

  const AppTopbar({super.key, required this.title, required this.onMenu});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  String _roleLabel(String role) {
    switch (role) {
      case 'SUPERADMIN':
        return 'Super Admin';
      case 'MANAGER':
        return 'Manager';
      case 'STAFF':
        return 'Staff';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final fullName = storage.fullName;
    final role = storage.role;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: const Border(bottom: BorderSide(color: AppColors.topbarBorder)),
      ),
      child: Row(
        children: [
          IconButton(onPressed: onMenu, icon: const Icon(Icons.menu_rounded)),
          const SizedBox(width: 4),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary)),
          const Spacer(),
          const CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.avatarBg,
            child: Icon(Icons.person, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 9),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fullName.isEmpty ? 'Mtumiaji' : fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              Text(_roleLabel(role), style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 6),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Get.toNamed(AppRoutes.settings);
              } else if (value == 'logout') {
                storage.clearSession();
                Get.offAllNamed(AppRoutes.login);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'logout', child: Text('Toka')),
            ],
          ),
        ],
      ),
    );
  }
}
