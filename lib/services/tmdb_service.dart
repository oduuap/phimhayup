import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:phimhayokup/config/app_config.dart';
import 'package:phimhayokup/models/movie.dart';
import 'package:phimhayokup/models/movie_detail.dart';
import 'package:phimhayokup/models/person.dart';

class TmdbException implements Exception {
  final String message;
  const TmdbException(this.message);
  @override
  String toString() => message;
}

http.Client _buildClient() {
  final inner = HttpClient()
    ..connectionTimeout = const Duration(seconds: 20);
  return IOClient(inner);
}

class TmdbService {
  final http.Client _client;

  TmdbService({http.Client? client}) : _client = client ?? _buildClient();

  static const Map<String, String> _headers = {
    'Authorization': 'Bearer ${AppConfig.tmdbBearerToken}',
    'accept': 'application/json',
  };

  Uri _buildUri(String path, [Map<String, String>? extra]) {
    final params = {'language': AppConfig.language, ...?extra};
    return Uri.parse('${AppConfig.tmdbBaseUrl}$path')
        .replace(queryParameters: params);
  }

  Future<Map<String, dynamic>> _get(String path,
      [Map<String, String>? extra]) async {
    final uri = _buildUri(path, extra);
    debugPrint('[TMDB] GET $path');
    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 30));
      debugPrint('[TMDB] ${response.statusCode} $path');
      if (response.statusCode != 200) {
        throw TmdbException('Lỗi API: ${response.statusCode}');
      }
      return json.decode(response.body) as Map<String, dynamic>;
    } on SocketException catch (e) {
      debugPrint('[TMDB] Network error: $e');
      throw TmdbException('Không có kết nối mạng');
    } catch (e) {
      debugPrint('[TMDB] Exception: $e');
      rethrow;
    }
  }

  Future<List<Movie>> getTrending({String timeWindow = 'week'}) async {
    final data = await _get('/trending/movie/$timeWindow');
    return _parseMovieList(data);
  }

  Future<List<Movie>> getPopular({int page = 1}) async {
    final data = await _get('/movie/popular', {'page': '$page'});
    return _parseMovieList(data);
  }

  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final data = await _get('/movie/now_playing', {'page': '$page'});
    return _parseMovieList(data);
  }

  Future<List<Movie>> getTopRated({int page = 1}) async {
    final data = await _get('/movie/top_rated', {'page': '$page'});
    return _parseMovieList(data);
  }

  Future<List<Movie>> getUpcoming({int page = 1}) async {
    final data = await _get('/movie/upcoming', {'page': '$page'});
    return _parseMovieList(data);
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final data = await _get('/search/movie', {
      'query': query,
      'page': '$page',
      'include_adult': 'false',
    });
    return _parseMovieList(data);
  }

  Future<MovieDetail> getMovieDetail(int id) async {
    final data = await _get('/movie/$id', {
      'append_to_response': 'videos,credits,similar',
    });
    return MovieDetail.fromJson(data);
  }

  Future<PersonDetail> getPersonDetail(int id) async {
    final data = await _get('/person/$id', {
      'append_to_response': 'movie_credits',
    });
    return PersonDetail.fromJson(data);
  }

  Future<List<Movie>> getByGenre(int genreId, {int page = 1}) async {
    final data = await _get('/discover/movie', {
      'with_genres': '$genreId',
      'page': '$page',
      'sort_by': 'popularity.desc',
    });
    return _parseMovieList(data);
  }

  List<Movie> _parseMovieList(Map<String, dynamic> data) {
    final results = data['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
