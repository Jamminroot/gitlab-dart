part of exitlive.gitlab;

class MergeRequestsApi {
  final GitLab _gitLab;
  final ProjectsApi _project;

  MergeRequestsApi(this._gitLab, this._project);

  Future<MergeRequest> get(int iid) async {
    final uri = _project.buildUri(['merge_requests', '$iid']);

    final json = await _gitLab.request(uri) as Map;

    return new MergeRequest.fromJson(json);
  }

  Future<List<MergeRequest>> list(
      {MergeRequestState? state, MergeRequestOrderBy? orderBy, MergeRequestSort? sort, int? page, int? perPage, List<int>? iids}) async {
    final queryParameters = <String, dynamic>{};

    if (state != null) queryParameters['state'] = _enumToString(state);
    if (orderBy != null) queryParameters['order_by'] = _enumToString(orderBy);
    if (sort != null) queryParameters['sort'] = _enumToString(sort);
    if (iids != null && iids.isNotEmpty) {
      queryParameters['iids[]'] = iids.map((iid) => iid.toString());
    }

    final uri = _project.buildUri(['merge_requests'], queryParameters: queryParameters, page: page, perPage: perPage);

    final jsonList = _responseToList(await _gitLab.request(uri));

    return jsonList.map((json) => new MergeRequest.fromJson(json)).toList();
  }
}

enum MergeRequestState { merged, opened, closed }
enum MergeRequestOrderBy { createdAt, updatedAt }
enum MergeRequestSort { asc, desc }

class MergeRequest {
  final Map originalJson;

  MergeRequest.fromJson(this.originalJson);

  int get id => originalJson['id'] as int;
  int get iid => originalJson['iid'] as int;
  String get targetBranch => originalJson['target_branch'] as String;
  String get sourceBranch => originalJson['source_branch'] as String;
  int get projectId => originalJson['project_id'] as int;
  String get title => originalJson['title'] as String;
  String get state => originalJson['state'] as String;
  List<String> get labels => (originalJson['labels'] as List).cast<String>();
  int get upvotes => originalJson['upvotes'] as int;
  int get downvotes => originalJson['downvotes'] as int;
  String get description => originalJson['description'] as String;
  String get webUrl => originalJson['web_url'] as String;

  @override
  String toString() => 'MergeRequest id#$id iid#$iid ($title)';
}
