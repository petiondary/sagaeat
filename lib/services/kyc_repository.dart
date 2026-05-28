import 'package:dio/dio.dart';
import 'api_client.dart';

class KycRepository {
  KycRepository._();

  static Future<Map<String, dynamic>> getStatus() async {
    final resp = await ApiClient.dio.get('/kyc/status');
    return resp.data as Map<String, dynamic>;
  }

  static Future<void> submit({
    required String nom,
    required String prenom,
    required String dateNaissance,
    required String lieuNaissance,
    required String docType,
    required String docRectoPath,
    String? docVersoPath,
    required String selfiePath,
  }) async {
    final form = FormData.fromMap({
      'nom': nom,
      'prenom': prenom,
      'date_naissance': dateNaissance,
      'lieu_naissance': lieuNaissance,
      'doc_type': docType,
      'doc_recto': await MultipartFile.fromFile(
        docRectoPath,
        filename: 'doc_recto.jpg',
      ),
      if (docVersoPath != null)
        'doc_verso': await MultipartFile.fromFile(
          docVersoPath,
          filename: 'doc_verso.jpg',
        ),
      'selfie': await MultipartFile.fromFile(
        selfiePath,
        filename: 'selfie.jpg',
      ),
    });

    await ApiClient.dio.post('/kyc/submit', data: form);
  }
}
