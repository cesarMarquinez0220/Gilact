import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class CustomTextFormFieldWidget extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final String? errorText;
  final bool enabled;
  final TextInputType? keyboardType;
  final int? maxLines;
  final Widget? suffixIcon;
  final String? labelText;
  final String? helperText;
  final bool isRequired;

  const CustomTextFormFieldWidget({
    super.key,
    required this.hintText,
    required this.icon,
    this.controller,
    this.focusNode,
    this.onTap,
    this.obscureText = false,
    this.inputFormatters,
    this.validator,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.maxLines = 1,
    this.suffixIcon,
    this.labelText,
    this.helperText,
    this.isRequired = false,
  });

  @override
  State<CustomTextFormFieldWidget> createState() =>
      _CustomTextFormFieldWidgetState();
}

class _CustomTextFormFieldWidgetState extends State<CustomTextFormFieldWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label opcional
        if (widget.labelText != null) ...[
          Row(
            children: [
              Text(
                widget.labelText!,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Campo de texto
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              height: widget.maxLines == 1 ? 48 : null,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface.withValues(alpha: 0.9),
                    AppColors.surface.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: _isFocused
                      ? AppColors.primary
                      : widget.errorText != null
                      ? AppColors.error.withValues(alpha: 0.5)
                      : AppColors.border.withValues(alpha: 0.3),
                  width: _isFocused ? 2.0 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isFocused
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.1),
                    blurRadius: _isFocused ? 20 : 15,
                    spreadRadius: _isFocused ? 3 : 2,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                onTap: () {
                  widget.onTap?.call();
                  _isFocused = true;
                  _animationController.forward();
                },
                obscureText: widget.obscureText,
                validator: widget.validator,
                inputFormatters: widget.inputFormatters,
                enabled: widget.enabled,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  color: widget.enabled
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: GoogleFonts.quicksand(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.primary.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: _isFocused
                          ? AppColors.primary
                          : widget.errorText != null
                          ? AppColors.error
                          : AppColors.primary.withValues(alpha: 0.7),
                      size: 18.0,
                    ),
                  ),
                  suffixIcon: widget.suffixIcon,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                ),
                onChanged: (value) {
                  // Notificar cambios para validación en tiempo real
                },
                onTapOutside: (event) {
                  _isFocused = false;
                  _animationController.reverse();
                },
              ),
            );
          },
        ),

        // Texto de ayuda
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],

        // Mensaje de error
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
