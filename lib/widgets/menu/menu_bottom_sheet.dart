import 'package:flutter/material.dart';

typedef MenuActionCallback = void Function();

class MenuBottomSheet extends StatelessWidget {
  final List<Widget> menuItems;

  const MenuBottomSheet({super.key, required this.menuItems});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: menuItems,
        ),
      ),
    );
  }
}

Future<T?> showMenuBottomSheet<T>({
  required BuildContext context,
  required List<Widget> menuItems,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: true,
    builder: (ctx) => MenuBottomSheet(menuItems: menuItems),
  );
}