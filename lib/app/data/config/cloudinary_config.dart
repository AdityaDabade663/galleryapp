class CloudinaryConfig {
  /// 1. Enter your Cloud Name from your Cloudinary Dashboard
  static const String cloudName = 'rxx45egw';

  /// 2. Enter your Unsigned Upload Preset name
  /// (Created in Cloudinary Settings -> Upload -> Upload Presets -> Add Unsigned)
  static const String uploadPreset = 'gallery_preset';

  static bool get isConfigured =>
      cloudName.trim().isNotEmpty && uploadPreset.trim().isNotEmpty;
}
