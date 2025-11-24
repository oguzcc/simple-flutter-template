import 'package:equatable/equatable.dart';

class TagModel extends Equatable {
  const TagModel({
    this.id,
    this.name,
  });

  final String? id;
  final String? name;

  @override
  List<Object?> get props => [id, name];

  TagModel copyWith({
    String? id,
    String? name,
  }) {
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // id is excluded from JSON (like @JsonKey(includeToJson: false))
      if (name != null) 'name': name,
    };
  }
}
