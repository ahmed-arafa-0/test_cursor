import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:csv/csv.dart';

Future<List<Map<String, String>>> fetchSheetByGid(String gid) async {
  try {
    final String _spreadsheetId =
        '1mxAn5hS4bk_bX3_dwFERS_vpgnMj3dgN0bec3TRXDtA';
    final url =
        'https://docs.google.com/spreadsheets/d/$_spreadsheetId/export?format=csv&gid=$gid';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      debugPrint('Failed to fetch sheet: ${response.statusCode}');
      return [];
    }

    final csvText = utf8.decode(response.bodyBytes);
    final rows = const CsvToListConverter(eol: '\n').convert(csvText);

    if (rows.isEmpty || rows.length < 2) {
      debugPrint('No data found in sheet');
      return [];
    }

    final headers = rows.first.map((h) => h.toString().trim()).toList();
    final dataRows = rows.skip(1);

    return dataRows.map((row) {
      final map = <String, String>{};
      for (var i = 0; i < headers.length; i++) {
        final header = headers[i];
        final value = i < row.length ? row[i].toString().trim() : '';
        map[header] = value;
      }
      return map;
    }).toList();
  } catch (e) {
    debugPrint('Error fetching sheet: $e');
    return [];
  }
}
