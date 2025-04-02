import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_ssh_client/app/routes/app_pages.dart';
import 'package:flutter_ssh_client/app/core/theme/app_theme.dart';
import 'package:flutter_ssh_client/app/core/utils/logger.dart';
import 'package:flutter_ssh_client/app/core/services/init_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggerUtil.init();
  
  // 初始化服务
  await InitServices.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter SSH Client',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
    );
  }
}
