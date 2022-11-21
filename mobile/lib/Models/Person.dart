import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sovkombank/Models/Currency.dart';
import 'package:sovkombank/MyWidgets/Account.dart';

Future<AllAccount> getAllAccounts(FlutterSecureStorage storage) async {
  final response = await http.get(
    Uri.parse('https://sovcombank.scipie.ru/api/currencies/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-access-token': (await storage.read(key:"jwt"))!,
    },
  );
  if (response.statusCode == 200) {
    return AllAccount.fromJsonList(jsonDecode(response.body));
  }
  else {
    throw Exception('Failed to load currencies');
  }
}

//...
//Господи, за что мне product Manager в команде...
//...

Future<allShowRate> fetchBuyTickets(
    FlutterSecureStorage storage,
    )
async
{
  final response = await http.get(
    Uri.parse('https://sovcombank.scipie.ru/api/rates/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-access-token': (await storage.read(key: "jwt"))!,
    },
  );
  if (response.statusCode == 200) {
    return allShowRate.fromJson(jsonDecode(response.body));
  }
  else {
    throw Exception('Failed to load ShowRate');
  }
}

Future<Accounts> addNewAccount(
    String currencyTag,
    int userId,
    FlutterSecureStorage storage,
    )
async
{
  final response = await http.post(
    Uri.parse('https://sovcombank.scipie.ru/api/accounts/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-access-token': (await storage.read(key: "jwt"))!,
    },
    body: jsonEncode(<String, dynamic>{
      "currency_tag": currencyTag,
      "user_id": userId,
    }),
  );
  if (response.statusCode == 201) {
    return Accounts.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to add new account.');
  }
}

Future<PersonToken> signInPerson (
    String phone,
    String password,
    )
async
{
  final response = await http.post(
    Uri.parse('https://sovcombank.scipie.ru/api/users/login/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      "phone": phone,
      "password": password,
    }),
  );

  if (response.statusCode == 201) {
    return PersonToken.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 400) {
    throw Exception('Invalid request');
  }
  else if (response.statusCode == 401) {
    throw Exception('user does not exist');
  }
  else if (response.statusCode == 403) {
    throw Exception('user is non active or password is wrong');
  }
  else {
    throw Exception('Failed to sign in');
  }
}

Future<Person> changeMoney(
    int accountId,
    int value,
    FlutterSecureStorage storage,
)
async
{
  final response = await http.post (
    Uri.parse('https://sovcombank.scipie.ru/api/cash/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-access-token': (await storage.read(key:"jwt"))!,
      },
    body: jsonEncode(<String, int>{
      "account_id" : accountId,
      "value" : value,
    }),
  );
  
  if (response.statusCode == 200) {
    return Person.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to change money balance.');
  }
}

Future<Person> createPerson (
    String phone,
    String passport,
    String firstName,
    String secondName,
    String fatherName,
    String password
    )
async
{
  final response = await http.post(
    Uri.parse('https://sovcombank.scipie.ru/api/users/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      "phone": phone,
      "passport": passport,
      "first_name": firstName,
      "second_name": secondName,
      "father_name": fatherName,
      "password": password,
    }),
  );

  if (response.statusCode == 201) {
    return Person.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create person.');
  }
}

Future<Person> fetchPerson(FlutterSecureStorage storage) async {

  final response = await http
      .get(
      Uri.parse('https://sovcombank.scipie.ru/api/users/1/'),
      headers: <String, String>{
        'x-access-token': (await storage.read(key:"jwt"))!,
      }
  );


  if (response.statusCode == 200) {
    return Person.fromJson(jsonDecode(response.body));
  }
  else {
    throw Exception('Failed to load person');
  }
}


class PersonToken {
  String? token;

  PersonToken({
    this.token,
  });

  PersonToken.fromJson(Map<String, dynamic> json) {
    token = json['token'];
  }
}

class Person {
  List<Accounts>? accounts;
  String? fatherName;
  String? firstName;
  int? id;
  String? passport;
  String? phone;
  String? secondName;
  String? status;

  Person(
      {this.accounts,
        this.fatherName,
        this.firstName,
        this.id,
        this.passport,
        this.phone,
        this.secondName,
        this.status});

  factory Person.fromJson(Map<String, dynamic> json) {
    Person pers = new Person();
    pers.accounts = <Accounts>[];
    json['accounts'].forEach((v) {
      pers.accounts!.add(new Accounts.fromJson(v));
    });
    pers.fatherName = json['father_name'];
    pers.firstName = json['first_name'];
    pers.id = json['id'];
    pers.passport = json['passport'];
    pers.phone = json['phone'];
    pers.secondName = json['second_name'];
    pers.status = json['status'];
    return pers;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.accounts != null) {
      data['accounts'] = this.accounts!.map((v) => v.toJson()).toList();
    }
    data['father_name'] = this.fatherName;
    data['first_name'] = this.firstName;
    data['id'] = this.id;
    data['passport'] = this.passport;
    data['phone'] = this.phone;
    data['second_name'] = this.secondName;
    data['status'] = this.status;
    return data;
  }
}

class AllAccount{
  List<Currency>? curr;
  AllAccount({this.curr});
  factory AllAccount.fromJsonList(dynamic json) {
    AllAccount temp = new AllAccount();
    List<Currency> currency = <Currency>[];
    json.forEach((v) {
      currency.add(new Currency.fromJson(v));
    });
    temp.curr = currency;
    return temp;
  }
}


class Accounts {
  int? amount;
  Currency? currency;
  int? id;
  int? userId;

  Accounts({this.amount, this.currency, this.id, this.userId});

  Accounts.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    currency = json['currency'] != null
        ? new Currency.fromJson(json['currency'])
        : null;
    id = json['id'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    if (this.currency != null) {
      data['currency'] = this.currency!.toJson();
    }
    data['id'] = this.id;
    data['user_id'] = this.userId;
    return data;
  }
}
class allShowRate{
  List<ShowRate>? show;
  allShowRate({this.show});
  factory allShowRate.fromJson(dynamic json) {
    allShowRate temp = new allShowRate();
    List<ShowRate> showRate = <ShowRate>[];
    json.forEach((v) {
      showRate.add(new ShowRate.fromJson(v));
    });
    temp.show = showRate;
    return temp;
  }
}
class ShowRate{
  String? tag;
  double? rate;

  ShowRate({this.rate, this.tag});

  ShowRate.fromJson(Map<String, dynamic> json) {
    tag = json['to_tag'];
    rate = json['rate'];
  }
}

class Rate {

  int? fromId;
  int? toId;
  int? rate;

  Rate({this.fromId, this.rate, this.toId});

  Rate.fromJson(Map<String, dynamic> json) {
    fromId = json['from_id'];
    toId = json['to_id'];
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from_id'] = this.fromId;
    data['toId'] = this.toId;
    data['rate'] = this.rate;
    return data;
  }
}
class Currency {
  String? name;
  String? tag;

  Currency({this.name, this.tag});

  Currency.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    tag = json['tag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['tag'] = this.tag;
    return data;
  }
}