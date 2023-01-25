import 'package:beer_brewer/recipe_details.dart';
import 'package:beer_brewer/data/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data/store.dart';

class ProductsOverview extends StatefulWidget {
  const ProductsOverview({Key? key}) : super(key: key);

  @override
  State<ProductsOverview> createState() => _ProductsOverviewState();
}

class _ProductsOverviewState extends State<ProductsOverview> {
  bool loading = true;
  int selected = 0;
  List<Widget> productGroups = [];
  bool filterList = true;
  String searchFilter = "";

  Widget getProductGroup(ProductCategory cat, List<Product> products) {
    return Column(children: [
      DataTable(
        showCheckboxColumn: false,
        rows: products
            .map(
              (product) => DataRow(
                cells: [
                  DataCell(Text(product.name)),
                  if (product is Malt) DataCell(Text(product.type)),
                  if (product is Hop) DataCell(Text(product.type.name)),
                  DataCell(Text(product.brand)),
                  DataCell(Text(product.amount == null
                      ? "-"
                      : product.amount! >= 1000
                          ? "${product.amount! / 1000} kg"
                          : "${product.amount} g")),
                  if (product is Malt) DataCell(Text(product.ebcToString())),
                  DataCell(Text(product.storesToString())),
                ],
                // onSelectChanged: (bool? selected) async {
                //   await Navigator.push(
                //     context,
                //     MaterialPageRoute<void>(
                //       builder: (BuildContext context) =>
                //           RecipeDetails(recipe: r),
                //     ),
                //   );
                // }
              ),
            )
            .toList(),
        columns: [
          DataColumn(label: Text("Naam")),
          if (cat == ProductCategory.malt || cat == ProductCategory.hop) DataColumn(label: Text("Type")),
          DataColumn(label: Text("Merk")),
          DataColumn(label: Text("Voorraad")),
          if (cat == ProductCategory.malt) DataColumn(label: Text("EBC")),
          DataColumn(label: Text("Te koop")),
        ],
      )
    ]);
  }

  List<Product> getFilteredList(ProductCategory cat) {
    List<Product> products = [];
    switch (cat) {
      case ProductCategory.malt:
        products = Store.maltProducts;
        break;
      case ProductCategory.hop:
        products = Store.hopProducts;
        break;
      case ProductCategory.yeast:
        products = Store.yeastProducts;
        break;
      case ProductCategory.sugar:
        products = Store.sugarProducts;
        break;
      default:
        products = Store.otherProducts;
        break;
    }

    if (filterList) {
      products = products
          .where((product) => product.amount != null && product.amount! > 0)
          .toList();
    }
    if (searchFilter != "") {
      String filter = searchFilter.toLowerCase();
      products = products
          .where((product) =>
              product.name.toLowerCase().contains(filter) ||
              product.brand.toLowerCase().contains(filter) ||
          (product is Malt && product.type.toLowerCase().contains(filter)) ||
                  (product is Hop && product.type.name.toLowerCase().contains(filter))
      ).toList();
    }
    return products;
  }

  void loadList() {
    productGroups[selected] = getProductGroup(ProductCategory.values[selected],
        getFilteredList(ProductCategory.values[selected]));
  }

  void loadTabs() {
    productGroups = ProductCategory.values
        .map((cat) => getProductGroup(cat, getFilteredList(cat)))
        .toList();

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    // Store.loadProducts().then((value) => setState(() {
    //       loading = false;
    //     }));
    loadTabs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: loading
            ? CircularProgressIndicator()
            : Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(
                    height: 50,
                    color: Colors.blue,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ProductCategory.values
                            .map(
                              (cat) => TextButton(
                                child: Text(
                                  cat.name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          ProductCategory.values.indexOf(cat) ==
                                                  selected
                                              ? FontWeight.bold
                                              : null),
                                ),
                                onPressed: () {
                                  setState(() {
                                    selected =
                                        ProductCategory.values.indexOf(cat);
                                  });
                                },
                              ),
                            )
                            .toList())),
                Container(
                    height: 5,
                    child: Row(children: [
                      Container(
                          width: MediaQuery.of(context).size.width / 5,
                          color: selected == 0 ? Colors.white : Colors.blue),
                      Container(
                          width: MediaQuery.of(context).size.width / 5,
                          color: selected == 1 ? Colors.white : Colors.blue),
                      Container(
                          width: MediaQuery.of(context).size.width / 5,
                          color: selected == 2 ? Colors.white : Colors.blue),
                      Container(
                          width: MediaQuery.of(context).size.width / 5,
                          color: selected == 3 ? Colors.white : Colors.blue),
                      Container(
                          width: MediaQuery.of(context).size.width / 5,
                          color: selected == 4 ? Colors.white : Colors.blue)
                    ])),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(children: [
                      Padding(
                          padding: EdgeInsets.only(left: 25, right: 25),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  SizedBox(
                                      width: 200,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: "Zoek product...",
                                          //Add isDense true and zero Padding.
                                          //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                          isDense: true,
                                          contentPadding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 10,
                                              bottom: 10),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          //Add more decoration as you want here
                                          //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            searchFilter = value;
                                            loadList();
                                          });
                                        },
                                      )),
                                  SizedBox(width: 20),
                                  SizedBox(
                                      height: 30,
                                      child: ToggleButtons(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Text("Op voorraad")),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Text("Alles"))
                                        ],
                                        isSelected: [filterList, !filterList],
                                        onPressed: (value) {
                                          setState(() {
                                            filterList = value == 0;
                                            loadList();
                                          });
                                        },
                                      ))
                                ]),
                                OutlinedButton.icon(
                                    onPressed: () {},
                                    label: Text("Voeg toe"),
                                    icon: Icon(Icons.add))
                              ])),
                      productGroups[selected]
                    ]))
              ]));
  }
}
