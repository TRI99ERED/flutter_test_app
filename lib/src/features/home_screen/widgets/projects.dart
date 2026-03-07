import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';

class Projects extends StatelessWidget {
  final ValueNotifier<bool> editPressed;

  const Projects({super.key, required this.editPressed});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Projects coming soon!'));
  }
}

class ProjectsAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueNotifier<bool> editPressed;

  const ProjectsAppBar({super.key, required this.editPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ProjectsAppBar> createState() => _ProjectsAppBarState();
}

class _ProjectsAppBarState extends State<ProjectsAppBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: widget.editPressed,
        builder: (context, value, child) {
          return AppNavBar(
            title: 'Projects',
            leftText: widget.editPressed.value ? 'Done' : 'Edit',
            rightIcon: AppIcons.search,
            onPressedLeft: () {
              widget.editPressed.value = !widget.editPressed.value;
            },
            onPressedRight: () {},
          );
        },
      ),
    );
  }
}
