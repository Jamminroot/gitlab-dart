part of exitlive.gitlab;

class IssueNotesApi {
  final GitLab _gitLab;
  final ProjectsApi _project;
  final String _iid;

  IssueNotesApi(this._gitLab, this._project, int issueIid)
      : _iid = issueIid.toString();

  Future<List<Note>> list({
    NoteOrderBy orderBy,
    NoteSort sort,
    int page,
    int perPage,
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

  Future<Note> get(int noteId) async {
    final uri = _project.buildUri(['issues', _iid, 'notes', noteId.toString()]);

    final json = await _gitLab.request(uri) as Map<String, dynamic>;

    return Note.fromJson(json);
  }

  Future<Note> add(String body) async {
    final uri = _project.buildUri(
      ['issues', _iid, 'notes'],
      queryParameters: {"body": body},
    );

    final json = await _gitLab.request(uri, method: HttpMethod.post)
        as Map<String, dynamic>;

    return Note.fromJson(json);
  }

  Future<Note> update(int noteId, String body) async {
    final uri = _project.buildUri(
      ['issues', _iid, 'notes', noteId.toString()],
      queryParameters: {"body": body},
    );

    final json = await _gitLab.request(uri, method: HttpMethod.put)
        as Map<String, dynamic>;

    return Note.fromJson(json);
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

  static List<Note> fromJsonList(List notes) => notes
      .map((n) => n is Map<String, dynamic> ? Note.fromJson(n) : null)
      .where((note) => note != null)
      .toList();

  final int id;
  String type;
  String body;

  Author author;

  DateTime createdAt;
  DateTime updatedAt;

  bool isSystemNote;

  int noteableId;
  String noteableType;
  int noteableIid;
}

class Author {
  Author.fromJson(Map<String, dynamic> author)
      : id = author.getIntOrNull("id"),
        name = author.getStringOrNull("name"),
        username = author.getStringOrNull("username"),
        state = author.getStringOrNull("state"),
        avatarUrl = author.getStringOrNull("avatar_url"),
        webUrl = author.getStringOrNull("web_url");

  final int id;
  String name;
  String username;
  String state;
  String avatarUrl;
  String webUrl;
}
