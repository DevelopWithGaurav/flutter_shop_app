import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3_flutter/providers/products.dart';
import 'package:shop_app_3_flutter/screens/edit_product_screen.dart';
import 'package:shop_app_3_flutter/widgets/app_drawer.dart';
import 'package:shop_app_3_flutter/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  const UserProductsScreen({super.key});

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, EditProductScreen.routeName,
                  arguments: 'false');
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (context, productsData, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          // shrinkWrap: true,
                          itemCount: productsData.items.length,
                          itemBuilder: (context, i) => UserProductItem(
                            title: productsData.items[i].title,
                            urlImage: productsData.items[i].imageUrl,
                            id: productsData.items[i].id,
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
