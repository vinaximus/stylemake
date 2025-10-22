# Fluent Design Integration Plan

## Overview
Implement Microsoft Fluent Design System for desktop platforms while maintaining Material 3 design for mobile platforms. This will provide a native desktop experience on Windows/macOS/Linux while keeping the familiar mobile experience on Android/iOS.

## Goals
- **Desktop**: Native Fluent Design experience with Windows 11-style components
- **Mobile**: Maintain current Material 3 design
- **Responsive**: Seamless transition between design systems
- **Consistent**: Unified user experience across platforms

## Platform Detection Strategy

### 1. Platform Detection Service
Create a service to detect platform and screen size for design system selection:

```dart
// lib/core/services/platform_service.dart
class PlatformService {
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isWeb => kIsWeb;
  
  static bool get shouldUseFluent => isDesktop && !isWeb;
  static bool get shouldUseMaterial => isMobile || isWeb;
}
```

### 2. Responsive Breakpoints
Extend current responsive system:

```dart
// lib/core/constants/layout_constants.dart
class LayoutConstants {
  // Existing breakpoints
  static const double mobileMaxWidth = 600.0;
  static const double tabletMaxWidth = 900.0;
  static const double desktopMaxWidth = 1200.0;
  
  // New Fluent breakpoints
  static const double fluentMinWidth = 1024.0;  // Minimum for Fluent
  static const double fluentOptimalWidth = 1440.0;  // Optimal Fluent width
}
```

## Fluent Design Implementation

### 1. Fluent Theme System
Create Fluent-specific theme that mirrors Material 3 structure:

```dart
// lib/core/theme/fluent_theme.dart
class FluentTheme {
  static ThemeData lightTheme = ThemeData(
    // Fluent-specific color scheme
    colorScheme: FluentColorScheme.light,
    
    // Fluent typography
    textTheme: FluentTextTheme.light,
    
    // Fluent component themes
    appBarTheme: FluentAppBarTheme.light,
    cardTheme: FluentCardTheme.light,
    buttonTheme: FluentButtonTheme.light,
    inputDecorationTheme: FluentInputTheme.light,
    // ... other component themes
  );
}
```

### 2. Fluent Color System
Implement Fluent Design color tokens:

```dart
// lib/core/theme/fluent_colors.dart
class FluentColors {
  // Fluent Design System colors
  static const Color accent = Color(0xFF0078D4);
  static const Color accentLight = Color(0xFF106EBE);
  static const Color accentDark = Color(0xFF005A9E);
  
  // Neutral colors (Fluent palette)
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralGray10 = Color(0xFFFAFAFA);
  static const Color neutralGray20 = Color(0xFFF5F5F5);
  static const Color neutralGray30 = Color(0xFFEDEBE9);
  static const Color neutralGray40 = Color(0xFFE1DFDD);
  static const Color neutralGray50 = Color(0xFFD2D0CE);
  static const Color neutralGray60 = Color(0xFFC7C6C4);
  static const Color neutralGray70 = Color(0xFFA19F9D);
  static const Color neutralGray80 = Color(0xFF8A8886);
  static const Color neutralGray90 = Color(0xFF605E5C);
  static const Color neutralGray100 = Color(0xFF484644);
  static const Color neutralGray110 = Color(0xFF323130);
  static const Color neutralGray120 = Color(0xFF201F1E);
  static const Color neutralGray130 = Color(0xFF11100F);
  static const Color neutralGray140 = Color(0xFF0B0A0A);
  static const Color neutralGray150 = Color(0xFF000000);
  
  // Semantic colors
  static const Color success = Color(0xFF107C10);
  static const Color warning = Color(0xFFFF8C00);
  static const Color error = Color(0xFFD13438);
  static const Color info = Color(0xFF0078D4);
}
```

### 3. Fluent Typography
Implement Fluent Design typography scale:

```dart
// lib/core/theme/fluent_text_styles.dart
class FluentTextStyles {
  // Fluent typography scale
  static const TextStyle display = TextStyle(
    fontSize: 68,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle largeTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.3,
  );
}
```

## Fluent Components

### 1. Fluent App Bar
Replace Material AppBar with Fluent-style navigation:

```dart
// lib/core/widgets/fluent/fluent_app_bar.dart
class FluentAppBar extends StatelessWidget {
  const FluentAppBar({
    required this.title,
    super.key,
    this.actions,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: FluentColors.neutralGray10,
        border: Border(
          bottom: BorderSide(
            color: FluentColors.neutralGray30,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (leading != null) leading!,
          Expanded(
            child: Text(
              title,
              style: FluentTextStyles.title,
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
```

### 2. Fluent Cards
Implement Fluent-style cards with subtle shadows and borders:

```dart
// lib/core/widgets/fluent/fluent_card.dart
class FlentCard extends StatelessWidget {
  const FluentCard({
    required this.child,
    super.key,
    this.onTap,
    this.elevation = 0,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FluentColors.neutralWhite,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: FluentColors.neutralGray30,
          width: 1,
        ),
        boxShadow: elevation > 0 ? [
          BoxShadow(
            color: FluentColors.neutralGray130.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: child,
        ),
      ),
    );
  }
}
```

### 3. Fluent Buttons
Implement Fluent button styles:

```dart
// lib/core/widgets/fluent/fluent_button.dart
class FluentButton extends StatelessWidget {
  const FluentButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.variant = FluentButtonVariant.primary,
    this.size = FluentButtonSize.medium,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final FluentButtonVariant variant;
  final FluentButtonSize size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _getHeight(),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(2),
        border: _getBorder(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(2),
          child: Padding(
            padding: _getPadding(),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
```

### 4. Fluent Input Fields
Implement Fluent-style form inputs:

```dart
// lib/core/widgets/fluent/fluent_text_field.dart
class FluentTextField extends StatelessWidget {
  const FluentTextField({
    required this.controller,
    required this.label,
    super.key,
    this.hint,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FluentTextStyles.caption.copyWith(
            color: FluentColors.neutralGray130,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.neutralGray60,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.accent,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }
}
```

## Adaptive Layout System

### 1. Adaptive App Shell
Create platform-aware app shell:

```dart
// lib/core/widgets/adaptive_app_shell.dart
class AdaptiveAppShell extends ConsumerWidget {
  const AdaptiveAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = PlatformService.isDesktop;
    
    if (isDesktop) {
      return FluentAppShell(child: child);
    } else {
      return AppShell(child: child);
    }
  }
}
```

### 2. Fluent App Shell
Implement desktop-specific navigation:

```dart
// lib/core/widgets/fluent/fluent_app_shell.dart
class FluentAppShell extends ConsumerWidget {
  const FluentAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          // Fluent Navigation Pane
          FluentNavigationPane(
            selectedIndex: ref.watch(bottomNavIndexProvider),
            onSelectionChanged: (index) {
              ref.read(bottomNavIndexProvider.notifier).state = index;
              // Handle navigation
            },
          ),
          // Main content
          Expanded(child: child),
        ],
      ),
    );
  }
}
```

### 3. Fluent Navigation Pane
Implement Fluent-style navigation:

```dart
// lib/core/widgets/fluent/fluent_navigation_pane.dart
class FluentNavigationPane extends StatelessWidget {
  const FluentNavigationPane({
    required this.selectedIndex,
    required this.onSelectionChanged,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: FluentColors.neutralGray10,
        border: Border(
          right: BorderSide(
            color: FluentColors.neutralGray30,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // App title
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.factory,
                  color: FluentColors.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stylemake',
                  style: FluentTextStyles.title,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Navigation items
          Expanded(
            child: ListView(
              children: [
                _NavigationItem(
                  icon: Icons.factory,
                  label: 'Production',
                  isSelected: selectedIndex == 0,
                  onTap: () => onSelectionChanged(0),
                ),
                _NavigationItem(
                  icon: Icons.inventory_2,
                  label: 'Masters',
                  isSelected: selectedIndex == 1,
                  onTap: () => onSelectionChanged(1),
                ),
                _NavigationItem(
                  icon: Icons.analytics,
                  label: 'Reports',
                  isSelected: selectedIndex == 2,
                  onTap: () => onSelectionChanged(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Implementation Phases

### Phase 1: Foundation (Week 1)
- [ ] Create platform detection service
- [ ] Implement Fluent color system
- [ ] Implement Fluent typography
- [ ] Create basic Fluent theme
- [ ] Update main app to use adaptive theme

### Phase 2: Core Components (Week 2)
- [ ] Implement Fluent buttons
- [ ] Implement Fluent cards
- [ ] Implement Fluent text fields
- [ ] Implement Fluent app bar
- [ ] Create adaptive component wrapper

### Phase 3: Navigation (Week 3)
- [ ] Implement Fluent navigation pane
- [ ] Create adaptive app shell
- [ ] Update routing for desktop
- [ ] Implement desktop-specific layouts

### Phase 4: Advanced Components (Week 4)
- [ ] Implement Fluent dialogs
- [ ] Implement Fluent data tables
- [ ] Implement Fluent command bars
- [ ] Add Fluent animations and transitions

### Phase 5: Polish & Testing (Week 5)
- [ ] Test responsive behavior
- [ ] Polish animations
- [ ] Add accessibility features
- [ ] Performance optimization
- [ ] Cross-platform testing

## File Structure

```
lib/
├── core/
│   ├── services/
│   │   └── platform_service.dart
│   ├── theme/
│   │   ├── fluent_theme.dart
│   │   ├── fluent_colors.dart
│   │   └── fluent_text_styles.dart
│   └── widgets/
│       ├── adaptive_app_shell.dart
│       └── fluent/
│           ├── fluent_app_bar.dart
│           ├── fluent_card.dart
│           ├── fluent_button.dart
│           ├── fluent_text_field.dart
│           ├── fluent_navigation_pane.dart
│           └── fluent_app_shell.dart
```

## Dependencies

Add Fluent Design dependencies to `pubspec.yaml`:

```yaml
dependencies:
  # Existing dependencies...
  
  # Fluent Design support
  fluent_ui: ^4.0.0  # Microsoft's official Fluent UI package
  windows_ui: ^3.0.0  # Windows-specific Fluent components
```

## Testing Strategy

### 1. Platform Testing
- Test on Windows desktop
- Test on macOS desktop  
- Test on Linux desktop
- Test on mobile platforms
- Test responsive breakpoints

### 2. Component Testing
- Unit tests for Fluent components
- Widget tests for adaptive behavior
- Integration tests for navigation
- Visual regression tests

### 3. Accessibility Testing
- Screen reader compatibility
- Keyboard navigation
- High contrast mode
- Focus management

## Success Criteria

- [ ] Desktop app looks and feels native to Windows 11
- [ ] Mobile app maintains Material 3 design
- [ ] Seamless responsive behavior across breakpoints
- [ ] All existing functionality works with new design
- [ ] Performance is maintained or improved
- [ ] Accessibility standards are met
- [ ] Cross-platform compatibility

## Future Enhancements

- Fluent Design animations and micro-interactions
- Windows 11-specific features (snap layouts, etc.)
- macOS-specific adaptations
- Advanced Fluent components (data grids, charts)
- Theme switching (light/dark mode)
- Custom Fluent component library
