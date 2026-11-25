import 'package:amity_sdk/amity_sdk.dart';

/// [ZUDDL] Zuddl stores the profile photo as `avatarCustomUrl`; `avatarUrl`
/// is only set for a file uploaded to Amity. Natives read the custom URL too.
extension ZuddlAvatar on AmityUser {
  String? get zuddlAvatarUrl {
    final custom = avatarCustomUrl;
    return custom != null && custom.isNotEmpty ? custom : avatarUrl;
  }
}
