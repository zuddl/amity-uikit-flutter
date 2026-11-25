import 'package:amity_uikit_beta_service/v4/utils/zuddl_avatar.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

class AmityUserImage extends StatelessWidget {
  final AmityUser? user;
  final AmityThemeColor theme;
  final double size;
  // final String? imageUrl;
  // final String displayName;

  const AmityUserImage({
    super.key,
    required this.user,
    required this.size,
    required this.theme,
  });

  String? get imageUrl => user?.zuddlAvatarUrl;
  String get displayName => user?.displayName ?? "";

  // [ZUDDL] Same as portal-flutter's speaker avatar, not Amity's letter disc.
  Widget _buildPlaceholder(BuildContext context) =>
      ZuddlInitialsAvatar(name: displayName, size: size, theme: theme);

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return _buildPlaceholder(context);
          }
        },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return _buildPlaceholder(context);
        },
      );
    } else {
      return _buildPlaceholder(context);
    }
  }
}
