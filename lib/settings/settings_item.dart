import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

Widget settingsItem({
  String? tooltip,
  bool wrapControls = false,
  required String text,
  required Widget child,
}) {
  final settingItemContent = tooltip is String ? Tooltip(
    triggerMode: TooltipTriggerMode.tap,
    showDuration: kIsWeb ? null : const Duration(milliseconds: 5000),
    message: tooltip,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 8, bottom: 3),
          child: Icon(
            Ionicons.information_circle_outline,
            color: Colors.black,
            size: 25
          ),
        ),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 21)
          ),
        ),
      ],
    ),
  ) : Text(
    text,
    textWidthBasis: TextWidthBasis.longestLine,
    style: const TextStyle(fontSize: 21)
  );

  return wrapControls ? Row(
    children: [
      Expanded(
        child: Wrap (
          direction: Axis.horizontal,
          alignment: WrapAlignment.spaceBetween,
          children: [
            settingItemContent,
            child
          ],
        ),
      ),
    ],
  ) : Row(
    children: [
      Expanded(child: settingItemContent),
      child
    ],
  );
}
