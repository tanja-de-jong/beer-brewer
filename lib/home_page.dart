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
  List<Widget> pages = [
    const BatchesOverview(),
    const RecipesOverview(),
    const ProductsOverview()
  ];
  late int selected;

  @override
  void initState() {
    selected = widget.selectedPage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the HomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
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