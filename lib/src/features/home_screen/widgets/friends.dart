import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_tap_bar.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class Friends extends StatelessWidget {
  final ValueNotifier<int> selectedTabIndex;

  const Friends({super.key, required this.selectedTabIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(
        title: 'Friends',
        leftText: 'Add',
        rightText: 'Manage',
        onPressedLeft: () {},
        onPressedRight: () {},
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: selectedTabIndex,
        builder: (context, value, child) {
          return AppTapBar(
            tabCount: 3,
            selectedIndex: value,
            tabTitles: ['Chats', 'Friends', 'Settings'],
            tabIcons: [AppIcons.chat, AppIcons.profile, AppIcons.settings],
            onTabSelected: (value) {
              selectedTabIndex.value = value;
            },
          );
        },
      ),
      body: Center(
        child: Text(
          'Home Screen - Friends Tab',
          style: TextStyle(
            fontSize: h4Size,
            fontWeight: h4Weight,
            color: DarkColor.darkest.color,
          ),
        ),
      ),
    );
  }
}
