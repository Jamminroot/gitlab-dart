part of exitlive.gitlab;

/// The documentation for this API is here:
/// https://docs.gitlab.com/ee/api/notes.html
class IssueNotesApi {
  final GitLab _gitLab;
  final ProjectsApi _project;
  final String _iid;

  IssueNotesApi(this._gitLab, this._project, int issueIid) : _iid = issueIid.toString();

  /// Retrieves the list of notes of an issue.
  ///
  /// See https://docs.gitlab.com/ee/api/notes.html#list-project-issue-notes
  Future<List<Note?>> list({
    NoteOrderBy? orderBy,
    NoteSort? sort,
    int? page,
    int? perPage,
  }) async {
    final queryParameters = <String, dynamic>{};

    if (orderBy != null) queryParameters['order_by'] = _enumToString(orderBy);
    if (sort != null) queryParameters['sort'] = _enumToString(sort);

    final uri = _project.buildUri(
      ['issues', _iid, 'notes'],
      queryParameters: queryParameters,
      page: page,
      perPage: perPage,
    );

    final jsonList = _responseToList(await _gitLab.request(uri));

    return Note.fromJsonList(jsonList);
  }

  /// Retrieves a single note.
  ///
  /// See https://docs.gitlab.com/ee/api/notes.html#get-single-issue-note
  Future<Note> get(int noteId) async {
    final uri = _project.buildUri(['issues', _iid, 'notes', noteId.toString()]);

    final json = await _gitLab.request(uri) as Map<String, dynamic>;

    return Note.fromJson(json);
  }

  /// Adds a note to an issue.
  ///
  /// See https://docs.gitlab.com/ee/api/notes.html#create-new-issue-note
  Future<Note> create(String body) async {
    final uri = _project.buildUri(
      ['issues', _iid, 'notes'],
      queryParameters: {"body": body},
    );

    final json = await _gitLab.request(uri, method: HttpMethod.post) as Map<String, dynamic>;

    return Note.fromJson(json);
  }

  /// Updates the body of an existing note.
  ///
  /// See https://docs.gitlab.com/ee/api/notes.html#modify-existing-issue-note
  Future<Note> update(int noteId, String body) async {
    final uri = _project.buildUri(
      ['issues', _iid, 'notes', noteId.toString()],
      queryParameters: {"body": body},
    );

    final json = await _gitLab.request(uri, method: HttpMethod.put) as Map<String, dynamic>;

    return Note.fromJson(json);
  }

  /// Deletes an existing note.
  ///
  /// See https://docs.gitlab.com/ee/api/notes.html#delete-an-issue-note
  Future<void> delete(int noteId) async {
    final uri = _project.buildUri(
      ['issues', _iid, 'notes', noteId.toString()],
    );

    await _gitLab.request(uri, method: HttpMethod.delete, asJson: false);
  }
}

enum NoteOrderBy { createdAt, updatedAt }
enum NoteSort { asc, desc }

class Note {
  Note.fromJson(Map<String, dynamic> note)
      : id = note.getIntOrNull("id"),
        type = note.getStringOrNull("type"),
        body = note.getStringOrNull("body"),
        author = Author.fromJson(note.getJsonMap("author")),
        createdAt = note.getISODateTimeOrNull("created_at"),
        updatedAt = note.getISODateTimeOrNull("updated_at"),
        isSystemNote = note.getBoolOrNull("system"),
        noteableId = note.getIntOrNull("noteable_id"),
        noteableType = note.getStringOrNull("noteable_type"),
        noteableIid = note.getIntOrNull("noteable_iid");

  static List<Note?> fromJsonList(List notes) => notes.map((n) => n is Map<String, dynamic> ? Note.fromJson(n) : null).where((note) => note != null).toList();

  final int? id;
  String? type;
  String? body;

  Author? author;

  DateTime? createdAt;
  DateTime? updatedAt;

  bool? isSystemNote;

  int? noteableId;
  String? noteableType;
  int? noteableIid;
}

class Author {
  Author.fromJson(Map<String, dynamic> author)
      : id = author.getIntOrNull("id"),
        name = author.getStringOrNull("name"),
        username = author.getStringOrNull("username"),
        state = author.getStringOrNull("state"),
        avatarUrl = author.getStringOrNull("avatar_url"),
        webUrl = author.getStringOrNull("web_url");

  final int? id;
  String? name;
  String? username;
  String? state;
  String? avatarUrl;
  String? webUrl;
}
