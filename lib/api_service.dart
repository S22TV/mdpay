import 'dart:convert';

import 'config.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiService {
  static String get baseUrl => AppConfig.mobileApiUrl;

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'mdpay_token';

  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<void> _saveToken(String t) =>
      _storage.write(key: _tokenKey, value: t);
  static Future<void> logout() => _storage.delete(key: _tokenKey);

  /// Бүх action энэ нэг функцээр дамжина
  static Future<Map<String, dynamic>> _call(
    String action, {
    Map<String, dynamic> data = const {},
    bool auth = true,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token == null) throw ApiException('Нэвтэрнэ үү', 401);
      headers['Authorization'] = 'Bearer $token';
    }

    final http.Response res;
    try {
      res = await http
          .post(
            Uri.parse(baseUrl),
            headers: headers,
            body: jsonEncode({'action': action, ...data}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw ApiException('Сервертэй холбогдож чадсангүй');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      if (res.statusCode == 401 && auth) await logout(); // token хүчингүй
      throw ApiException(json['error'] ?? 'Алдаа гарлаа', res.statusCode);
    }
    return json;
  }

  // ---------- Auth ----------
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final json = await _call(
      'login',
      data: {'email': email, 'password': password},
      auth: false,
    );
    await _saveToken(json['token']);
    return json['user'];
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String type = 'PERSONAL',
    String? businessName,
  }) async {
    final json = await _call(
      'register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'type': type,
        if (businessName != null) 'businessName': businessName,
      },
      auth: false,
    );
    await _saveToken(json['token']);
    return json['user'];
  }

  static Future<Map<String, dynamic>> me() => _call('me');
  static Future<Map<String, dynamic>> summary() => _call('summary');

  static Future<List<dynamic>> transactions() async =>
      (await _call('transactions'))['transactions'];

  static Future<List<dynamic>> invoices() async =>
      (await _call('invoices'))['invoices'];

  static Future<Map<String, dynamic>> createInvoice(
    String amount, {
    String? description,
  }) => _call(
    'create_invoice',
    data: {
      'amount': amount,
      if (description != null) 'description': description,
    },
  );
  static Future<Map<String, dynamic>> lookupAccount(
    String accountNumber,
  ) async => (await _call(
    'lookup_account',
    data: {'accountNumber': accountNumber},
  ))['account'];

  static Future<Map<String, dynamic>> transfer({
    required String accountNumber,
    required String amount,
    required String password,
    String? note,
  }) => _call(
    'transfer',
    data: {
      'accountNumber': accountNumber,
      'amount': amount,
      'password': password,
      if (note != null && note.isNotEmpty) 'note': note,
    },
  );
  static bool _isIncome(String kind) {
    const incomeKinds = {'income', 'credit', 'deposit', 'topup', 'transfer_in'};
    return incomeKinds.contains(kind.toLowerCase());
  }

  Future<Map<String, dynamic>> sendRequest(
    String action,
    Map<String, dynamic> data,
  ) async {
    try {
      switch (action) {
        case 'login':
        case 'register':
          final user = action == 'login'
              ? await ApiService.login(data['email'], data['password'])
              : await ApiService.register(
                  name: data['name'],
                  email: data['email'],
                  password: data['password'],
                  type: data['type'] ?? 'PERSONAL',
                  businessName: data['businessName'],
                );
          try {
            final s = await ApiService.summary();
            user['wallet_id'] = s['walletId'];
          } catch (_) {}
          return {'status': 'success', 'user': user};

        case 'get_dashboard':
          final s = await ApiService.summary();
          final txs = await ApiService.transactions();
          final invs = await ApiService.invoices();
          return {
            'status': 'success',
            'balance': s['balance'],
            'pending_invoices_count': s['pendingInvoices'] ?? 0,
            'recent_transactions_count': txs.length,
            'invoices': invs
                .map(
                  (i) => {
                    'id': int.tryParse('${i['id']}'),
                    'description': i['description'] ?? '',
                    'amount': i['amount'],
                    'status': i['status'],
                    'sender_email': '',
                    'receiver_email': '',
                    'qr_code': 'MDPAY_INV_${i['id']}',
                  },
                )
                .toList(),
            'transactions': txs
                .map(
                  (t) => {
                    'type': _isIncome('${t['kind']}') ? 'INCOME' : 'EXPENSE',
                    'title': (t['note'] ?? '').toString().isEmpty
                        ? '${t['kind']}'
                        : t['note'],
                    'counterparty': t['counterpartyName'] ?? '',
                    'date': '${t['createdAt']}'.split('T').first,
                    'amount': t['amount'],
                  },
                )
                .toList(),
          };

        case 'generate_qr':
          if (data['qr_type'] == 'QUICK') {
            return {
              'status': 'error',
              'message': 'QuickPay (дүнгүй) QR серверт хараахан хийгдээгүй',
            };
          }
          final r = await ApiService.createInvoice(
            '${data['amount']}',
            description: data['description'],
          );
          return {'status': 'success', 'qr_code': r['qrText']};
        case 'lookup_account':
          final acc = await ApiService.lookupAccount(
            '${data['accountNumber']}',
          );
          return {'status': 'success', 'account': acc};

        case 'transfer':
          await ApiService.transfer(
            accountNumber: '${data['accountNumber']}',
            amount: '${data['amount']}',
            password: '${data['password']}',
            note: data['note'],
          );
          return {'status': 'success', 'message': 'Шилжүүлэг амжилттай'};
        default:
          return {
            'status': 'error',
            'message': 'Энэ үйлдэл серверт хараахан хийгдээгүй ($action)',
          };
      }
    } on ApiException catch (e) {
      return {'status': 'error', 'message': e.message};
    }
  }
}
