import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Currency> fetchCurrency() async {
  final response = await http
      .get(Uri.parse('https://sovcombank.scipie.ru/api/users/2/'));

  if(response.statusCode == 200)
  {
    return Currency.fromJson(jsonDecode(response.body));
  }
  else
  {
    throw Exception('Failed to load album');
  }
}

class Currency {
  int? id;
  Currency? currency;
  int? amount;
  int? userId;

  Currency({this.id, this.currency, this.amount, this.userId});

  Currency.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currency = json['currency'] != null
        ? new Currency.fromJson(json['currency'])
        : null;
    amount = json['amount'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.currency != null) {
      data['currency'] = this.currency!.toJson();
    }
    data['amount'] = this.amount;
    data['user_id'] = this.userId;
    return data;
  }
}
