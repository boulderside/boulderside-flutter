import 'package:json_annotation/json_annotation.dart';

part 'find_id_response.g.dart';

@JsonSerializable()
class FindIdResponse {
  final String email;

  FindIdResponse({required this.email});

  factory FindIdResponse.fromJson(Map<String, dynamic> json) =>
      _$FindIdResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FindIdResponseToJson(this);
}
