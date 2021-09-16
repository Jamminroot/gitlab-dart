part of exitlive.gitlab;

class SnippetsApi {
  final GitLab _gitLab;
  final ProjectsApi _project;

  SnippetsApi(this._gitLab, this._project);

  /// If you want to get the content, use [content]
  Future<Snippet> get(int id) async {
    final uri = _project.buildUri(['snippets', '$id']);

    final json = await _gitLab.request(uri) as Map;

    return new Snippet.fromJson(json);
  }

  Future<String> content(int id) async {
    final uri = _project.buildUri(['snippets', '$id', 'raw']);
    return await _gitLab.request(uri, asJson: false) as String;
  }

  Future<List<Snippet>> list({int? page, int? perPage}) async {
    final uri = _project.buildUri(['snippets'], page: page, perPage: perPage);

    final jsonList = _responseToList(await _gitLab.request(uri));

    return jsonList.map((json) => new Snippet.fromJson(json)).toList();
  }

  Future update(int id, {String? title, String? fileName, String? code, String? visibility}) async {
    final queryParameters = <String, dynamic>{};

    if (title != null) queryParameters['title'] = title;
    if (fileName != null) queryParameters['file_name'] = fileName;
    if (code != null) queryParameters['code'] = code;
    if (visibility != null) queryParameters['visibility'] = '$visibility';

    final uri = _project.buildUri(['snippets', '$id'], queryParameters: queryParameters);

    final json = await _gitLab.request(uri, method: HttpMethod.put) as Map;

    return new Snippet.fromJson(json);
  }
}

class Snippet {
  final Map originalJson;

  Snippet.fromJson(this.originalJson);

  int get id => originalJson['id'] as int;
  String get title => originalJson['title'] as String;
  String get fileName => originalJson['file_name'] as String;
  String get webUrl => originalJson['web_url'] as String;

  @override
  String toString() => 'Snippet id#$id ($title)';
}
