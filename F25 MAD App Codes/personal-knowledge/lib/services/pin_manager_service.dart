import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Service for managing PIN operations
/// Handles PIN hashing, verification, and validation
class PinManagerService {
  
  /// Hash a PIN using SHA-256
  /// Returns a secure hash of the PIN
  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify if provided PIN matches the hashed PIN
  /// Returns true if PIN is correct
  bool verifyPin(String providedPin, String hashedPin) {
    final hashedProvidedPin = hashPin(providedPin);
    return hashedProvidedPin == hashedPin;
  }

  /// Validate PIN format
  /// PIN must be 4-6 digits
  bool isValidPin(String pin) {
    if (pin.isEmpty) return false;
    if (pin.length < 4 || pin.length > 6) return false;
    
    // Check if all characters are digits
    final regex = RegExp(r'^[0-9]+$');
    return regex.hasMatch(pin);
  }

  /// Check PIN strength
  /// Returns strength level: weak, medium, strong
  String getPinStrength(String pin) {
    if (!isValidPin(pin)) return 'invalid';
    
    // Check for sequential numbers (1234, 5678, etc.)
    if (_isSequential(pin)) return 'weak';
    
    // Check for repeating numbers (1111, 2222, etc.)
    if (_isRepeating(pin)) return 'weak';
    
    // Check for common PINs
    if (_isCommonPin(pin)) return 'weak';
    
    if (pin.length == 4) return 'medium';
    if (pin.length >= 5) return 'strong';
    
    return 'medium';
  }

  bool _isSequential(String pin) {
    for (int i = 0; i < pin.length - 1; i++) {
      int current = int.parse(pin[i]);
      int next = int.parse(pin[i + 1]);
      if (next != current + 1 && next != current - 1) {
        return false;
      }
    }
    return true;
  }

  bool _isRepeating(String pin) {
    return pin.split('').toSet().length == 1;
  }

  bool _isCommonPin(String pin) {
    const commonPins = [
      '1234', '0000', '1111', '2222', '3333', '4444',
      '5555', '6666', '7777', '8888', '9999', '1212',
      '4321', '6969', '1004', '2000', '7777'
    ];
    return commonPins.contains(pin);
  }

  /// Generate error message for invalid PIN
  String? getPinErrorMessage(String pin) {
    if (pin.isEmpty) return 'PIN cannot be empty';
    if (pin.length < 4) return 'PIN must be at least 4 digits';
    if (pin.length > 6) return 'PIN must be at most 6 digits';
    
    final regex = RegExp(r'^[0-9]+$');
    if (!regex.hasMatch(pin)) return 'PIN must contain only numbers';
    
    return null; // No error
  }
}
