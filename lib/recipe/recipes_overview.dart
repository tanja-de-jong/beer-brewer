import 'package:beer_brewer/data/store.dart';
import 'package:beer_brewer/recipe/recipe_creator.dart';
import 'package:beer_brewer/recipe/recipe_details.dart';
import 'package:flutter/material.dart';

import '../screen.dart';

class RecipesOverview extends StatefulWidget {
  const RecipesOverview({Key? key}) : super(key: key);

  @override
  State<RecipesOverview> createState() => _RecipesOverviewState();
}

class _RecipesOverviewState extends State<RecipesOverview> {
  bool loading = true;

  @override
  void initState() {
    Store.loadRecipes().then((value) => setState(() {
          loading = false;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'Recipes',
      actions: [
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
      ],
      page: OverviewPage.recipes,
      loading: loading,
      child:
      // Expanded(child:
      DataTable(
        showCheckboxColumn: false,
        rows: Store.recipes
            .map(
              (r) => DataRow(
              cells: [
                DataCell(Text(r.name)),
                DataCell(Text(r.style ?? "-")),
                DataCell(Text(Store.batches
                    .where((b) => b.recipeId == r.id)
                    .length
                    .toString()))
              ],
              onSelectChanged: (bool? selected) async {
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        RecipeDetails(recipe: r),
                  ),
                );
              }),
        )
            .toList(),
        columns: const [
          DataColumn(label: Text("Naam", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Stijl", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Batches", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      )
    // )
    );

    return Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: DataTable(
                    showCheckboxColumn: false,
                    rows: Store.recipes
                        .map(
                          (r) => DataRow(
                              cells: [
                                DataCell(Text(r.name)),
                                DataCell(Text(r.style ?? "-")),
                                DataCell(Text(Store.batches
                                    .where((b) => b.recipeId == r.id)
                                    .length
                                    .toString()))
                              ],
                              onSelectChanged: (bool? selected) async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        RecipeDetails(recipe: r),
                                  ),
                                );
                              }),
                        )
                        .toList(),
                    columns: const [
                      DataColumn(label: Text("Naam", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Stijl", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Batches", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                )
              ]));
  }
}
