class Constants {
  static const List<String> categories = [
    'Nature',
    'Urban',
    'Historical',
    'Mountain',
    'Lake'
  ];

  static const noConnectionErrorMessage = 'Not connected to a network!';

  static const int numberOfPostsPerRequest = 2;
}

enum SourcePage {
  home,
  favourites,
  myposts,
}
