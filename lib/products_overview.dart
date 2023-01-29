import 'package:beer_brewer/form/DropDownRow.dart';
import 'package:beer_brewer/recipe_details.dart';
import 'package:beer_brewer/data/store.dart';
import 'package:beer_brewer/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data/store.dart';
import 'data/store.dart';
import 'data/store.dart';
import 'form/DoubleTextFieldRow.dart';
import 'form/TextFieldRow.dart';
import 'main.dart';

class ProductsOverview extends StatefulWidget {
  const ProductsOverview({Key? key}) : super(key: key);

  @override
  State<ProductsOverview> createState() => _ProductsOverviewState();
}

class _ProductsOverviewState extends State<ProductsOverview> {
  bool loading = true;
  int selected = 0;
  List<Product> products = [];
  bool filterInStock = true;
  String searchFilter = "";
  Set<String> brands = {};

  Widget getProductGroup() {
    ProductCategory cat = ProductCategory.values[selected];
    return Column(children: [
      DataTable(
        showCheckboxColumn: false,
        rows: products
            .map(
              (product) => DataRow(
                onSelectChanged: (selected) => selected == null || !selected
                    ? null
                    : showAddDialog(product, (Product newProduct) {
                        setState(() {
                          brands.add(Util.capitalize(newProduct.brand));
                        });
                        Navigator.pop(context);
                      }, onDelete: () {
                        setState(() {});
                      }),
                cells: [
                  DataCell(Text(product.name)),
                  if (product is Malt) DataCell(Text(product.typeToString())),
                  if (product is Hop) DataCell(Text(product.type.name)),
                  DataCell(Text(product.brand)),
                  DataCell(Text(product.amountToString())),
                  if (product is Malt) DataCell(Text(product.ebcToString())),
                  if (product is Hop)
                    DataCell(Text(product.alphaAcid == null
                        ? "-"
                        : "${product.alphaAcid}%")),
                  DataCell(Text(product.storesToString())),
                ],
              ),
            )
            .toList(),
        columns: [
          DataColumn(label: Text("Naam")),
          if (cat == ProductCategory.malt || cat == ProductCategory.hop)
            DataColumn(label: Text("Type")),
          DataColumn(label: Text("Merk")),
          DataColumn(label: Text("Voorraad")),
          if (cat == ProductCategory.malt) DataColumn(label: Text("EBC")),
          if (cat == ProductCategory.hop) DataColumn(label: Text("Alfazuur")),
          DataColumn(label: Text("Te koop")),
        ],
      )
    ]);
  }

  void filterProducts() {
    ProductCategory cat = ProductCategory.values[selected];

    setState(() {
      products = Store.products[cat.productType]! as List<Product>;

      if (filterInStock) {
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
                (product is Malt &&
                    product.typeToString().toLowerCase().contains(filter)) ||
                (product is Hop &&
                    product.type.name.toLowerCase().contains(filter)))
            .toList();
      }
    });
  }

  void loadData() async {
    await Store.loadProducts();
    setState(() {
      products = Store.products[ProductCategory.values[selected].productType]!
          as List<Product>;
      brands = products.map((p) => p.brand).toSet();
      filterProducts();
      loading = false;
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: loading
            ? CircularProgressIndicator()
            : Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(
                    // Tabs
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
                                    filterProducts();
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
                                            filterProducts();
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
                                        isSelected: [
                                          filterInStock,
                                          !filterInStock
                                        ],
                                        onPressed: (value) {
                                          setState(() {
                                            filterInStock = value == 0;
                                            filterProducts();
                                          });
                                        },
                                      ))
                                ]),
                                OutlinedButton.icon(
                                    onPressed: () => showAddDialog(null,
                                            (Product newProduct) {
                                          setState(() {
                                            brands.add(Util.capitalize(newProduct.brand));
                                          });
                                          Navigator.pop(context);
                                        }),
                                    label: Text("Voeg toe"),
                                    icon: Icon(Icons.add))
                              ])),
                      getProductGroup()
                    ]))
              ]));
  }

  showAddDialog(Product? product, void Function(Product) onChange,
      {void Function()? onDelete}) {
    ProductCategory category = ProductCategory.values[selected];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          String? name = product?.name;
          String? type = product == null
              ? null
              : product is Malt
                  ? product.type
                  : Product is Hop
                      ? (product as Hop).type.name
                      : null;
          String? brand = product?.brand;
          Map<String, Map<String, dynamic>>? stores = product?.stores;
          double? amount = product?.amount;
          double? ebcMin = product is Malt ? product.ebcMin : null;
          double? ebcMax = product is Malt ? product.ebcMax : null;
          double? alphaAcid = product is Hop ? product.alphaAcid : null;
          String? hopType =
              product is Hop ? product.type.name : HopType.korrels.name;

          return StatefulBuilder(builder: (context, setState) {
            return SimpleDialog(
                title: Center(
                    child: Text("Voeg ${category.name.toLowerCase()} toe")),
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFieldRow(
                            label: 'Naam',
                            initialValue: name,
                            onChanged: (value) {
                              setState(() {
                                name = value;
                              });
                            },
                          ),
                          if (category == ProductCategory.malt)
                            DropDownRow(
                              label: "Soort",
                              initialValue: type,
                              items: Store.maltTypes,
                              onChanged: (value) {
                                setState(() {
                                  type = value;
                                });
                              },
                            ),
                          DropDownRow(
                            label: 'Merk',
                            initialValue: brand,
                            onChanged: (value) {
                              setState(() {
                                brand = value;
                              });
                            },
                            items: brands.toList(),
                          ),
                          if (category == ProductCategory.malt)
                            TextFieldRow(
                                label: "Min EBC",
                                initialValue: ebcMin,
                                onChanged: (value) {
                                  setState(() {
                                    ebcMin = double.parse(value);
                                  });
                                }),
                          if (category == ProductCategory.malt)
                            TextFieldRow(
                                label: "Max EBC",
                                initialValue: ebcMax,
                                onChanged: (value) {
                                  setState(() {
                                    ebcMax = double.parse(value);
                                  });
                                }),
                          if (category == ProductCategory.hop)
                            DropDownRow(
                              label: "Type",
                              initialValue: hopType,
                              onChanged: (value) {
                                setState(() {
                                  hopType = value;
                                });
                              },
                              items: HopType.values.map((t) => t.name).toList(),
                            ),
                          if (category == ProductCategory.hop)
                            DoubleTextFieldRow(
                                label: "Alfazuur (%)",
                                initialValue: alphaAcid,
                                onChanged: (value) {
                                  setState(() {
                                    alphaAcid = value;
                                  });
                                }),
                          TextFieldRow(label: 'Te koop'),
                          DoubleTextFieldRow(
                            label: 'Op voorraad (g)',
                            initialValue: amount,
                            onChanged: (value) {
                              setState(() {
                                amount = value;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (product != null)
                                  OutlinedButton(
                                      onPressed: () {
                                        Util.showDeleteDialog(
                                            context, "product", () async {
                                          await Store.removeProduct(product)
                                              .then((value) => onDelete!());
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: const Text(
                                        "Verwijderen",
                                        style: TextStyle(color: Colors.red),
                                      )),
                                if (product != null) SizedBox(width: 10),
                                ElevatedButton(
                                    onPressed: name != null
                                        ? () {
                                            Map extraProps = {};
                                            if (category ==
                                                ProductCategory.malt) {
                                              extraProps["type"] = type;
                                              extraProps["ebcMin"] = ebcMin;
                                              extraProps["ebcMax"] = ebcMax;
                                            } else if (category ==
                                                ProductCategory.hop) {
                                              extraProps["alphaAcid"] =
                                                  alphaAcid;
                                              extraProps["type"] = hopType;
                                            }
                                            Store.saveProduct(
                                                    product?.id,
                                                    category,
                                                    name!,
                                                    brand,
                                                    stores,
                                                    amount,
                                                    extraProps)
                                                .then((newProduct) {
                                                  filterProducts();
                                              onChange(newProduct);
                                            });
                                          }
                                        : null,
                                    child: const Text("Opslaan"))
                              ])
                        ]),
                  ),
                ]);
          });
        });
  }
}
