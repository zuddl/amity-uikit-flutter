import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/zuddl_avatar.dart';
import 'package:flutter_test/flutter_test.dart';

// [ZUDDL] Avatars use the Zuddl profile photo (avatarCustomUrl) first.
void main() {
  AmityUser user({String? custom, String? file}) => AmityUser()
    ..avatarCustomUrl = custom
    ..avatarUrl = file;

  test('the Zuddl profile photo wins over an Amity file', () {
    expect(
        user(custom: 'https://cdn/p.jpg', file: 'https://amity/f')
            .zuddlAvatarUrl,
        'https://cdn/p.jpg');
  });

  test('without a profile photo the Amity file is used', () {
    expect(user(custom: '', file: 'https://amity/f').zuddlAvatarUrl,
        'https://amity/f');
    expect(user(file: 'https://amity/f').zuddlAvatarUrl, 'https://amity/f');
  });

  test('no photo at all gives null, so the initials show', () {
    expect(user().zuddlAvatarUrl, isNull);
  });
}
