import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shop_app_3_flutter/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.amount,
    required this.dateTime,
    required this.id,
    required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this._orders, this.userId);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
      'https://flutter-learn2-312ef-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken',
    );

    final response = await http.get(url);

    final List<OrderItem> loadedOrders = [];

    final extractedData = json.decode(response.body) as Map<String, dynamic>?;

    if (extractedData == null) {
      return;
    }

    extractedData.forEach((key, value) {
      loadedOrders.add(
        OrderItem(
          amount: value['amount'],
          dateTime: DateTime.parse(value['dateTime']),
          id: key,
          products: (value['products'] as List<dynamic>)
              .map((e) => CartItem(
                    id: e['id'],
                    title: e['title'],
                    quantity: e['quantity'],
                    price: e['price'],
                  ))
              .toList(),
        ),
      );
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
      'https://flutter-learn2-312ef-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken',
    );

    final timeStamp = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode(
        {
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price,
                  })
              .toList()
        },
      ),
    );

    _orders.insert(
      0,
      OrderItem(
        amount: total,
        dateTime: timeStamp,
        id: json.decode(response.body)['name'],
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
