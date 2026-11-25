import 'dart:convert';
import 'dart:io';

import 'package:amity_uikit_beta_service/v4/social/comment/comment_tray_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_detail/post_content_component_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/user_search_result/user_search_result_behavior.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// [ZUDDL] F6: what attendees can do in the feed matches the native apps.
void main() {
  test('creation: text, image, video and poll on; story, live, clip off', () {
    final config =
        jsonDecode(File('assets/config/config.json').readAsStringSync())
            as Map<String, dynamic>;
    final flags =
        AmityFeatureFlag(config['feature_flags'] as Map<String, dynamic>);

    expect(flags.post.text.createEnabled, isTrue);
    expect(flags.post.image.createEnabled, isTrue);
    expect(flags.post.video.createEnabled, isTrue);
    expect(flags.post.poll.createEnabled, isTrue);
    expect(flags.post.livestream.createEnabled, isFalse);
    expect(flags.post.clip.createEnabled, isFalse);
    expect(flags.story.createEnabled, isFalse);
  });

  testWidgets('taps on a user open no profile page', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        ctx = context;
        return const Text('feed');
      }),
    ));

    AmityPostContentComponentBehavior().goToUserProfilePage(ctx, 'u1');
    AmityCommentTrayBehavior().goToUserProfilePage(ctx, 'u1');
    AmityUserSearchResultBehavior().goToUserProfilePage(ctx, 'u1');
    await tester.pumpAndSettle();

    expect(find.text('feed'), findsOneWidget);
    expect(Navigator.of(ctx).canPop(), isFalse);
  });
}
