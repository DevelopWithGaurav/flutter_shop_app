import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3_flutter/providers/orders.dart' show Orders;

import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;

  @override
  void initState() {
    super.initState();

    _isLoading = true;

    Provider.of<Orders>(context, listen: false)
        .fetchAndSetOrders()
        .then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orderData.orders.length,
              itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
            ),
    );
  }
}
