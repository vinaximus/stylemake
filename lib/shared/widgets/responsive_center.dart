import 'package:flutter/material.dart';
import 'package:stylemake/shared/constants/layout_constants.dart';

/// A widget that centers its child and constrains its width on larger screens
/// to prevent UI elements from stretching too much on desktop.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    required this.child,
    this.maxWidth,
    this.padding,
    super.key,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveMaxWidth = maxWidth ?? _getMaxWidth(screenWidth);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }

  /// Determines max width based on screen size
  double _getMaxWidth(double screenWidth) {
    if (screenWidth <= LayoutConstants.mobileMaxWidth) {
      // Mobile: use full width
      return double.infinity;
    } else if (screenWidth <= LayoutConstants.tabletMaxWidth) {
      // Tablet: use 80% or max 700px
      return 700.0;
    } else {
      // Desktop: use max 800px for forms, 1200px for lists
      return 800.0;
    }
  }
}

/// A responsive wrapper specifically for form screens with tighter constraints
class ResponsiveFormContainer extends StatelessWidget {
  const ResponsiveFormContainer({
    required this.child,
    this.maxWidth = 600.0,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// A responsive wrapper for list content
class ResponsiveListContainer extends StatelessWidget {
  const ResponsiveListContainer({
    required this.child,
    this.maxWidth = 1000.0,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
