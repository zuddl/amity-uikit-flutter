import 'dart:ui';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/component/community_header_component.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:flutter/material.dart';

class AmityCommunityCoverView extends BaseElement {
  final AmityCommunity? community;
  final AmityCommunityHeaderStyle style;

  AmityCommunityCoverView({
    super.key,
    required this.community,
    required this.style,
  }) : super(elementId: "community_cover");

  @override
  Widget buildElement(BuildContext context) {
    switch (style) {
      case AmityCommunityHeaderStyle.EXPANDED:
        return Container(
          width: double.infinity,
          height: 188,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // [ZUDDL] No back or options button on the cover, as native: the
              // host's header has back, and community settings stay hidden.
              renderAvatarImage(),
            ],
          ),
        );
      case AmityCommunityHeaderStyle.COLLAPSE:
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: renderAvatarImage()),
        );
    }
  }

  Widget renderAvatarImage() {
    final url = community?.avatarImage?.getUrl(AmityImageSize.LARGE);
    return (url != null)
        ? Container(width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              ),
            )
          )
        : Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.14, -0.99),
                end: Alignment(0.14, 0.99),
                colors: [Color(0xFFA5A9B5), Color(0xFF898E9E)],
              ),
            ),
          );
  }
}
