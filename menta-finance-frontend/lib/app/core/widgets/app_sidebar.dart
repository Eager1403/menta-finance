import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../storage/storage_service.dart';
import '../theme/app_colors.dart';

class _SidebarItem {
  final String label;
  final IconData icon;
  final String route;

  const _SidebarItem(this.label, this.icon, this.route);
}

/// SUPERADMIN anaona KILA KITU.
const _superAdminMenu = [
  _SidebarItem('Dashboard', Icons.dashboard_outlined, AppRoutes.dashboard),
  _SidebarItem('Clients', Icons.people_outline, AppRoutes.clients),
  _SidebarItem('Projects', Icons.work_outline, AppRoutes.projects),
  _SidebarItem('Invoices', Icons.receipt_long_outlined, AppRoutes.invoices),
  _SidebarItem('Income', Icons.trending_up, AppRoutes.income),
  _SidebarItem('Expenses', Icons.trending_down, AppRoutes.expenses),
  _SidebarItem('Services', Icons.design_services_outlined, AppRoutes.services),
  _SidebarItem('Team', Icons.groups_outlined, AppRoutes.team),
  _SidebarItem('Reports', Icons.bar_chart_outlined, AppRoutes.reports),
];

/// MANAGER anaona kila kitu ISIPOKUWA Reports (SUPERADMIN pekee -
/// angalia ReportController.hasRole('SUPERADMIN') upande wa backend).
const _managerMenu = [
  _SidebarItem('Dashboard', Icons.dashboard_outlined, AppRoutes.dashboard),
  _SidebarItem('Clients', Icons.people_outline, AppRoutes.clients),
  _SidebarItem('Projects', Icons.work_outline, AppRoutes.projects),
  _SidebarItem('Invoices', Icons.receipt_long_outlined, AppRoutes.invoices),
  _SidebarItem('Income', Icons.trending_up, AppRoutes.income),
  _SidebarItem('Expenses', Icons.trending_down, AppRoutes.expenses),
  _SidebarItem('Services', Icons.design_services_outlined, AppRoutes.services),
  _SidebarItem('Team', Icons.groups_outlined, AppRoutes.team),
];

/// STAFF: hana ruhusa ya kuona Income/Expenses (GET /project/{id} ni
/// SUPERADMIN/MANAGER pekee), wala Team (POST/GET ni SUPERADMIN/MANAGER
/// pekee) wala Reports - kwa hiyo vitu hivyo havionekani kwenye menu yake
/// (kuepuka "403 Forbidden" asiyoitegemea).
const _staffMenu = [
  _SidebarItem('Dashboard', Icons.dashboard_outlined, AppRoutes.dashboard),
  _SidebarItem('Clients', Icons.people_outline, AppRoutes.clients),
  _SidebarItem('Projects', Icons.work_outline, AppRoutes.projects),
  _SidebarItem('Invoices', Icons.receipt_long_outlined, AppRoutes.invoices),
  _SidebarItem('Services', Icons.design_services_outlined, AppRoutes.services),
];

class AppSidebar extends StatelessWidget {
  final bool collapsed;
  final bool mobile;
  const AppSidebar({super.key, this.collapsed = false, this.mobile = false});

  void _handleTap(_SidebarItem item) {
    if (mobile) Get.back(); // funga Drawer kwanza
    Get.offAllNamed(item.route);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;
    final showText = !collapsed || mobile;
    final storage = Get.find<StorageService>();
    final menu = storage.isSuperAdmin
        ? _superAdminMenu
        : storage.isManager
            ? _managerMenu
            : _staffMenu;

    return Material(
      color: AppColors.sidebarGreen,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/MENTA STUDIO-01 (1).png',
                      width: showText ? 150 : 48,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (showText) ...[
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Menta Finance',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                children: menu.map((item) {
                  final active = item.route == currentRoute;
                  return _LeafTile(
                    item: item,
                    active: active,
                    showText: showText,
                    collapsed: collapsed,
                    onTap: () => _handleTap(item),
                  );
                }).toList(),
              ),
            ),
            if (showText)
              const Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Menta Finance v1.0',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LeafTile extends StatelessWidget {
  final _SidebarItem item;
  final bool active;
  final bool showText;
  final bool collapsed;
  final VoidCallback onTap;

  const _LeafTile({
    required this.item,
    required this.active,
    required this.showText,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: collapsed ? item.label : '',
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.accentYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: active ? AppColors.activeNavText : Colors.white70,
                size: 19,
              ),
              if (showText) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: active ? AppColors.activeNavText : Colors.white,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
