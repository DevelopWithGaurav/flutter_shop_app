import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3_flutter/providers/cart.dart';
import 'package:shop_app_3_flutter/providers/products.dart';
import 'package:shop_app_3_flutter/screens/cart_screen.dart';
import 'package:shop_app_3_flutter/widgets/app_drawer.dart';
import 'package:shop_app_3_flutter/widgets/badge.dart';

import '../widgets/products_grid.dart';

enum FilterOptions { favourites, all }

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({super.key});

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavourites = false;

  // var _isInit = true;

  var _isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
    } catch (error) {
      _showErrorDialog('Http Error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('An error occurred!!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  //   }
  //   _isInit = false;
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == FilterOptions.favourites) {
                setState(() {
                  _showOnlyFavourites = true;
                });
              } else {
                setState(() {
                  _showOnlyFavourites = false;
                });
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterOptions.favourites,
                child: Text('Favourites Products'),
              ),
              const PopupMenuItem(
                value: FilterOptions.all,
                child: Text('All Products'),
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (context, value, ch) => Badge(
              value: value.itemCount.toString(),
              child: ch!,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProductsGrid(_showOnlyFavourites),
    );
  }
}
