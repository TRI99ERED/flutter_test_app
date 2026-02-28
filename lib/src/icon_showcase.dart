import 'package:flutter/material.dart';
import 'app_icons.dart';

class IconShowcase extends StatelessWidget {
  const IconShowcase({super.key});

  static final List<Map<String, dynamic>> _icons = [
    {'name': 'add', 'icon': AppIcons.add},
    {'name': 'apple', 'icon': AppIcons.apple},
    {'name': 'arrow_down', 'icon': AppIcons.arrowDown},
    {'name': 'arrow_left', 'icon': AppIcons.arrowLeft},
    {'name': 'arrow_right', 'icon': AppIcons.arrowRight},
    {'name': 'arrow_up', 'icon': AppIcons.arrowUp},
    {'name': 'camera', 'icon': AppIcons.camera},
    {'name': 'categories', 'icon': AppIcons.categories},
    {'name': 'chat', 'icon': AppIcons.chat},
    {'name': 'check', 'icon': AppIcons.check},
    {'name': 'close', 'icon': AppIcons.close},
    {'name': 'create', 'icon': AppIcons.create},
    {'name': 'delete', 'icon': AppIcons.delete},
    {'name': 'edit', 'icon': AppIcons.edit},
    {'name': 'energy', 'icon': AppIcons.energy},
    {'name': 'explore', 'icon': AppIcons.explore},
    {'name': 'eye_invisible', 'icon': AppIcons.eyeInvisible},
    {'name': 'eye_visible', 'icon': AppIcons.eyeVisible},
    {'name': 'facebook', 'icon': AppIcons.facebook},
    {'name': 'filter', 'icon': AppIcons.filter},
    {'name': 'google', 'icon': AppIcons.google},
    {'name': 'hamburger', 'icon': AppIcons.hamburger},
    {'name': 'heart_filled', 'icon': AppIcons.heartFilled},
    {'name': 'heart_outlined', 'icon': AppIcons.heartOutlined},
    {'name': 'image', 'icon': AppIcons.image},
    {'name': 'inbox', 'icon': AppIcons.inbox},
    {'name': 'info', 'icon': AppIcons.info},
    {'name': 'linked_in', 'icon': AppIcons.linkedIn},
    {'name': 'minus', 'icon': AppIcons.minus},
    {'name': 'play', 'icon': AppIcons.play},
    {'name': 'profile', 'icon': AppIcons.profile},
    {'name': 'record', 'icon': AppIcons.record},
    {'name': 'search', 'icon': AppIcons.search},
    {'name': 'send', 'icon': AppIcons.send},
    {'name': 'settings', 'icon': AppIcons.settings},
    {'name': 'shopping_bag_filled', 'icon': AppIcons.shoppingBagFilled},
    {'name': 'shopping_bag_outlined', 'icon': AppIcons.shoppingBagOutlined},
    {'name': 'sort', 'icon': AppIcons.sort},
    {'name': 'star_filled', 'icon': AppIcons.starFilled},
    {'name': 'star_outlined', 'icon': AppIcons.starOutlined},
    {'name': 'store', 'icon': AppIcons.store},
    {'name': 'success', 'icon': AppIcons.success},
    {'name': 'warning', 'icon': AppIcons.warning},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Icons Showcase'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _icons.length,
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          final iconData = _icons[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: ListTile(
              leading: Icon(iconData['icon'] as IconData, size: 32.0),
              title: Text(
                iconData['name'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                ),
              ),
              trailing: Text(
                '0x${(iconData['icon'] as IconData).codePoint.toRadixString(16).toUpperCase()}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12.0,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
