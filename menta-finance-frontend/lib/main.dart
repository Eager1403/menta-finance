import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/config/app_config.dart';
import 'app/core/controllers/theme_controller.dart';
import 'app/core/network/api_client.dart';
import 'app/core/routes/app_pages.dart';
import 'app/core/routes/app_routes.dart';
import 'app/core/storage/storage_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/translations/app_translations.dart';

/// KWA NINI HII IPO: Kwa default, Flutter (release mode) ikikutana na
/// hitilafu wakati wa "build" ya widget yoyote, inaficha ujumbe wa hitilafu
/// na kuonyesha BOX TUPU YA KIJIVU tu. Override hii inahakikisha tunaona
/// UJUMBE HALISI wa tatizo (kwa maandishi mekundu, si kijivu tupu), ili iwe
/// rahisi kutambua na kurekebisha haraka - badala ya kukisia.
void _installFriendlyErrorWidget() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFFDECEA),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 18),
              SizedBox(width: 8),
              Text(
                'Sehemu hii imeshindwa kuonyesha (hitilafu ya UI)',
                style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            details.exceptionAsString(),
            style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 11.5),
          ),
        ],
      ),
    );
  };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installFriendlyErrorWidget();

  // 1) Local storage (GetStorage) - lazima i-init kabla ya kuitumia
  await StorageService.init();
  final storageService = StorageService();

  // 2) Dependency Injection ya jumla (GetX) - vitu vinavyotumika app nzima.
  // Moduli nyingine (Clients, Projects, Invoices, n.k.) zinaingiza Services
  // zao wenyewe kupitia Bindings za kila route (angalia app_pages.dart) -
  // hapa tunaweka TU vitu vya msingi vinavyohitajika KILA MAHALI.
  Get.put<StorageService>(storageService, permanent: true);
  final apiClient = ApiClient(storage: storageService);
  Get.put<ApiClient>(apiClient, permanent: true);

  // Token ikiisha muda (401), safisha session na mrudishe mtumiaji Login
  // popote alipo kwenye app.
  apiClient.onUnauthorized = () {
    storageService.clearSession();
    if (Get.currentRoute != AppRoutes.login) {
      Get.offAllNamed(AppRoutes.login);
    }
  };

  final themeController = Get.put<ThemeController>(ThemeController(storageService), permanent: true);

  runApp(MentaFinanceApp(themeController: themeController));
}

class MentaFinanceApp extends StatelessWidget {
  final ThemeController themeController;
  const MentaFinanceApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();

    return Obx(() => GetMaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.themeMode.value,
          translations: AppTranslations(),
          locale: const Locale('sw', 'TZ'),
          fallbackLocale: const Locale('sw', 'TZ'),
          initialRoute: storage.isLoggedIn ? AppRoutes.dashboard : AppRoutes.login,
          getPages: AppPages.routes,
          // Admin Panel ni web dashboard - kubadilisha ukurasa kunapaswa
          // kuwa PAPO HAPO (kama Gmail/Notion), siyo "kuanimishwa".
          defaultTransition: Transition.noTransition,
          transitionDuration: Duration.zero,
        ));
  }
}
