import 'package:json_annotation/json_annotation.dart';

part 'phone_lookup_request.g.dart';

@JsonSerializable()
class PhoneLookupRequest {
  final String phoneNumber;

  PhoneLookupRequest({required this.phoneNumber});

  factory PhoneLookupRequest.fromJson(Map<String, dynamic> json) =>
      _$PhoneLookupRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneLookupRequestToJson(this);
}
