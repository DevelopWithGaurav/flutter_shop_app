import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3_flutter/providers/cart.dart' show Cart;
import 'package:shop_app_3_flutter/providers/orders.dart';

import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  // const Spacer(),
                  Chip(
                    label: Text(
                      '\$ ${cart.totalAmount.toStringAsFixed(2)}',
                    ),
                  ),
                  // const Spacer(),
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (cart.items.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: cart.itemCount,
                itemBuilder: (context, i) => CartItem(
                  id: cart.items.values.toList()[i].id,
                  title: cart.items.values.toList()[i].title,
                  quantity: cart.items.values.toList()[i].quantity,
                  price: cart.items.values.toList()[i].price,
                  productId: cart.items.keys.toList()[i],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                widget.cart.items.values.toList(),
                widget.cart.totalAmount,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clearCart();
            },
      child: _isLoading ? const CircularProgressIndicator() : const Text('ORDER NOW'),
    );
  }
}
