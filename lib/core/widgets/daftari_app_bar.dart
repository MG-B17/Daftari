import 'package:flutter/material.dart';

/// The only app bar used in the app (agent.md Section 8).
///
/// All styling comes from the app theme; no custom colors or styles here.
class DaftariAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DaftariAppBar({required this.title, this.actions, super.key});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), actions: actions);
  }
}
