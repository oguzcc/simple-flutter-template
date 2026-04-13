sealed class CoreStrings {
  // MARK: API URLs
  //
  // PRODUCTION TODO: Replace these placeholder URLs with your actual
  // backend endpoints for each flavor.
  static const devUrl = 'http://localhost:3000';
  static const stgUrl = 'https://staging.example.com';
  static const prodUrl = 'https://example.com';

  // MARK: Connection
  static const online = 'You are now online';
  static const offline = 'You are now offline';

  // MARK: Date Time
  static const today = 'Today';
  static const yesterday = 'Yesterday';
  static const tomorrow = 'Tomorrow';

  // MARK: Share
  static const copiedToClipboard = 'Copied to clipboard';

  // MARK: Error Messages
  static const defaultErrorMessage =
      'An error occurred. Please try again later.';
  static const serverErrorMessage =
      'Server error occurred. Please try again later.';
  static const noInternetErrorMessage = 'No internet connection.';
  static const unauthorizedErrorMessage = 'Unauthorized. Please login again.';
}
