import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stylemake/core/services/platform_service.dart';
import 'package:stylemake/core/router/app_router.dart';
import 'package:stylemake/core/widgets/app_shell.dart';
import 'package:stylemake/core/widgets/fluent/fluent_navigation_pane.dart';

// Uses bottomNavIndexProvider from app_shell.dart

/// Adaptive app shell that uses Fluent Design on desktop and Material 3 on mobile
class AdaptiveAppShell extends ConsumerWidget {
  const AdaptiveAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 840;

    if (isWide && PlatformService.shouldUseFluent) {
      return FluentAppShell(child: child);
    }

    return AppShell(child: child);
  }
}

/// Fluent Design System app shell for desktop
class FluentAppShell extends ConsumerWidget {
  const FluentAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Fluent background
      body: Row(
        children: [
          // Fluent Navigation Pane
          FluentDefaultNavigationPane(
            selectedIndex: currentIndex,
            onSelectionChanged: (index) {
              ref.read(bottomNavIndexProvider.notifier).state = index;
              _handleNavigation(context, index);
            },
            onChildNavigation: (path) {
              context.go(path);
            },
            onSettingsTap: () {
              context.go(AppRouter.settings);
            },
            onHelpTap: () {
              context.go(AppRouter.help);
            },
          ),
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Optional command bar can be added here
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.production);
        break;
      case 1:
        context.go(AppRouter.fabric);
        break;
      case 2:
        context.go(AppRouter.dispatch);
        break;
      case 3:
        context.go(AppRouter.masters);
        break;
      case 4:
        context.go(AppRouter.reports);
        break;
    }
  }
}

/// Fluent Design System app shell with command bar
class FluentAppShellWithCommandBar extends ConsumerWidget {
  const FluentAppShellWithCommandBar({
    required this.child,
    required this.commandBar,
    super.key,
  });

  final Widget child;
  final Widget commandBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Fluent background
      body: Row(
        children: [
          // Fluent Navigation Pane
          FluentDefaultNavigationPane(
            selectedIndex: currentIndex,
            onSelectionChanged: (index) {
              ref.read(bottomNavIndexProvider.notifier).state = index;
              _handleNavigation(context, index);
            },
            onChildNavigation: (path) {
              context.go(path);
            },
            onSettingsTap: () {
              // TODO: Implement settings navigation
              debugPrint('Settings tapped');
            },
            onHelpTap: () {
              // TODO: Implement help navigation
              debugPrint('Help tapped');
            },
          ),
          // Main content area with command bar
          Expanded(
            child: Column(
              children: [
                // Command bar
                commandBar,
                // Main content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.production);
        break;
      case 1:
        context.go(AppRouter.masters);
        break;
      case 2:
        context.go(AppRouter.reports);
        break;
    }
  }
}

/// Fluent Design System app shell with custom navigation
class FluentCustomAppShell extends ConsumerWidget {
  const FluentCustomAppShell({
    required this.child,
    required this.navigationItems,
    required this.selectedIndex,
    required this.onSelectionChanged,
    super.key,
    this.header,
    this.footer,
    this.commandBar,
  });

  final Widget child;
  final List<FluentNavigationItem> navigationItems;
  final int selectedIndex;
  final ValueChanged<int> onSelectionChanged;
  final Widget? header;
  final Widget? footer;
  final Widget? commandBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Fluent background
      body: Row(
        children: [
          // Custom Fluent Navigation Pane
          FluentNavigationPane(
            selectedIndex: selectedIndex,
            onSelectionChanged: onSelectionChanged,
            items: navigationItems,
            header: header,
            footer: footer,
          ),
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Optional command bar
                if (commandBar != null) commandBar!,
                // Main content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
