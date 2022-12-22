import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/products_grid.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';

enum filterOption{
  Favorite,
  All,
}

class ProductOverviewScreen extends StatefulWidget {

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {

  bool _showOnlyFavorite = false;

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop App'),
        actions: [
          Consumer<Cart>(
              builder: (ctx,cart,_)=>Badge(child: IconButton(icon: Icon(Icons.shopping_cart),onPressed: (){},), value: cart.quantity.toString())),
          PopupMenuButton(
            itemBuilder: (ctx)=>[
            PopupMenuItem(child: Text('Only Favorite'),value: filterOption.Favorite,),
            PopupMenuItem(child: Text('Show All'),value: filterOption.All,),
          ],
            icon: Icon(Icons.more_vert_rounded),
            onSelected: (filterOption selectedValue){

            setState(() {
              if(selectedValue == filterOption.Favorite){
                _showOnlyFavorite = true;
              }else{
                _showOnlyFavorite = false;
              }}
            );
            },
          ),
        ],
      ),
      body: ProductsGrid(_showOnlyFavorite),
    );
  }
}

