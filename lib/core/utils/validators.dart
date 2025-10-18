/// Form validation utilities
class Validators {
  Validators._();

  /// Compose multiple validators
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Required field validator
  static String? Function(String?) required([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message ?? 'This field is required';
      }
      return null;
    };
  }

  /// Minimum length validator
  static String? Function(String?) minLength(int min, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length < min) {
        return message ?? 'Minimum $min characters required';
      }
      return null;
    };
  }

  /// Maximum length validator
  static String? Function(String?) maxLength(int max, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length > max) {
        return message ?? 'Maximum $max characters allowed';
      }
      return null;
    };
  }

  /// Numeric validator (integers only)
  static String? Function(String?) numeric([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (int.tryParse(value) == null) {
        return message ?? 'Please enter a valid number';
      }
      return null;
    };
  }

  /// Decimal number validator
  static String? Function(String?) decimal([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (double.tryParse(value) == null) {
        return message ?? 'Please enter a valid decimal number';
      }
      return null;
    };
  }

  /// Positive number validator (> 0)
  static String? Function(String?) positiveNumber([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final number = double.tryParse(value);
      if (number == null || number <= 0) {
        return message ?? 'Please enter a positive number';
      }
      return null;
    };
  }

  /// Positive integer validator (> 0)
  static String? Function(String?) positiveInteger([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final number = int.tryParse(value);
      if (number == null || number <= 0) {
        return message ?? 'Please enter a positive integer';
      }
      return null;
    };
  }

  /// Non-negative number validator (>= 0)
  static String? Function(String?) nonNegativeNumber([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final number = double.tryParse(value);
      if (number == null || number < 0) {
        return message ?? 'Please enter a non-negative number';
      }
      return null;
    };
  }

  /// Email validator
  static String? Function(String?) email([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(value)) {
        return message ?? 'Please enter a valid email address';
      }
      return null;
    };
  }

  /// Indian GST number validator (15 characters)
  static String? Function(String?) gstNumber([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final gstRegex = RegExp(
        r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
      );
      if (!gstRegex.hasMatch(value)) {
        return message ?? 'Please enter a valid GST number (15 characters)';
      }
      return null;
    };
  }

  /// PIN code validator (6 digits for India)
  static String? Function(String?) pinCode([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final pinRegex = RegExp(r'^[0-9]{6}$');
      if (!pinRegex.hasMatch(value)) {
        return message ?? 'Please enter a valid 6-digit PIN code';
      }
      return null;
    };
  }

  /// Phone number validator (10 digits for India)
  static String? Function(String?) phoneNumber([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final phoneRegex = RegExp(r'^[0-9]{10}$');
      if (!phoneRegex.hasMatch(value)) {
        return message ?? 'Please enter a valid 10-digit phone number';
      }
      return null;
    };
  }

  /// Custom pattern validator
  static String? Function(String?) pattern(RegExp regex, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!regex.hasMatch(value)) {
        return message ?? 'Invalid format';
      }
      return null;
    };
  }

  /// Cutting reference format validator (letters, numbers, hyphens)
  static String? Function(String?) cuttingRefFormat([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final cuttingRefRegex = RegExp(r'^[A-Z0-9\-]+$');
      if (!cuttingRefRegex.hasMatch(value)) {
        return message ??
            'Only uppercase letters, numbers, and hyphens allowed';
      }
      return null;
    };
  }

  /// Range validator for numbers
  static String? Function(String?) range(
    double min,
    double max, [
    String? message,
  ]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final number = double.tryParse(value);
      if (number == null || number < min || number > max) {
        return message ?? 'Value must be between $min and $max';
      }
      return null;
    };
  }
}
