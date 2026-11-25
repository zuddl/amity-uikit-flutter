import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/zuddl_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

/// [ZUDDL] A file post's files: icon, name and size, as native iOS
/// `AmityFileTableView`. A tap opens the file.
class PostContentFile extends StatelessWidget {
  const PostContentFile({
    super.key,
    required this.posts,
    required this.theme,
    this.onViewAll,
  });

  final List<AmityPost> posts;
  final AmityThemeColor theme;

  /// Set in the feed: only the first five files show, then "View all files".
  /// Post detail leaves it null and shows every file.
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final files =
        posts.map(_properties).whereType<AmityFileProperties>().toList();
    if (files.isEmpty) return const SizedBox.shrink();

    final limited = onViewAll != null && files.length > zuddlFilesShownInFeed;
    final shown = limited ? files.take(zuddlFilesShownInFeed) : files;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final f in shown) _FileRow(file: f, theme: theme),
          if (limited)
            TextButton(
              onPressed: onViewAll,
              child: Text(
                context.l10n.zuddl_post_view_all_files,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// `fileInfo` is `late`: unset until the SDK has the file, and reading it then throws.
AmityFileProperties? _properties(AmityPost post) {
  final data = post.data;
  if (data is! FileData) return null;
  try {
    return data.fileInfo.getFileProperties;
  } catch (_) {
    return null;
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.file, required this.theme});

  final AmityFileProperties file;
  final AmityThemeColor theme;

  @override
  Widget build(BuildContext context) {
    final url = file.fileUrl;
    final size = int.tryParse(file.size ?? '');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        // Native downloads, then offers to save; the browser shows or
        // downloads it the same way.
        onTap: url == null
            ? null
            : () =>
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.baseColorShade4),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                zuddlFileIcon(file.ext, file.mimeType),
                package: 'amity_uikit_beta_service',
                width: 34,
                height: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.baseColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (size != null)
                      Text(
                        zuddlFileSize(size),
                        style: TextStyle(
                          color: theme.baseColorShade2,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
