import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

/// [ZUDDL] Zuddl stores the profile photo as `avatarCustomUrl`; `avatarUrl`
/// is only set for a file uploaded to Amity. Natives read the custom URL too.
extension ZuddlAvatar on AmityUser {
  String? get zuddlAvatarUrl {
    final custom = avatarCustomUrl;
    return custom != null && custom.isNotEmpty ? custom : avatarUrl;
  }
}

/// [ZUDDL] A user without a photo: up to two initials on the event colour,
/// as portal-flutter's speaker avatar (`session_detail_view.dart` `_Avatar`).
class ZuddlInitialsAvatar extends StatelessWidget {
  const ZuddlInitialsAvatar(
      {required this.name, required this.size, required this.theme, super.key});

  final String name;
  final double size;
  final AmityThemeColor theme;

  static String initials(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
        // The speaker avatar's text is half its width (20 on 40).
        child: Text(initials(name),
            style: TextStyle(
                color: theme.secondaryColor,
                fontSize: size / 2,
                fontWeight: FontWeight.w500)),
      );
}
