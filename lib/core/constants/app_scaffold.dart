import 'package:flutter/material.dart';

import '../theme/AppliColors.dart';


class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool hasBackButton;

  const AppScaffold({
    Key? key,
    required this.body,
    required this.title,
    this.actions,
    this.bottomNavigationBar,
    this.hasBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: hasBackButton
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        )
            : null,
        actions: actions,
      ),
      body: SafeArea(
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}