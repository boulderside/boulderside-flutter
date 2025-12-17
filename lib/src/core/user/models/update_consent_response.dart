class UpdateConsentResponse {
  UpdateConsentResponse({required this.consentType, required this.agreed});

  final String consentType;
  final bool agreed;

  factory UpdateConsentResponse.fromJson(Map<String, dynamic> json) {
    return UpdateConsentResponse(
      consentType: json['consentType'] as String? ?? '',
      agreed: json['agreed'] as bool? ?? false,
    );
  }
}
