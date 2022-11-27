import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shop_app_3_flutter/models/http_expection.dart';

import 'package:shop_app_3_flutter/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  String authToken;
  String userId;

  Products(this.authToken, this._items, this.userId);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouroteItems {
    return _items.where((element) => element.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
      'https://flutter-learn2-312ef-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken$filterString',
    );

    try {
      final response = await http.get(
        url,
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      if (extractedData == null) {
        return;
      }
      final favouriteResponse = await http.get(
        Uri.parse(
          'https://flutter-learn2-312ef-default-rtdb.asia-southeast1.firebasedatabase.app/userFavourites/$userId.json?auth=$authToken',
        ),
      );
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((key, value) {
        loadedProducts.add(Product(
          title: value['title'],
          id: key,
          description: value['description'],
          price: value['price'],
          imageUrl: value['imageUrl'],
          isFavourite:
              favouriteData == null ? false : favouriteData[key] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
      'https://flutter-learn2-312ef-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken',
    );
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );

      final newProduct = Product(
        title: product.title,
        id: json.decode(response.body)['name'],
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
        'https://flutter-learn2-312ef-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken',
      );
      // final url = Uri.https(
      //     'flutter-learn2-312ef-default-rtdb.asia-southeast1.firebasedatabase.app',
      //     '/products/$id.json');
      await http.patch(
        url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );

      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
      'https://flutter-learn2-312ef-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken',
    );

    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Couldn\'t delete product.');
    }
    existingProduct.dispose();
  }
}

// https://t3.ftcdn.net/jpg/01/41/81/30/360_F_141813016_vrZ4TFKphl7vLBty0kfQmIAEjFgtkJzW.jpg

// https://www.liveabout.com/thmb/j5EvkyiDhCT9lu1svon4P-u5pMo=/395x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-638316888-58bd8bc93df78c353c5b8631.jpg
