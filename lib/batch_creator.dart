import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/store.dart';

class BatchCreator extends StatefulWidget {
  final Recipe recipe;

  const BatchCreator({Key? key, required this.recipe}) : super(key: key);

  @override
  State<BatchCreator> createState() => _BatchCreatorState();
}

class _BatchCreatorState extends State<BatchCreator> {
  Map<ProductSpec, List<SpecToProduct>> mappings = {};

  void addProductForSpec(
      ProductSpec spec, Product product, double amount, String? explanation) {
    setState(() {
      mappings[spec]!.add(SpecToProduct(spec, product, amount, explanation));
    });
  }

  Widget getProductsForSpec(ProductSpec spec) {
    List<SpecToProduct> selectedProducts = mappings[spec]!;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          spec.getProductString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextButton(
            onPressed: () {
              selectProductDialog(spec, addProductForSpec);
            },
            child: const Text("Voeg toe")
            // icon: Icon(Icons.arrow_forward),
            // splashRadius: 18,
            )
      ]),
      ...selectedProducts.map((sel) => Row(
            children: [
              Expanded(child: Text("${sel.amount}g ${sel.product.name} (${sel.product.brand})", overflow: TextOverflow.ellipsis)),
              IconButton(
                onPressed: () {
                  setState(() {
                    mappings[spec]!.remove(sel);
                  });
                },
                icon: const Icon(Icons.delete),
                iconSize: 15,
                splashRadius: 15,
              )
            ],
          ))
    ]);
  }

  Row _getRow(String label, Widget value,
      {mainAxisAlignment = MainAxisAlignment.spaceBetween}) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Text(
          "$label:",
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        SizedBox(width: 5),
        value
      ],
    );
  }

  Widget getCategory(ProductSpecCategory category) {
    Iterable filteredList = [];
    if (category == ProductSpecCategory.malt) {
      filteredList = mappings.keys.whereType<MaltSpec>();
    } else if (category == ProductSpecCategory.hop) {
      filteredList = mappings.keys.whereType<HopSpec>();
    } else if (category == ProductSpecCategory.cookingSugar) {
      filteredList = mappings.keys.whereType<CookingSugarSpec>();
    } else if (category == ProductSpecCategory.bottleSugar) {
      filteredList = mappings.keys.whereType<BottleSugarSpec>();
    } else if (category == ProductSpecCategory.yeast) {
      filteredList = mappings.keys.whereType<YeastSpec>();
    } else {
      filteredList = mappings.keys.where((spec) => !(spec is MaltSpec ||
          spec is HopSpec ||
          spec is SugarSpec ||
          spec is YeastSpec));
    }

    return filteredList.isEmpty
        ? Container()
        : SizedBox(
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(fontSize: 18),
                ),
                ...filteredList.map((spec) => getProductsForSpec(spec)).toList()
              ],
            ));
  }

  @override
  void initState() {
    for (MaltSpec spec in widget.recipe.mashing.malts) {
      mappings.putIfAbsent(spec, () => []);
    }
    for (ProductSpec spec in widget.recipe.cooking.getCookingIngredients()) {
      mappings.putIfAbsent(spec, () => []);
    }
    mappings.putIfAbsent(widget.recipe.yeast, () => []);
    mappings.putIfAbsent(widget.recipe.bottleSugar, () => []);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: const Text("Maak brouwplan"),
    );

    return Scaffold(
        appBar: appBar,
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [

              SizedBox(
                  height: MediaQuery.of(context).size.height -
                      appBar.preferredSize.height -
                      100,
                  child: SingleChildScrollView(
                      child: Wrap(runSpacing: 15, spacing: 15, children: [
                        getCategory(ProductSpecCategory.malt),
                        getCategory(ProductSpecCategory.hop),
                        getCategory(ProductSpecCategory.cookingSugar),
                        getCategory(ProductSpecCategory.yeast),
                        getCategory(ProductSpecCategory.bottleSugar),
                        getCategory(ProductSpecCategory.other)
                      ]),)),
              const Divider(),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                },
                child: Text("Opslaan"),
              ),
            ])));
  }

  selectProductDialog(ProductSpec spec, Function addProduct) {
    // Maltfilter
    // String nameFilter = "";
    // String typeFilter = spec.name;
    // String brandFilter = "";
    // String ebcMinFilter = "";
    // String ebcMaxFilter = "";
    // List<String> filterLabels = ["Naam", "Stijl", "Merk", "Min EBC", "Max EBC"];
    // int selectedFilterLabel = 0;
    // List<Widget> getFilteringWidgets() {
    //   return [
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       children: [
    //         DropdownButton<int>(
    //             value: selectedFilterLabel,
    //             items: filterLabels
    //                 .map((l) => DropdownMenuItem<int>(
    //                     value: filterLabels.indexOf(l), child: Text(l)))
    //                 .toList(),
    //             onChanged: (value) {
    //               setState(() {
    //                 if (value != null) selectedFilterLabel = value;
    //               });
    //             }),
    //         const SizedBox(width: 10),
    //         SizedBox(
    //             width: 200,
    //             height: 100,
    //             child: Autocomplete<String>(
    //               displayStringForOption: (option) => option,
    //               optionsBuilder: (TextEditingValue textEditingValue) {
    //                 if (textEditingValue.text == '') {
    //                   return const Iterable<String>.empty();
    //                 }
    //                 return ["Pilsmout", "Caramunich"].where((String option) {
    //                   return option
    //                       .toLowerCase()
    //                       .contains(textEditingValue.text.toLowerCase());
    //                 });
    //               },
    //               onSelected: (String selection) {
    //                 debugPrint('You just selected $selection');
    //               },
    //             )),
    //       ],
    //     ),
    //     Wrap(alignment: WrapAlignment.start, children: [
    //       if (nameFilter != "")
    //         Label(
    //             text: "Naam: $nameFilter",
    //             onClose: () {
    //               setState(() {
    //                 nameFilter = "";
    //               });
    //             }),
    //       if (typeFilter != "")
    //         Label(
    //             text: "Stijl: $typeFilter",
    //             onClose: () {
    //               setState(() {
    //                 typeFilter = "";
    //               });
    //             }),
    //       if (brandFilter != "")
    //         Label(
    //             text: "Merk: $brandFilter",
    //             onClose: () {
    //               setState(() {
    //                 brandFilter = "";
    //               });
    //             }),
    //       if (ebcMinFilter != "")
    //         Label(
    //             text: "Min EBC: $ebcMinFilter",
    //             onClose: () {
    //               setState(() {
    //                 ebcMinFilter = "";
    //               });
    //             }),
    //       if (ebcMaxFilter != "")
    //         Label(
    //             text: "Max EBC: $ebcMaxFilter",
    //             onClose: () {
    //               setState(() {
    //                 ebcMaxFilter = "";
    //               });
    //             })
    //     ]),
    //     const SizedBox(
    //       height: 10,
    //     ),
    //   ];
    // }

    /* TEMP DATA */
    List<Product> products = [];
    if (spec is MaltSpec) {
      products = Store.maltProducts;
      products += Store.maltProducts;
      products += Store.maltProducts;
      products += Store.maltProducts;
      products += Store.maltProducts;
      products += Store.maltProducts;
    } else if (spec is HopSpec) {
      products = Store.hopProducts;
    } else if (spec is SugarSpec) {
      products = Store.sugarProducts;
    } else if (spec is YeastSpec) {
      products = Store.yeastProducts;
    } else {
      products = Store.otherProducts;
    }

    Product? selectedProduct;
    double? amount;
    String? explanation;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            DataTable getTable() {
              return DataTable(
                showCheckboxColumn: false,
                border: TableBorder.all(),
                columns: [
                  const DataColumn(label: Text("Naam")),
                  if (spec is MaltSpec) const DataColumn(label: Text("Type")),
                  const DataColumn(label: Text("Merk")),
                  if (spec is MaltSpec) const DataColumn(label: Text("EBC")),
                  const DataColumn(label: Text("Te koop")),
                ],
                rows: [
                  ...(selectedProduct == null ? products : [selectedProduct])
                      .map((product) => DataRow(
                              selected: selectedProduct != null,
                              color: selectedProduct == null
                                  ? null
                                  : MaterialStateProperty.resolveWith<Color?>(
                                      (Set<MaterialState> states) {
                                      return Colors.grey.withOpacity(0.2);
                                    }),
                              onSelectChanged: (bool? selected) {
                                setState(() {
                                  selectedProduct =
                                      selectedProduct == null ? product : null;
                                });
                              },
                              cells: [
                                DataCell(Text(product!.name)),
                                if (product is Malt)
                                  DataCell(Text(product.type)),
                                DataCell(Text(product.brand)),
                                if (product is Malt)
                                  DataCell(Text(product.ebcToString())),
                                DataCell(Text(product.storesToString()))
                              ]))
                      .toList()
                ],
              );
            }

            return SimpleDialog(
                title: const Center(child: Text("Kies product")),
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: selectedProduct == null
                        ? Column(children: [
                            Row(
                              children: [
                                const SizedBox(width: 5),
                                const Text(
                                  "Doel: ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 5),
                                Text(spec.getProductString())
                              ],
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 100,
                                child: SingleChildScrollView(child: getTable()))
                          ])
                        : Column(children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _getRow("Naam", Text(selectedProduct!.name)),
                                if (selectedProduct is Malt)
                                  _getRow("Soort",
                                      Text((selectedProduct as Malt).type)),
                                _getRow("Merk", Text(selectedProduct!.brand)),
                                if (selectedProduct is Malt)
                                  _getRow(
                                      "EBC",
                                      Text((selectedProduct as Malt)
                                          .ebcToString())),
                                _getRow(
                                    "Te koop",
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: selectedProduct!.stores.keys
                                            .map((String store) => RichText(
                                                text: TextSpan(
                                                    text: store,
                                                    style: new TextStyle(
                                                        color: Colors.blue),
                                                    recognizer:
                                                        new TapGestureRecognizer()
                                                          ..onTap = () {
                                                            launchUrl(Uri.parse(
                                                                selectedProduct!
                                                                    .getStoreUrl()));
                                                          })))
                                            .toList())),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedProduct = null;
                                      });
                                    },
                                    child: const Center(child: Text("Wijzig"))),
                              ],
                            ),
                            _getRow(
                                "Hoeveelheid (g)",
                                SizedBox(
                                    height: 30,
                                    width: 80,
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          amount = double.tryParse(value);
                                        });
                                      },
                                      decoration: InputDecoration(
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
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true, signed: false),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r"[0-9.,]")),
                                        TextInputFormatter.withFunction(
                                            (oldValue, newValue) {
                                          try {
                                            final text = newValue.text
                                                .replaceAll(RegExp(r','), ".");
                                            if (text.isNotEmpty)
                                              double.parse(text);
                                            return newValue;
                                          } catch (e) {}
                                          return oldValue;
                                        }),
                                      ],
                                    ))),
                            SizedBox(height: 5),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text("Toelichting",
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
                                ]),
                            SizedBox(height: 5),
                            SizedBox(
                                height: 100,
                                child: TextFormField(
                                  minLines:
                                      6, // any number you need (It works as the rows for the textarea)
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    //Add isDense true and zero Padding.
                                    //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                    isDense: true,
                                    contentPadding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    //Add more decoration as you want here
                                    //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                  ),
                                  onChanged: (value) {
                                    explanation = value;
                                  },
                                )),
                            SizedBox(height: 10),
                            ElevatedButton(
                                onPressed: amount == null
                                    ? null
                                    : () {
                                        addProduct(spec, selectedProduct,
                                            amount, explanation);
                                        Navigator.pop(context);
                                      },
                                child: const Text("Voeg toe"))
                          ]),
                  ),
                ]);
          });
        });
  }
}
