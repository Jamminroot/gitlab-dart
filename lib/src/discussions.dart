part of exitlive.gitlab;

/// The documentation for this API is here:
/// https://docs.gitlab.com/ee/api/discussions.html
class IssueDiscussionsApi {
  final GitLab _gitLab;
  final ProjectsApi _project;
  final String _iid;

  IssueDiscussionsApi(this._gitLab, this._project, int issueIid) : _iid = issueIid.toString();

  /// Retrieves the list of discussions of an issue.
  ///
  /// See https://docs.gitlab.com/ee/api/discussions.html#list-project-issue-discussion-items
  Future<List<Discussion?>> list({
    int? page,
    int? perPage,
  }) async {
    final queryParameters = <String, dynamic>{};

    final uri = _project.buildUri(
      ['issues', _iid, 'discussions'],
      queryParameters: queryParameters,
      page: page,
      perPage: perPage,
    );

    final jsonList = _responseToList(await _gitLab.request(uri));

    return Discussion.fromJsonList(jsonList);
  }

  /// Retrieves a single discussion.
  ///
  /// See https://docs.gitlab.com/ee/api/discussions.html#get-single-issue-discussion-item
  Future<Discussion?> get(String discussionId) async {
    final uri = _project.buildUri(['issues', _iid, 'discussions', discussionId]);

    final json = await _gitLab.request(uri) as Map<String, dynamic>;

    return Discussion.fromJson(json);
  }

  /// Adds a new discussion to an issue.
  ///
  /// See https://docs.gitlab.com/ee/api/discussions.html#create-new-issue-thread
  Future<Discussion?> create(String body) async {
    final uri = _project.buildUri(
      ['issues', _iid, 'discussions'],
      queryParameters: {"body": body},
    );

    final json = await _gitLab.request(uri, method: HttpMethod.post) as Map<String, dynamic>;

    return Discussion.fromJson(json);
  }

  /// Adds a new note to an existing discussion of an issue.
  ///
  /// See https://docs.gitlab.com/ee/api/discussions.html#add-note-to-existing-issue-thread
  Future<Note> addNote(String discussionId, String body) async {
    final uri = _project.buildUri(
      ['issues', _iid, 'discussions', discussionId, 'notes'],
      queryParameters: {"body": body},
    );

    final json = await _gitLab.request(uri, method: HttpMethod.post) as Map<String, dynamic>;

    return Note.fromJson(json);
  }

  /// Updates the body of an existing note of an issue-discussion.
  ///
  /// See https://docs.gitlab.com/ee/api/discussions.html#modify-existing-issue-thread-note
  Future<Note> updateNote(String discussionId, int noteId, String body) async {
    final uri = _project.buildUri(
      ['issues', _iid, 'discussions', discussionId, 'notes', noteId.toString()],
      queryParameters: {"body": body},
    );
    print(uri);

    final json = await _gitLab.request(uri, method: HttpMethod.put) as Map<String, dynamic>;

    return Note.fromJson(json);
  }

  /// Deletes an existing note of an issue-discussion.
  ///
  /// See https://docs.gitlab.com/ee/api/notes.html#delete-an-issue-note
  Future<void> deleteNote(String discussionId, int noteId) async {
    final uri = _project.buildUri(
      ['issues', _iid, 'discussions', discussionId, 'notes', noteId.toString()],
    );

    await _gitLab.request(uri, method: HttpMethod.delete, asJson: false);
  }
}

class Discussion {
  Discussion.fromJson(Map<String, dynamic> discussion)
      : id = discussion.getStringOrNull("id"),
        isIndividualNote = discussion.getBoolOrNull("individual_note"),
        notes = Note.fromJsonList(discussion["notes"] as List);

  static List<Discussion?> fromJsonList(List discussions) =>
      discussions.map((n) => n is Map<String, dynamic> ? Discussion.fromJson(n) : null).where((discussion) => discussion != null).toList();

  final String? id;
  bool? isIndividualNote;
  List<Note?> notes;
}
