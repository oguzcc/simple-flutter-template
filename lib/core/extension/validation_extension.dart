extension ValidationExtension on String {
  bool isValidEmail() {
    if (isEmpty) return false;

    const pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(this);
  }

  bool isValidOTPCode() {
    const pattern = r'^[0-9]*$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(this) && length == 6;
  }

  bool isValidPhoneNumber() {
    if (isEmpty) return false;

    const pattern = r'^\(\d{3}\) \d{3} \d{4}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(this);
  }

  bool isValidQRCode() {
    const pattern = r'^[a-zA-Z0-9][a-zA-Z0-9_.]+[a-zA-Z0-9]$';
    final regExp = RegExp(pattern);
    return length >= 4 && length <= 16 && regExp.hasMatch(this);
  }
}
