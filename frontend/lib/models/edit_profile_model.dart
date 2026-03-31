import 'package:image_picker/image_picker.dart';

class EditProfileModel {
  final String name;
  final String? bio;

  /// Existing profile photo URL (from server/auth state).
  final String? existingPhotoUrl;

  /// A newly picked local image file (not yet uploaded).
  final XFile? newPhoto;

  /// True when the user explicitly removed their photo.
  final bool photoDeleted;

  const EditProfileModel({
    required this.name,
    this.bio,
    this.existingPhotoUrl,
    this.newPhoto,
    this.photoDeleted = false,
  });

  /// Whether any photo is currently set (new pick OR existing not deleted).
  bool get hasPhoto =>
      newPhoto != null || (!photoDeleted && existingPhotoUrl != null);

  /// True when the user changed at least one field.
  bool get isDirty =>
      name.trim().isNotEmpty || bio != null || newPhoto != null || photoDeleted;

  /// Serialise name + bio for API submission.
  Map<String, dynamic> toMap() => {
        'name': name.trim(),
        'bio': bio?.trim(),
        'deletePhoto': photoDeleted,
        // newPhoto.path should be uploaded separately as multipart
        if (newPhoto != null) 'newPhotoPath': newPhoto!.path,
      };

  @override
  String toString() =>
      'EditProfileModel(name: $name, bio: $bio, '
      'existingPhotoUrl: $existingPhotoUrl, '
      'newPhoto: ${newPhoto?.name}, photoDeleted: $photoDeleted)';
}
