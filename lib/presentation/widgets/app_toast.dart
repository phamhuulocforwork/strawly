import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Transient feedback via [ShadToast] (requires [ShadToaster] from [ShadAppBuilder]).
abstract final class AppToast {
  static const Duration _defaultDuration = Duration(seconds: 5);
  static const Duration undoDuration = Duration(seconds: 8);

  static void success(
    BuildContext context, {
    required String title,
    String? description,
    Duration? duration,
  }) {
    show(
      context,
      title: title,
      description: description,
      duration: duration,
    );
  }

  static void error(
    BuildContext context, {
    required String title,
    String? description,
    Duration? duration,
  }) {
    show(
      context,
      title: title,
      description: description,
      destructive: true,
      duration: duration,
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    String? description,
    Widget? action,
    bool destructive = false,
    Duration? duration,
  }) {
    final toaster = ShadToaster.of(context);
    final effectiveDuration = duration ?? _defaultDuration;

    final toast = destructive
        ? ShadToast.destructive(
            title: Text(title),
            description: description != null ? Text(description) : null,
            action: action,
            duration: effectiveDuration,
          )
        : ShadToast(
            title: Text(title),
            description: description != null ? Text(description) : null,
            action: action,
            duration: effectiveDuration,
          );

    toaster.show(toast);
  }
}
