import 'dart:async';
import 'package:flutter/material.dart';

/// Text field with built-in validation and real-time feedback
class ValidatedTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool validateOnChange;
  final Duration validationDebounce;
  final AutovalidateMode autovalidateMode;

  const ValidatedTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffix,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.validateOnChange = true,
    this.validationDebounce = const Duration(milliseconds: 300),
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  late TextEditingController _controller;
  String? _errorText;
  bool _isValid = false;
  bool _hasInteracted = false;
  Timer? _debounceTimer;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _obscureText = widget.obscureText;
    
    if (widget.validateOnChange) {
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (!_hasInteracted) {
      setState(() => _hasInteracted = true);
    }
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.validationDebounce, () {
      _validate();
    });
    
    widget.onChanged?.call(_controller.text);
  }

  void _validate() {
    if (!mounted) return;
    
    final error = widget.validator?.call(_controller.text);
    setState(() {
      _errorText = error;
      _isValid = error == null && _controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          autovalidateMode: widget.autovalidateMode,
          validator: widget.validator,
          onFieldSubmitted: widget.onSubmitted,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            labelStyle: const TextStyle(color: Colors.white54),
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: Colors.white54)
                : null,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: const Color(0xFF4A3D7E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: _hasInteracted && _isValid
                  ? const BorderSide(color: Colors.green, width: 2)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: _hasInteracted && _errorText != null
                    ? Colors.red
                    : const Color(0xFFE8FF78),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    // Show toggle for password fields
    if (widget.obscureText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasInteracted && _isValid)
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
          IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.white54,
            ),
            onPressed: () {
              setState(() => _obscureText = !_obscureText);
            },
          ),
        ],
      );
    }
    
    // Show validation indicator if field has been interacted with
    if (_hasInteracted && _controller.text.isNotEmpty) {
      if (_isValid) {
        return const Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.check_circle, color: Colors.green, size: 20),
        );
      }
    }
    
    return widget.suffix;
  }
}

/// Email-specific validated text field
class EmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const EmailTextField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      controller: controller,
      labelText: 'Email',
      hintText: 'Enter your email',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: validator ?? _defaultEmailValidator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      textInputAction: textInputAction ?? TextInputAction.next,
    );
  }

  static String? _defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }
}

/// Password-specific validated text field
class PasswordTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool strictValidation;

  const PasswordTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.strictValidation = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      controller: controller,
      labelText: labelText ?? 'Password',
      hintText: hintText ?? 'Enter your password',
      prefixIcon: Icons.lock_outline,
      obscureText: true,
      validator: validator ?? (strictValidation ? _strictPasswordValidator : _simplePasswordValidator),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      textInputAction: textInputAction ?? TextInputAction.done,
    );
  }

  static String? _simplePasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? _strictPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Must contain at least one number';
    }
    return null;
  }
}
