part of exitlive.gitlab;

/// If you have an enum like `enum Foo { foo, bar }` calling this function will return the name of the value.
///
/// Eg.:
///     _enumToString(Foo.bar); // => 'bar'
String _enumToString(dynamic enumValue) {
  final value = enumValue.toString().split('.').last;
  value.replaceAllMapped(new RegExp(r'([A-Z])'), (match) => '_${match.group(1)?.toLowerCase()}');
  return value;
}

final _formatter = new DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
String _formatDate(DateTime date) => _formatter.format(date);

List<Map> _responseToList(dynamic response) => (response as List).cast<Map>();
