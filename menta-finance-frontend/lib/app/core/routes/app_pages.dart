import 'package:get/get.dart';

import '../../modules/auth/bindings/login_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/clients/bindings/client_detail_binding.dart';
import '../../modules/clients/bindings/client_list_binding.dart';
import '../../modules/clients/views/client_detail_view.dart';
import '../../modules/clients/views/client_list_view.dart';
import '../../modules/dashboard/bindings/dashboard_binding.dart';
import '../../modules/dashboard/views/dashboard_view.dart';
import '../../modules/expenses/bindings/expenses_binding.dart';
import '../../modules/expenses/views/expenses_view.dart';
import '../../modules/income/bindings/income_binding.dart';
import '../../modules/income/views/income_view.dart';
import '../../modules/invoices/bindings/invoice_binding.dart';
import '../../modules/invoices/views/invoice_list_view.dart';
import '../../modules/projects/bindings/project_detail_binding.dart';
import '../../modules/projects/bindings/project_list_binding.dart';
import '../../modules/projects/views/project_detail_view.dart';
import '../../modules/projects/views/project_list_view.dart';
import '../../modules/reports/bindings/reports_binding.dart';
import '../../modules/reports/views/reports_view.dart';
import '../../modules/services/bindings/services_binding.dart';
import '../../modules/services/views/services_view.dart';
import '../../modules/settings/bindings/settings_binding.dart';
import '../../modules/settings/views/settings_view.dart';
import '../../modules/team/bindings/team_binding.dart';
import '../../modules/team/views/team_view.dart';
import '../../modules/users/bindings/users_binding.dart';
import '../../modules/users/views/users_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(name: AppRoutes.login, page: () => const LoginView(), binding: LoginBinding()),
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardView(), binding: DashboardBinding()),

    GetPage(name: AppRoutes.clients, page: () => const ClientListView(), binding: ClientListBinding()),
    GetPage(name: AppRoutes.clientDetail, page: () => const ClientDetailView(), binding: ClientDetailBinding()),

    GetPage(name: AppRoutes.projects, page: () => const ProjectListView(), binding: ProjectListBinding()),
    GetPage(name: AppRoutes.projectDetail, page: () => const ProjectDetailView(), binding: ProjectDetailBinding()),

    GetPage(name: AppRoutes.invoices, page: () => const InvoiceListView(), binding: InvoiceBinding()),

    GetPage(name: AppRoutes.income, page: () => const IncomeView(), binding: IncomeBinding()),
    GetPage(name: AppRoutes.expenses, page: () => const ExpensesView(), binding: ExpensesBinding()),

    GetPage(name: AppRoutes.services, page: () => const ServicesView(), binding: ServicesBinding()),
    GetPage(name: AppRoutes.team, page: () => const TeamView(), binding: TeamBinding()),
    GetPage(name: AppRoutes.reports, page: () => const ReportsView(), binding: ReportsBinding()),

    GetPage(name: AppRoutes.users, page: () => const UsersView(), binding: UsersBinding()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsView(), binding: SettingsBinding()),
  ];
}
