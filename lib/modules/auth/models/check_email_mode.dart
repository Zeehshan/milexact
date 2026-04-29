enum CheckEmailMode { verification, passwordReset }

extension CheckEmailModeX on CheckEmailMode {
  String get routeValue => switch (this) {
    CheckEmailMode.verification => 'verification',
    CheckEmailMode.passwordReset => 'password_reset',
  };

  static CheckEmailMode fromRouteValue(String? value) {
    return switch (value) {
      'password_reset' => CheckEmailMode.passwordReset,
      _ => CheckEmailMode.verification,
    };
  }
}
