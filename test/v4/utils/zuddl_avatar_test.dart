import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/zuddl_avatar.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';
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

  test('initials take the first letter of up to two words', () {
    expect(ZuddlInitialsAvatar.initials('gopi  krishna p'), 'GK');
    expect(ZuddlInitialsAvatar.initials('Kiran'), 'K');
    expect(ZuddlInitialsAvatar.initials('  '), '');
  });

  testWidgets('no photo: initials on the event colour, like a speaker',
      (tester) async {
    final theme = AmityThemeColor(
      primaryColor: const Color(0xFFE8C46A),
      secondaryColor: const Color(0xFF111111),
      baseColor: const Color(0xFFFFFFFF),
      baseInverseColor: const Color(0xFFFFFFFF),
      baseColorShade1: const Color(0xFFFFFFFF),
      baseColorShade2: const Color(0xFFFFFFFF),
      baseColorShade3: const Color(0xFFFFFFFF),
      baseColorShade4: const Color(0xFFFFFFFF),
      alertColor: const Color(0xFFFFFFFF),
      backgroundColor: const Color(0xFF000000),
      backgroundShade1Color: const Color(0xFF000000),
      highlightColor: const Color(0xFFFFFFFF),
    );
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ZuddlInitialsAvatar(name: 'Gopi Krishna', size: 40, theme: theme),
    ));

    final text = tester.widget<Text>(find.text('GK'));
    expect(text.style?.color, const Color(0xFF111111));
    expect(text.style?.fontSize, 20);
    final box = tester.widget<Container>(find.byType(Container)).decoration
        as BoxDecoration;
    expect(box.color, const Color(0xFFE8C46A));
  });
}
