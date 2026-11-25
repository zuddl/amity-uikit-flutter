/// [ZUDDL] File posts, as native iOS (`AmityFile.swift`, `AmityFileExtension.swift`,
/// `AmityFilePicker`). Icons are converted from portal-ios ASC-UIKit `icon_file_*.pdf`.
library;

/// iOS `AmityFilePicker.Constant`: up to 10 files, each up to 1 GB.
const int zuddlMaxPostFiles = 10;
const int zuddlMaxFileBytes = 1000000000;

/// A post shows its first five files; the rest are behind "View all files"
/// (iOS `AmityFileTableView.limitItem`).
const int zuddlFilesShownInFeed = 5;

const _byExtension = {
  'doc': 'doc',
  'docx': 'doc',
  'xls': 'xls',
  'xlsx': 'xls',
  'ppt': 'ppt',
  'pptx': 'ppt',
  'csv': 'csv',
  'txt': 'txt',
  'pdf': 'pdf',
  'html': 'html',
  'mpeg': 'mpeg',
  'avi': 'avi',
  'mp3': 'mp3',
  'mp4': 'mp4',
  'zip': 'zip',
};

/// The icon for a file, by extension first, then by MIME type, as iOS.
String zuddlFileIcon(String? extension, String? mimeType) {
  final ext = (extension ?? '').toLowerCase().replaceFirst('.', '');
  final mime = (mimeType ?? '').toLowerCase();
  final name = _byExtension[ext] ??
      (mime.startsWith('image/')
          ? 'img'
          : mime.startsWith('audio/')
              ? 'audio'
              : mime.startsWith('video/')
                  ? 'mov'
                  : mime == 'application/zip'
                      ? 'zip'
                      : 'default');
  return 'assets/Icons/zuddl_ic_file_$name.svg';
}

/// "12 bytes", "345 KB", "1.2 MB", "1.23 GB": decimal units, as iOS
/// `ByteCountFormatter` with `.file`.
String zuddlFileSize(int bytes) {
  if (bytes < 1000) return bytes == 1 ? '1 byte' : '$bytes bytes';
  if (bytes < 1000 * 1000) return '${(bytes / 1000).round()} KB';
  if (bytes < 1000 * 1000 * 1000) {
    return '${_trim((bytes / 1e6).toStringAsFixed(1))} MB';
  }
  return '${_trim((bytes / 1e9).toStringAsFixed(2))} GB';
}

String _trim(String n) => n.contains('.')
    ? n.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
    : n;
