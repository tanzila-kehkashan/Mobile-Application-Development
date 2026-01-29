/// Validation utility class for form input validation
class Validators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validate password strength
  /// Requirements: min 8 chars, at least one uppercase, one lowercase, one number
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  /// Validate password for login (less strict - just check not empty)
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  /// Validate password confirmation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validate username
  /// Requirements: 3-20 chars, alphanumeric with underscores allowed
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (value.length > 20) {
      return 'Username must be at most 20 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }

  /// Validate name (display name)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Name must be at most 50 characters';
    }
    
    return null;
  }

  /// Validate weight (in lbs or kg)
  static String? validateWeight(String? value, {bool isMetric = false}) {
    if (value == null || value.isEmpty) {
      return null; // Weight is optional
    }
    
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }
    
    if (isMetric) {
      // Metric: 20-300 kg
      if (weight < 20 || weight > 300) {
        return 'Weight must be between 20 and 300 kg';
      }
    } else {
      // Imperial: 44-660 lbs
      if (weight < 44 || weight > 660) {
        return 'Weight must be between 44 and 660 lbs';
      }
    }
    
    return null;
  }

  /// Validate height (in inches or cm)
  static String? validateHeight(String? value, {bool isMetric = false}) {
    if (value == null || value.isEmpty) {
      return null; // Height is optional
    }
    
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }
    
    if (isMetric) {
      // Metric: 100-250 cm
      if (height < 100 || height > 250) {
        return 'Height must be between 100 and 250 cm';
      }
    } else {
      // Imperial: 39-98 inches (3'3" to 8'2")
      if (height < 39 || height > 98) {
        return 'Height must be between 39 and 98 inches';
      }
    }
    
    return null;
  }

  /// Validate age
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Age is optional
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    if (age < 13 || age > 120) {
      return 'Age must be between 13 and 120';
    }
    
    return null;
  }

  /// Validate goal value (steps, calories, minutes)
  static String? validateGoalValue(String? value, {required int min, required int max, required String fieldName}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final goalValue = int.tryParse(value);
    if (goalValue == null) {
      return 'Please enter a valid number';
    }
    
    if (goalValue < min || goalValue > max) {
      return '$fieldName must be between $min and $max';
    }
    
    return null;
  }

  /// Check if a string is a valid number
  static bool isValidNumber(String? value) {
    if (value == null || value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  /// Check if a string is a valid integer
  static bool isValidInteger(String? value) {
    if (value == null || value.isEmpty) return false;
    return int.tryParse(value) != null;
  }
}
