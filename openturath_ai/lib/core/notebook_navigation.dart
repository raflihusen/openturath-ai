class NotebookNavigation {
  static const hosts = {
    'notebooklm.google.com', 'notebook.google.com',
    'accounts.google.com', 'accounts.youtube.com', 'consent.google.com',
  };
  static bool allowed(Uri uri) => uri.scheme == 'https' && uri.userInfo.isEmpty &&
    uri.port == 443 && hosts.contains(uri.host.toLowerCase());
  static bool notebook(Uri uri) => allowed(uri) &&
    (uri.host == 'notebooklm.google.com' || uri.host == 'notebook.google.com');
}
