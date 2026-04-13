import 'package:flutter/material.dart';

import '../theme/app_button_tokens.dart';
import '../utils/constraints.dart';
import 'custom_text.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.minimumSize,
    this.maximumSize,
    this.padding,
    this.textColor,
    this.backgroundColor,
    this.borderRadius,
    this.labelStyle,
    this.labelVariant = AppTextVariant.appMedium16,
    this.maxLines = 1,
    this.useGradient = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final Size? minimumSize;
  final Size? maximumSize;
  final EdgeInsetsGeometry? padding;
  final Color? textColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final TextStyle? labelStyle;
  final AppTextVariant labelVariant;
  final int maxLines;
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appButtonTokens;
    final radius = borderRadius ?? tokens.radius;
    return _AppButtonContainer(
      padding: padding,
      useGradient: useGradient,
      borderRadius: radius,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            useGradient
                ? transparent
                : (backgroundColor ?? tokens.primaryBackground),
          ),
          shadowColor: const WidgetStatePropertyAll(transparent),
          overlayColor: const WidgetStatePropertyAll(transparent),
          elevation: const WidgetStatePropertyAll(0.0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          ),
          minimumSize: WidgetStatePropertyAll(
            minimumSize ?? Size(double.infinity, tokens.height),
          ),
          maximumSize: WidgetStatePropertyAll(
            maximumSize ?? const Size(double.infinity, 44.0),
          ),
        ),
        child: _ButtonChild(
          label: label,
          isLoading: isLoading,
          labelStyle: labelStyle,
          labelVariant: labelVariant,
          textColor: textColor ?? tokens.primaryForeground,
          maxLines: maxLines,
        ),
      ),
    );
  }
}

class AppOutlineButton extends StatelessWidget {
  const AppOutlineButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.minimumSize,
    this.maximumSize,
    this.padding,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.labelStyle,
    this.labelVariant = AppTextVariant.appMedium16,
    this.maxLines = 1,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final Size? minimumSize;
  final Size? maximumSize;
  final EdgeInsetsGeometry? padding;
  final Color? textColor;
  final Color? borderColor;
  final double? borderRadius;
  final TextStyle? labelStyle;
  final AppTextVariant labelVariant;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appButtonTokens;
    final radius = borderRadius ?? tokens.radius;
    final side = BorderSide(
      color: borderColor ?? tokens.outlineBorder,
      width: 1.0,
    );
    return _AppButtonContainer(
      padding: padding,
      borderRadius: radius,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(transparent),
          shadowColor: const WidgetStatePropertyAll(transparent),
          overlayColor: const WidgetStatePropertyAll(transparent),
          elevation: const WidgetStatePropertyAll(0.0),
          side: WidgetStatePropertyAll(side),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: side,
            ),
          ),
          minimumSize: WidgetStatePropertyAll(
            minimumSize ?? Size(double.infinity, tokens.height),
          ),
          maximumSize: WidgetStatePropertyAll(
            maximumSize ?? const Size(double.infinity, 44.0),
          ),
        ),
        child: _ButtonChild(
          label: label,
          isLoading: isLoading,
          labelStyle: labelStyle,
          labelVariant: labelVariant,
          textColor: textColor ?? tokens.outlineForeground,
          maxLines: maxLines,
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.isLoading = false,
    this.minimumSize,
    this.maximumSize,
    this.padding,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.labelStyle,
    this.labelVariant = AppTextVariant.appMedium16,
    this.maxLines = 1,
  });

  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool isLoading;
  final Size? minimumSize;
  final Size? maximumSize;
  final EdgeInsetsGeometry? padding;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final TextStyle? labelStyle;
  final AppTextVariant labelVariant;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appButtonTokens;
    final radius = borderRadius ?? tokens.radius;
    final side = BorderSide(
      color: borderColor ?? tokens.outlineBorder,
      width: 1.0,
    );
    return _AppButtonContainer(
      padding: padding,
      borderRadius: radius,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: icon ?? const Icon(Icons.add),
        label: _ButtonChild(
          label: label,
          isLoading: isLoading,
          labelStyle: labelStyle,
          labelVariant: labelVariant,
          textColor: textColor ?? tokens.iconForeground,
          maxLines: maxLines,
        ),
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            backgroundColor ?? tokens.iconBackground,
          ),
          shadowColor: const WidgetStatePropertyAll(transparent),
          overlayColor: const WidgetStatePropertyAll(transparent),
          elevation: const WidgetStatePropertyAll(0.0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: side,
            ),
          ),
          minimumSize: WidgetStatePropertyAll(
            minimumSize ?? Size(double.infinity, tokens.height),
          ),
          maximumSize: WidgetStatePropertyAll(
            maximumSize ?? const Size(double.infinity, 44.0),
          ),
        ),
      ),
    );
  }
}

class _AppButtonContainer extends StatelessWidget {
  const _AppButtonContainer({
    required this.child,
    this.padding,
    this.useGradient = false,
    this.borderRadius = 4.0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useGradient;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final wrappedChild = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );
    if (!useGradient) return wrappedChild;
    return Container(
      decoration: BoxDecoration(
        gradient: buttonGradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: wrappedChild,
    );
  }
}

class _ButtonChild extends StatelessWidget {
  const _ButtonChild({
    required this.label,
    required this.isLoading,
    required this.labelStyle,
    required this.labelVariant,
    required this.textColor,
    required this.maxLines,
  });

  final String label;
  final bool isLoading;
  final TextStyle? labelStyle;
  final AppTextVariant labelVariant;
  final Color textColor;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 18.0,
        height: 18.0,
        child: CircularProgressIndicator(strokeWidth: 2.0, color: whiteColor),
      );
    }
    return CustomText(
      text: label,
      variant: labelVariant,
      style: labelStyle,
      color: textColor,
      maxLine: maxLines,
      textAlign: TextAlign.center,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    this.maximumSize = const Size(double.infinity, 44.0),
    required this.text,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w500,
    required this.onPressed,
    this.textColor = whiteColor,
    this.bgColor = blackColor,
    this.borderColor = primaryColor,
    this.minimumSize = const Size(double.infinity, 44.0),
    this.borderRadiusSize = 4.0,
    this.buttonType = ButtonType.elevated,
    this.padding,
    this.icon,
    this.maxLine,
    this.isGradient = true,
  });

  final VoidCallback? onPressed;
  final String text;
  final Size maximumSize;
  final Size minimumSize;
  final double fontSize;
  final double borderRadiusSize;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
  final ButtonType buttonType;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final FontWeight fontWeight;
  final int? maxLine;
  final bool isGradient;

  @override
  Widget build(BuildContext context) {
    final legacyStyle = context.appButtonTokens.labelStyle.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
    );

    switch (buttonType) {
      case ButtonType.iconButton:
        return AppIconButton(
          onPressed: onPressed,
          label: text,
          icon: icon,
          textColor: textColor,
          backgroundColor: bgColor,
          borderColor: borderColor,
          minimumSize: minimumSize,
          maximumSize: maximumSize,
          borderRadius: borderRadiusSize,
          padding: padding,
          labelStyle: legacyStyle,
          maxLines: maxLine ?? 1,
        );
      case ButtonType.outlined:
        return AppOutlineButton(
          onPressed: onPressed,
          label: text,
          textColor: textColor,
          borderColor: borderColor,
          minimumSize: minimumSize,
          maximumSize: maximumSize,
          borderRadius: borderRadiusSize,
          padding: padding,
          labelStyle: legacyStyle,
          maxLines: maxLine ?? 1,
        );
      case ButtonType.gradient:
        return AppPrimaryButton(
          onPressed: onPressed,
          label: text,
          textColor: textColor,
          backgroundColor: bgColor,
          minimumSize: minimumSize,
          maximumSize: maximumSize,
          borderRadius: borderRadiusSize,
          padding: padding,
          labelStyle: legacyStyle,
          maxLines: maxLine ?? 1,
          useGradient: isGradient,
        );
      case ButtonType.elevated:
        return AppPrimaryButton(
          onPressed: onPressed,
          label: text,
          textColor: textColor,
          backgroundColor: bgColor,
          minimumSize: minimumSize,
          maximumSize: maximumSize,
          borderRadius: borderRadiusSize,
          padding: padding,
          labelStyle: legacyStyle,
          maxLines: maxLine ?? 1,
        );
    }
  }
}

enum ButtonType { elevated, outlined, iconButton, gradient }
