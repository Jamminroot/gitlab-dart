part of exitlive.gitlab;

class ProjectsApi {
  final GitLab _gitLab;

  final int? id;

  ProjectsApi(this._gitLab, this.id);

  MergeRequestsApi? _mergeRequestsApi;
  MergeRequestsApi get mergeRequests => _mergeRequestsApi ??= new MergeRequestsApi(_gitLab, this);

  IssuesApi? _issuesApi;
  IssuesApi get issues => _issuesApi ??= new IssuesApi(_gitLab, this);

  /// Get the [IssueNotesApi] for an [issue].
  ///
  /// This call doesn't do anything by itself, other than return the
  /// configured object.
  /// You can safely store the returned object and reuse it.
  IssueNotesApi issueNotes(Issue issue) => issueNotesByIid(issue.iid);

  /// Get the [IssueNotesApi] for an [issueIid].
  ///
  /// This call doesn't do anything by itself, other than return the
  /// configured object.
  /// You can safely store the returned object and reuse it.
  IssueNotesApi issueNotesByIid(int issueIid) => IssueNotesApi(
        _gitLab,
        this,
        issueIid,
      );

  /// Get the [IssueDiscussionsApi] for an [issue].
  ///
  /// This call doesn't do anything by itself, other than return the
  /// configured object.
  /// You can safely store the returned object and reuse it.
  IssueDiscussionsApi issueDiscussions(Issue issue) => issueDiscussionsByIid(issue.iid);

  /// Get the [IssueDiscussionsApi] for an [issueIid].
  ///
  /// This call doesn't do anything by itself, other than return the
  /// configured object.
  /// You can safely store the returned object and reuse it.
  IssueDiscussionsApi issueDiscussionsByIid(int issueIid) => IssueDiscussionsApi(
        _gitLab,
        this,
        issueIid,
      );

  SnippetsApi? _snippetsApi;
  SnippetsApi get snippets => _snippetsApi ??= new SnippetsApi(_gitLab, this);

  CommitsApi? _commitsApi;
  CommitsApi get commits => _commitsApi ??= new CommitsApi(_gitLab, this);

  JobsApi? _jobsApi;
  JobsApi get jobs => _jobsApi ??= new JobsApi(_gitLab, this);

  PipelinesApi? _pipelinesApi;
  PipelinesApi get pipelines => _pipelinesApi ??= new PipelinesApi(_gitLab, this);

  @visibleForTesting
  Uri buildUri(Iterable<String> pathSegments, {Map<String, dynamic>? queryParameters, int? page, int? perPage}) =>
      _gitLab.buildUri(['projects', '$id']..addAll(pathSegments), queryParameters: queryParameters, page: page, perPage: perPage);
}
