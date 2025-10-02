import 'package:flutter/material.dart';

class Controller extends ChangeNotifier {
  final GlobalKey<ScaffoldState> dashboardKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> recordsKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> parentKey = GlobalKey<ScaffoldState>();

  void controlMenu() {
    if (dashboardKey.currentState != null &&
        !dashboardKey.currentState!.isDrawerOpen) {
      dashboardKey.currentState!.openDrawer();
    }
    if (recordsKey.currentState != null &&
        !recordsKey.currentState!.isDrawerOpen) {
      recordsKey.currentState!.openDrawer();
    }
    if (parentKey.currentState != null &&
        !parentKey.currentState!.isDrawerOpen) {
      parentKey.currentState!.openDrawer();
    }
  }
}
