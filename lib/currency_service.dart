import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

class CurrencyService {
  final Dio _dio = Dio();
  final String url = 'https://api-v2.sp-today.com/api/v1/currencies';

  Future<Map<String, String>?> fetchDamascusDollarPrices() async {
    try {
      // جلب المفتاح مع وضع قيمة افتراضية آمنة
      final String realApiKey = dotenv.env['REAL_API_KEY'] ?? '';

      final response = await _dio.get(
        url,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
            'Accept': 'application/json',
            'X-API-Key': realApiKey,
          },
          // تحديد وقت أقصى للاتصال حتى لا يعلق التطبيق عند المراجع
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        if (data['data'] != null && data['data']['currencies'] != null) {
          final List currenciesList = data['data']['currencies'];
          
          // تعديل آمن للبحث لتجنب مشاكل الـ Null Safety والـ TypeError
          Map<String, dynamic>? usdCurrency;
          for (var element in currenciesList) {
            if (element is Map && element['code']?.toString().toUpperCase() == 'USD') {
              usdCurrency = Map<String, dynamic>.from(element);
              break;
            }
          }

          if (usdCurrency != null && usdCurrency['cities'] != null && usdCurrency['cities']['damascus'] != null) {
            final damascusData = usdCurrency['cities']['damascus'];
            
            return {
              'buy': damascusData['buy']?.toString() ?? '...',
              'sell': damascusData['sell']?.toString() ?? '...',
            };
          }
        }
      }
      
      // بدلاً من إرجاع null لانهائي يكسر الواجهة، نرجع قيم افتراضية آمنة أثناء الفحص
      return {'buy': '...', 'sell': '...'};
      
    } catch (e) {
      debugPrint('Error inside CurrencyService: $e');
      // نرجع قيم افتراضية لكي لا ينهار التطبيق (Crash) في وجه المراجع عند حدوث أي خطأ شبكة
      return {'buy': '...', 'sell': '...'};
    }
  }
}