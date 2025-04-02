import 'package:get/get.dart';
import 'package:flutter_ssh_client/app/modules/home/bindings/home_binding.dart';
import 'package:flutter_ssh_client/app/modules/home/views/home_view.dart';
import 'package:flutter_ssh_client/app/modules/terminal/bindings/terminal_binding.dart';
import 'package:flutter_ssh_client/app/modules/terminal/views/terminal_view.dart';
import 'package:flutter_ssh_client/app/modules/sftp/bindings/sftp_binding.dart';
import 'package:flutter_ssh_client/app/modules/sftp/views/sftp_view.dart';
import 'package:flutter_ssh_client/app/modules/settings/bindings/settings_binding.dart';
import 'package:flutter_ssh_client/app/modules/settings/views/settings_view.dart';
import 'package:flutter_ssh_client/app/routes/app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.TERMINAL,
      page: () => const TerminalView(),
      binding: TerminalBinding(),
    ),
    GetPage(
      name: Routes.SFTP,
      page: () => const SftpView(),
      binding: SftpBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
} 