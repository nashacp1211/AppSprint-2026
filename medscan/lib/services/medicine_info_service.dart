import 'dart:convert';

import 'package:http/http.dart' as http;

class MedicineInfo {
  final String name;
  final String rxcui;
  final String synonym;

  final String uses;
  final String sideEffects;
  final String warnings;

  MedicineInfo({
    required this.name,
    required this.rxcui,
    required this.synonym,
    required this.uses,
    required this.sideEffects,
    required this.warnings,
  });
}

class MedicineInfoService {
  static const String rxNormUrl =
      'https://rxnav.nlm.nih.gov/REST';

  static const String fdaUrl =
      'https://api.fda.gov/drug/label.json';

  // =========================================================
  // SEARCH MEDICINE
  // =========================================================

  static Future<MedicineInfo?> searchMedicine(
    String medicineName,
  ) async {
    final cleanedName =
        _cleanMedicineName(medicineName);

    if (cleanedName.isEmpty ||
        cleanedName.toLowerCase() == 'unknown') {
      return null;
    }

    // Only use exact / normalized matching.
    // We do NOT automatically accept approximate matches.
    final rxResult =
        await _exactOrNormalizedSearch(cleanedName);

    if (rxResult == null) {
      return null;
    }

    // Get information from FDA labeling.
    final label =
        await _getFdaInformation(cleanedName);

    return MedicineInfo(
      name: rxResult.name,
      rxcui: rxResult.rxcui,
      synonym: rxResult.synonym,
      uses: label['uses'] ?? '',
      sideEffects: label['sideEffects'] ?? '',
      warnings: label['warnings'] ?? '',
    );
  }

  // =========================================================
  // EXACT / NORMALIZED RXNORM SEARCH
  // =========================================================

  static Future<MedicineInfo?>
      _exactOrNormalizedSearch(
    String medicineName,
  ) async {
    try {
      final uri = Uri.parse(
        '$rxNormUrl/rxcui.json',
      ).replace(
        queryParameters: {
          'name': medicineName,
          'search': '2',
          'allsrc': '0',
        },
      );

      final response =
          await http.get(uri);

      if (response.statusCode != 200) {
        return null;
      }

      final data =
          jsonDecode(response.body);

      final idGroup =
          data['idGroup'];

      if (idGroup == null) {
        return null;
      }

      final rxNormId =
          idGroup['rxnormId'];

      if (rxNormId == null ||
          rxNormId is! List ||
          rxNormId.isEmpty) {
        return null;
      }

      final rxcui =
          rxNormId.first.toString();

      return await _getDrugDetails(rxcui);
    } catch (e) {
      return null;
    }
  }

  // =========================================================
  // GET RXNORM DRUG DETAILS
  // =========================================================

  static Future<MedicineInfo?>
      _getDrugDetails(
    String rxcui,
  ) async {
    try {
      final uri = Uri.parse(
        '$rxNormUrl/rxcui/$rxcui/property.json',
      ).replace(
        queryParameters: {
          'propName': 'RxNorm Name',
        },
      );

      final response =
          await http.get(uri);

      if (response.statusCode != 200) {
        return null;
      }

      final data =
          jsonDecode(response.body);

      final properties =
          data['propConcept'];

      String name = '';

      if (properties != null &&
          properties is List &&
          properties.isNotEmpty) {
        final first =
            properties.first;

        name =
            first['propValue']
                    ?.toString() ??
                '';
      }

      if (name.isEmpty) {
        return null;
      }

      return MedicineInfo(
        name: name,
        rxcui: rxcui,
        synonym: '',
        uses: '',
        sideEffects: '',
        warnings: '',
      );
    } catch (e) {
      return null;
    }
  }

  // =========================================================
  // GET FDA MEDICINE INFORMATION
  // =========================================================

  static Future<Map<String, String>>
      _getFdaInformation(
    String medicineName,
  ) async {
    try {
      final encodedName =
          Uri.encodeQueryComponent(
        medicineName,
      );

      final url =
          '$fdaUrl?search=openfda.generic_name:$encodedName'
          '&limit=1';

      final response =
          await http.get(
        Uri.parse(url),
      );

      if (response.statusCode != 200) {
        return {};
      }

      final data =
          jsonDecode(response.body);

      final results =
          data['results'];

      if (results == null ||
          results is! List ||
          results.isEmpty) {
        return {};
      }

      final result =
          results.first;

      final uses =
          _getTextFromField(
        result['indications_and_usage'],
      );

      final purpose =
          _getTextFromField(
        result['purpose'],
      );

      final sideEffects =
          _getTextFromField(
        result['adverse_reactions'],
      );

      final warnings =
          _getTextFromField(
        result['warnings'],
      );

      final boxedWarning =
          _getTextFromField(
        result['boxed_warning'],
      );

      final contraindications =
          _getTextFromField(
        result['contraindications'],
      );

      return {
        'uses':
            uses.isNotEmpty
                ? uses
                : purpose,

        'sideEffects':
            sideEffects,

        'warnings':
            warnings.isNotEmpty
                ? warnings
                : boxedWarning.isNotEmpty
                    ? boxedWarning
                    : contraindications,
      };
    } catch (e) {
      return {};
    }
  }

  // =========================================================
  // GET TEXT FROM FDA FIELD
  // =========================================================

  static String _getTextFromField(
    dynamic value,
  ) {
    if (value is List &&
        value.isNotEmpty) {
      final text =
          value.first.toString().trim();

      if (text.isNotEmpty) {
        return _cleanLabelText(text);
      }
    }

    if (value is String &&
        value.trim().isNotEmpty) {
      return _cleanLabelText(
        value.trim(),
      );
    }

    return '';
  }

  // =========================================================
  // CLEAN FDA TEXT
  // =========================================================

  static String _cleanLabelText(
    String text,
  ) {
    String cleaned = text;

    cleaned =
        cleaned.replaceAll(
      RegExp(r'<[^>]*>'),
      '',
    );

    cleaned =
        cleaned.replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    return cleaned.trim();
  }

  // =========================================================
  // CLEAN OCR MEDICINE NAME
  // =========================================================

  static String _cleanMedicineName(
    String name,
  ) {
    String cleaned =
        name.trim();

    cleaned =
        cleaned.replaceAll(
      RegExp(
        r'\b\d+(?:\.\d+)?\s*'
        r'(mg|mcg|g|ml|%)\b',
        caseSensitive: false,
      ),
      '',
    );

    cleaned =
        cleaned.replaceAll(
      RegExp(
        r'\b(tablets?|capsules?|syrup|'
        r'injection|suspension|cream|'
        r'ointment|tablet|capsule)\b',
        caseSensitive: false,
      ),
      '',
    );

    cleaned =
        cleaned.replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    return cleaned.trim();
  }
}
