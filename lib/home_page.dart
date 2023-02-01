import 'package:beer_brewer/data/database_controller.dart';
import 'package:beer_brewer/products_overview.dart';
import 'package:beer_brewer/recipe/recipe_creator.dart';
import 'package:beer_brewer/recipe/recipes_overview.dart';
import 'package:flutter/material.dart';

import 'batch/batches_overview.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.title = "Batches", this.selectedPage = 0})
      : super(key: key);

  final String title;
  final int selectedPage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> title = ["Batches", "Recepten", "Producten"];
  List<Widget> pages = [
    const BatchesOverview(),
    const RecipesOverview(),
    const ProductsOverview()
  ];
  late int selected;

  @override
  void initState() {
    DatabaseController.migrateData();
    selected = widget.selectedPage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title[selected]),
        actions: selected == 1
            ? [
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const RecipeCreator()),
                  );
                },
                child: const Icon(
                  Icons.add,
                  size: 26.0,
                ),
              )),
        ]
            : null,
      ),
      body: pages[selected],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selected,
        onTap: (int value) {
          setState(() {
            selected = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sync), label: "Batches"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Recepten"),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_grocery_store), label: "Voorraad")
        ],
      ),
    );
  }
}