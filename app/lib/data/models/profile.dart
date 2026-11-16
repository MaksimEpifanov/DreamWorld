import 'package:freezed_annotation/freezed_annotation.dart';

import 'interest.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// Цель знакомства.
@JsonEnum()
enum RelationshipGoal {
  @JsonValue('chat')
  chat,
  @JsonValue('friendship')
  friendship,
  @JsonValue('dating')
  dating,
  @JsonValue('serious')
  serious,
}

/// Анкета пользователя: то, что видят другие в подборе.
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String name,
    required int age,
    String? bio,
    String? photoUrl,
    @Default(<String>[]) List<String> photoUrls,
    String? city,
    String? country,
    @Default(<Interest>[]) List<Interest> interests,
    @Default(<String>[]) List<String> goals,
    @Default(<String>[]) List<String> values,
    @Default(<String>[]) List<String> languages,
    @Default(RelationshipGoal.chat) RelationshipGoal relationshipGoal,
    @Default(true) bool isOnline,
    DateTime? lastSeenAt,
    DateTime? createdAt,
    @Default(<String>[]) List<String> detailedInterests,
    @Default(<String>[]) List<String> joinedPlanetIds,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  const Profile._();

  /// Названия интересов профиля.
  List<String> get interestNames => interests
      .map((Interest interest) => interest.name)
      .toList(growable: false);
}
