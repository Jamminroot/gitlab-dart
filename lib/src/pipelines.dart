part of exitlive.gitlab;

/// The documentation for this API is here:
/// https://docs.gitlab.com/ee/api/jobs.html
class PipelinesApi {
  final GitLab _gitLab;
  final ProjectsApi _project;

  PipelinesApi(this._gitLab, this._project);

  Future<Pipeline> get(int id) async {
    final uri = _project.buildUri(['pipelines', '$id']);

    final json = await _gitLab.request(uri) as Map;

    return new Pipeline.fromJson(json);
  }

  Future<List<Pipeline>> list({int? page, int? perPage}) async {
    final uri = _project.buildUri(['pipelines'], page: page, perPage: perPage);

    final jsonList = _responseToList(await _gitLab.request(uri));

    return jsonList.map((json) => new Pipeline.fromJson(json)).toList();
  }
}

class Pipeline {
  final Map originalJson;

  Pipeline.fromJson(this.originalJson);

  int get id => originalJson['id'] as int;
  String get status => originalJson['status'] as String;
  String get ref => originalJson['ref'] as String;
  String get sha => originalJson['sha'] as String;

  @override
  String toString() => 'Pipeline id#$id (Ref: $ref)';
}
