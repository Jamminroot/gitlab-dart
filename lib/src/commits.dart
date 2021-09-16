part of exitlive.gitlab;

class CommitsApi {
  final GitLab _gitLab;
  final ProjectsApi _project;

  CommitsApi(this._gitLab, this._project);

  Future<Commit> get(String sha) async {
    final uri = _project.buildUri(['repository', 'commits', '$sha']);

    final json = await _gitLab.request(uri) as Map;

    return new Commit.fromJson(json);
  }

  Future<List<Commit>> list({String? refName, DateTime? since, DateTime? until, int? page, int? perPage}) async {
    final queryParameters = <String, dynamic>{};

    if (refName != null) queryParameters['ref_name'] = refName;
    if (since != null) queryParameters['since'] = _formatDate(since);
    if (until != null) queryParameters['until'] = _formatDate(until);

    final uri = _project.buildUri(['repository', 'commits'], queryParameters: queryParameters, page: page, perPage: perPage);

    final jsonList = _responseToList(await _gitLab.request(uri));

    return jsonList.map((json) => new Commit.fromJson(json)).toList();
  }
}

class Commit {
  final Map originalJson;

  Commit.fromJson(this.originalJson);

  String get id => originalJson['id'] as String;
  String get shortId => originalJson['short_id'] as String;
  String get title => originalJson['title'] as String;
  String get message => originalJson['message'] as String;
  String get status => originalJson['status'] as String;
  DateTime get createdAt => DateTime.parse(originalJson['created_at'] as String);
  DateTime get committedDate => DateTime.parse(originalJson['committed_date'] as String);

  @override
  String toString() => 'Commit id#$id ($title)';
}
