import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../storage/storage_service.dart';
import 'api_exception.dart';

/// Kiungo pekee cha mawasiliano na Backend (menta-finance-backend, Spring
/// Boot). Kila 'store'/'service' nyingine yote inapitia hapa - hakuna
/// sehemu nyingine ya app inayotakiwa kutumia HTTP moja kwa moja.
class ApiClient {
  final ChopperClient _client;
  final StorageService _storage;

  /// Inaitwa na main.dart kila ombi litakaporudisha 401 (token imeisha
  /// muda/si sahihi) - inasafisha session na kumrudisha mtumiaji kwenye
  /// ukurasa wa Login. Haijawekwa hapa moja kwa moja (bila GetX) ili
  /// safu hii (core/network) isitegemee moja kwa moja safu ya routing.
  void Function()? onUnauthorized;

  ApiClient({required StorageService storage})
      : _storage = storage,
        _client = ChopperClient(
          baseUrl: Uri.parse(AppConfig.baseUrl),
        );

  Map<String, String> _headers({bool auth = true, bool multipart = false}) {
    final headers = <String, String>{};
    if (!multipart) headers['Content-Type'] = 'application/json';
    headers['Accept'] = 'application/json';
    if (auth) {
      final token = _storage.token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    Map<String, String>? cleanQuery;
    if (query != null && query.isNotEmpty) {
      final mapped = <String, String>{};
      for (final entry in query.entries) {
        final value = entry.value;
        if (value != null) mapped[entry.key] = value.toString();
      }
      if (mapped.isNotEmpty) cleanQuery = mapped;
    }
    return Uri.parse('${AppConfig.baseUrl}$path').replace(queryParameters: cleanQuery);
  }

  /// Ujumbe wa default kwa status code za kawaida - unatumika TU kama
  /// backend haikurudisha body yenye maana (mfano 403 kutoka
  /// @PreAuthorize ambayo Spring inarudisha mwili mtupu - body tupu).
  String _defaultMessageForCode(int code) {
    switch (code) {
      case 401:
        return 'Muda wako wa kuingia umeisha. Tafadhali ingia tena.';
      case 403:
        return 'Huna ruhusa ya kufanya kitendo hiki.';
      case 404:
        return 'Taarifa hii haikupatikana.';
      case 500:
      case 502:
      case 503:
        return 'Hitilafu ya mfumo. Tafadhali jaribu tena baadaye.';
      default:
        return 'Hitilafu ya mfumo (code $code).';
    }
  }

  /// Backend (GlobalExceptionHandler) inarudisha makosa kwa njia mbili:
  ///   1) {"error": "ujumbe"} - kwa ResourceNotFound/BusinessRule/Auth
  ///   2) {"fieldA": "ujumbe1", "fieldB": "ujumbe2"} - kwa validation
  ///      (@Valid) - bila 'error' key, moja kwa moja field->message.
  String _parseErrorBody(String bodyStr, int code) {
    if (bodyStr.isEmpty) return _defaultMessageForCode(code);
    try {
      final decoded = jsonDecode(bodyStr);
      if (decoded is Map) {
        if (decoded['error'] != null) {
          return decoded['error'].toString();
        }
        if (decoded.isNotEmpty) {
          // Validation errors: field -> message. Tunaunganisha zote kwa
          // mkupuo mmoja, mfano: "Jina la client linahitajika".
          return decoded.values.map((v) => v.toString()).join('\n');
        }
      }
    } catch (_) {
      // body si JSON - tumia default
    }
    return _defaultMessageForCode(code);
  }

  Future<dynamic> _handle(Response response) {
    final code = response.statusCode;
    final bodyStr = _extractBodyString(response);

    if (code >= 200 && code < 300) {
      if (bodyStr.isEmpty) return Future.value(null);
      try {
        return Future.value(jsonDecode(bodyStr));
      } catch (_) {
        return Future.value(bodyStr);
      }
    }

    if (code == 401) {
      // Token imeisha muda / si sahihi - safisha session na mrudishe
      // mtumiaji Login. Tunafanya hii KABLA ya ku-throw, ili kila mahali
      // penye 'try/catch' popote kwenye app pafikiwe na tabia moja.
      onUnauthorized?.call();
    }

    final message = _parseErrorBody(bodyStr, code);
    throw ApiException(message: message, statusCode: code);
  }

  /// Tunasoma moja kwa moja kutoka 'response.base' (http.BaseResponse
  /// halisi) badala ya 'response.body' ya chopper, kwa sababu 'body' ya
  /// chopper inategemea Converter (ambayo hatujaiweka - ApiClient hii
  /// inafanya jsonDecode/jsonEncode yenyewe), na 'base' ndiyo pekee
  /// iliyohakikishwa kuwepo kwenye kila toleo la chopper.
  String _extractBodyString(Response response) {
    final base = response.base;
    if (base is http.Response) {
      return base.body;
    }
    return '';
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    final request = Request('GET', _uri(path, query), _client.baseUrl, headers: _headers(auth: auth));
    final response = await _client.send(request);
    return _handle(response);
  }

  Future<List<int>> getBytes(String path, {bool auth = true, Map<String, dynamic>? query}) async {
    final request = Request('GET', _uri(path, query), _client.baseUrl, headers: _headers(auth: auth, multipart: true));
    final response = await _client.send(request);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final base = response.base;
      if (base is http.Response) return base.bodyBytes;
      return const <int>[];
    }
    if (response.statusCode == 401) onUnauthorized?.call();
    throw ApiException(
      message: _defaultMessageForCode(response.statusCode),
      statusCode: response.statusCode,
    );
  }

  Future<dynamic> post(String path, {Object? body, Map<String, dynamic>? query, bool auth = true}) async {
    final request = Request(
      'POST',
      _uri(path, query),
      _client.baseUrl,
      body: body == null ? null : jsonEncode(body),
      headers: _headers(auth: auth),
    );
    final response = await _client.send(request);
    return _handle(response);
  }

  Future<dynamic> put(String path, {Object? body, Map<String, dynamic>? query, bool auth = true}) async {
    final request = Request(
      'PUT',
      _uri(path, query),
      _client.baseUrl,
      body: body == null ? null : jsonEncode(body),
      headers: _headers(auth: auth),
    );
    final response = await _client.send(request);
    return _handle(response);
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    final request = Request('DELETE', _uri(path), _client.baseUrl, headers: _headers(auth: auth));
    final response = await _client.send(request);
    return _handle(response);
  }
}
