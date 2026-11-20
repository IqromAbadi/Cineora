import 'package:flutter/material.dart';

import 'state_message.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    final action = onAction;
    return StateMessage(
      icon: icon,
      title: title,
      message: message,
      action: label != null && action != null
          ? OutlinedButton(onPressed: action, child: Text(label))
          : null,
    );
  }
}
