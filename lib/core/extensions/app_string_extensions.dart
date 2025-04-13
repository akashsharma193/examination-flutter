extension AppStringExtensions on String {
  String get getInitials {
    return split(' ')
        .map((e) => e.isEmpty ? '' : e[0].toUpperCase())
        .toList()
        .join('');
  }
}
