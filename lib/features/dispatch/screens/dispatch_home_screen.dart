import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stylemake/core/router/app_router.dart';

/// Dispatch module home screen
class DispatchHomeScreen extends StatelessWidget {
  const DispatchHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to dispatches list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(AppRouter.dispatchesList);
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
