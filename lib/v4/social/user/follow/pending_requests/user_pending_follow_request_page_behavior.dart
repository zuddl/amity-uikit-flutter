import 'package:amity_uikit_beta_service/v4/utils/zuddl_flags.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/amity_user_profile_page.dart';
import 'package:flutter/material.dart';

class AmityUserPendingFollowRequestsPageBehavior {

  void goToUserProfilePage(
    BuildContext context,
    String userId,
  ) {
    // [ZUDDL] See zuddl_flags.dart.
    if (!zuddlOpensUserProfiles) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmityUserProfilePage(
          userId: userId,
        ),
      ),
    );
  }
  
}
