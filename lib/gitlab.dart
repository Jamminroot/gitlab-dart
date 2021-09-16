/// This library allows you to communicate with the GitLab api.
/// It supports the default `gitlab.com` but also any other GitLab deployment you might have.
///
/// Usage:
///
///     // Setup your gitLab or gitLabProject once.
///     final gitLab  = new GitLab(secretToken);
///     final gitLabProject = gitLab.project('exit-live');
///
///     // Then use it whenever you need in your app.
///     final allMergeRequests = await gitLabProject.mergeRequests.list();
///     final allIssues = await gitLabProject.issues.list(page: 3, perPage: 30);
///     final issue = await gitLabProject.issues.get(allIssues.first.id);
///
/// For more information, please refer to the
/// [official GitLab API documentation at gitlab.com](https://docs.gitlab.com/ee/api/README.html).
library exitlive.gitlab;

import 'dart:async';
import 'dart:convert';

import 'package:gitlab/src/http_client.dart';
import 'package:gitlab/src/json_map.ext.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

part 'src/commits.dart';
part 'src/discussions.dart';
part 'src/issues.dart';
part 'src/jobs.dart';
part 'src/merge_requests.dart';
part 'src/notes.dart';
part 'src/pipelines.dart';
part 'src/projects.dart';
part 'src/snippets.dart';
part 'src/utils.dart';

final _log = new Logger('GitLab');

enum HttpMethod { get, post, put, delete }

/// The main class and entry point to use this library.
///
/// See the library documentation for information on how to use it.
class GitLab {
  final String token;

  final String host;
  final String scheme;

  /// Assume utf8 within in response bodies.
  ///
  /// The response of current gitlab instances (checked with 12.7.0-pre)
  /// respond without specifying the encoding of the response within the
  /// content-type (the server responds with content-type: application/json).
  ///
  /// The default implementation of http Response does assume latin1 in such
  /// cases. Therefore any special characters are broken.
  ///
  /// In order to avoid this behavior, the utf8 charset, which actually is used
  /// by gitlab, will be appended to the content-type, thus the resulting header
  /// is content-type: application/json; charset=utf-8 and will be parsed
  /// correctly.
  ///
  /// This behavior is enabled by default, but one can disable it, because this
  /// field is introduced in a later version (v0.5.0) and might interfere with
  /// existing implementations.
  ///
  final bool assumeUtf8;

  final GitLabHttpClient _httpClient;

  static const String apiVersion = 'v4';

  GitLab(this.token, {this.host = 'gitlab.com', this.scheme = 'https', this.assumeUtf8 = true}) : _httpClient = new GitLabHttpClient();

  GitLab._test(GitLabHttpClient httpClient, this.token, {this.host: 'gitlab.com', this.scheme: 'https', this.assumeUtf8 = true}) : _httpClient = httpClient;

  /// Get the [ProjectsApi] for this [id].
  ///
  /// This call doesn't do anything by itself, other than return the configured object.
  /// You can safely store the returned object and reuse it.
  ProjectsApi project(int id) => new ProjectsApi(this, id);

  /// Returns the decoded JSON.
  @visibleForTesting
  Future<dynamic> request(Uri uri, {HttpMethod method: HttpMethod.get, String? body, bool asJson: true}) async {
    final headers = <String, String>{'PRIVATE-TOKEN': token};

    _log.fine('Making GitLab $method request to $uri.');

    final response = await _httpClient.request(uri, headers, method);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw new GitLabException(response.statusCode, response.body);
    }

    final contentType = response.headers["content-type"];
    final hasContentType = contentType != null;
    final hasCharset = contentType?.contains("charset") ?? false;
    if (assumeUtf8 && hasContentType && !hasCharset) {
      response.headers["content-type"] = "$contentType; charset=utf-8";
    }

    return asJson ? jsonDecode(response.body) : response.body;
  }

  /// This function is used internally to build the URIs for API calls.
  @visibleForTesting
  Uri buildUri(Iterable<String> pathSegments, {Map<String, dynamic>? queryParameters, int? page, int? perPage}) {
    dynamic _addQueryParameter(String key, dynamic value) => (queryParameters ??= new Map<String, dynamic>())[key] = '$value';

    if (page != null) _addQueryParameter('page', page);
    if (perPage != null) _addQueryParameter('per_page', perPage);
    return new Uri(scheme: scheme, host: host, pathSegments: ['api', apiVersion]..addAll(pathSegments), queryParameters: queryParameters);
  }
}

class GitLabException implements Exception {
  final int statusCode;
  final String message;

  GitLabException(this.statusCode, this.message);

  @override
  String toString() => 'GitLabException ($statusCode): $message';
}

/// A helper function to get a [GitLab] instance with a [GitLabHttpClient] that
/// can be mocked.
@visibleForTesting
GitLab getTestable(GitLabHttpClient httpClient, [String token = 'secret-token']) => new GitLab._test(httpClient, token);
