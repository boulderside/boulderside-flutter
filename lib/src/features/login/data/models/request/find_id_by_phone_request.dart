import 'package:json_annotation/json_annotation.dart';

part 'find_id_by_phone_request.g.dart';

@JsonSerializable()
class FindIdByPhoneRequest {
  final String phoneNumber;

  FindIdByPhoneRequest({required this.phoneNumber});

  factory FindIdByPhoneRequest.fromJson(Map<String, dynamic> json) =>
      _$FindIdByPhoneRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FindIdByPhoneRequestToJson(this);
}
