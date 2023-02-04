import 'package:beer_brewer/batch/batches_overview.dart';
import 'package:beer_brewer/form/DoubleTextFieldRow.dart';
import 'package:beer_brewer/form/TextFieldRow.dart';
import 'package:beer_brewer/util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/store.dart';
import '../models/spec_to_products.dart';
import '../models/batch.dart';
import '../models/cooking.dart';
import '../models/mashing.dart';
import '../models/product.dart';
import '../models/product_spec.dart';
import '../models/recipe.dart';
import 'batch_details.dart';

class BatchCreator extends StatefulWidget {
  final Recipe? recipe;
  final Batch? batch;

  const BatchCreator({Key? key, this.recipe, this.batch}) : super(key: key);

  @override
  State<BatchCreator> createState() => _BatchCreatorState();
}

class _BatchCreatorState extends State<BatchCreator> {
  bool loading = true;
  List<SpecToProducts> maltMappings = [];
  List<SpecToProducts> hopMappings = [];
  List<SpecToProducts> cookingSugarMappings = [];
  List<SpecToProducts> bottleSugarMappings = [];
  List<SpecToProducts> yeastMappings = [];
  List<SpecToProducts> otherMappings = [];
  Map<ProductSpecCategory, List<SpecToProducts>> allMappings = {};

  Map<Product, num> amountsUsed = {};
  late num batchAmount;
  String? explanation;

  num? mashWater;
  num? rinsingWater;

  DateTime? brewDate;
  DateTime? lagerDate;
  DateTime? bottleDate;

  Future<void> updateProductAmounts({ delete = false }) async {
    if (delete) {
      for (List<SpecToProducts> value in allMappings.values) {
        for (SpecToProducts stp in value) {
          if (stp.products != null) {
            for (ProductInstance pi in stp.products!) {
              Product p = pi.product;
              if (p.amountInStock != null) {
                Store.updateAmountForProduct(p, p.amountInStock! + pi.amount);
              }
            }
          }
        }
      }
    } else {
      for (var p in amountsUsed.keys) {
        Store.updateAmountForProduct(p, (p.amountInStock ?? 0) - (amountsUsed[p] ?? 0));
      }
    }
  }

  void addProductForSpec(SpecToProducts stp, Product product, num amount) {
    setState(() {
      stp.products ??= [];
      stp.products!.add(ProductInstance(product, amount));
      amountsUsed[product] = (amountsUsed[product] ?? 0) + amount;
    });
  }

  Widget getProductsForSpec(SpecToProducts stp) {
    // List<SpecToProducts> selectedProducts = allMappings[stp.spec.category]!
    //     .where((stp) => stp.spec == spec && stp.product != null)
    //     .toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          stp.spec.getProductString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextButton(
            onPressed: () {
              selectProductDialog(stp, addProductForSpec);
            },
            child: const Text("Voeg toe")
            // icon: Icon(Icons.arrow_forward),
            // splashRadius: 18,
            )
      ]),
      ...stp.products!.map((sel) => Row(
            children: [
              Expanded(
                  child: Text(
                      "${sel.amount}g ${sel.product.name} (${sel.product.brand})",
                      overflow: TextOverflow.ellipsis, style: TextStyle(color: isInStock(sel) ? null : Colors.red),)),
              IconButton(
                onPressed: () {
                  setState(() {
                    stp.products!.remove(sel);
                    amountsUsed[sel.product] =
                        (amountsUsed[sel.product] ?? 0) - sel.amount;
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
        const SizedBox(width: 5),
        value
      ],
    );
  }

  Widget getCategory(ProductSpecCategory category) {
    List<SpecToProducts> filteredList = allMappings[category]!;

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
                ...filteredList
                    .map((SpecToProducts stp) => getProductsForSpec(stp))
                    .toList()
              ],
            ));
  }

  void updateBatchAmount(num amount) {
    if (amount != batchAmount) {
      num ingredientRatio = amount / batchAmount;
      setState(() {
        for (SpecToProducts stp in allMappings.values.expand((e) => e)) {
          ProductSpec spec = stp.spec;
          if (spec.category != ProductSpecCategory.bottleSugar) {
            if (spec.amount != null) {
              spec.amount = num.parse(
                  Util.prettify(spec.amount! * ingredientRatio) ?? "");
            }
            if (stp.products != null) {
              for (ProductInstance pi in stp.products!) {
                pi.amount = num.parse(
                    Util.prettify(pi.amount * ingredientRatio) ?? "");
              }
            }
          }
        }
        if (mashWater != null) mashWater = mashWater! * ingredientRatio;
        if (rinsingWater != null) rinsingWater = rinsingWater! * ingredientRatio;
        batchAmount = amount;
      });
    }
  }

  @override
  void initState() {
    batchAmount = widget.batch?.amount ?? widget.recipe!.amount!;
    Store.loadProducts().then((value) => setState(() {
          loading = false;
        }));

    if (widget.batch != null) {
      Batch batch = widget.batch!;
      maltMappings = batch.mashing.malts;
      hopMappings = batch.cooking.steps
          .expand((step) => step.products
              .where((p) => p.spec.category == ProductSpecCategory.hop))
          .toList();
      yeastMappings = batch.yeast == null ? [] : [batch.yeast!];
      cookingSugarMappings = batch.cooking.steps
          .expand((step) => step.products.where(
              (p) => p.spec.category == ProductSpecCategory.cookingSugar))
          .toList();
      bottleSugarMappings =
          batch.bottleSugar == null ? [] : [batch.bottleSugar!];
      otherMappings = batch.cooking.steps
          .expand((step) => step.products
              .where((p) => p.spec.category == ProductSpecCategory.other))
          .toList();
      mashWater = batch.mashing.water;
      rinsingWater = batch.rinsingWater;

      brewDate = batch.brewDate;
      lagerDate = batch.lagerDate;
      bottleDate = batch.bottleDate;
    } else {
      Recipe recipe = widget.recipe!;
      maltMappings = recipe.mashing.malts;
      hopMappings = recipe.cooking.steps
          .expand((step) => step.products
              .where((p) => p.spec.category == ProductSpecCategory.hop))
          .toList();
      yeastMappings =
          recipe.yeast == null ? [] : [SpecToProducts(recipe.yeast!, [], null)];
      cookingSugarMappings = recipe.cooking.steps
          .expand((step) => step.products.where(
              (p) => p.spec.category == ProductSpecCategory.cookingSugar))
          .toList();
      bottleSugarMappings = recipe.bottleSugar == null
          ? []
          : [SpecToProducts(recipe.bottleSugar!, [], null)];
      otherMappings = recipe.cooking.steps
          .expand((step) => step.products
              .where((p) => p.spec.category == ProductSpecCategory.other))
          .toList();

      mashWater = recipe.mashing.water;
      rinsingWater = recipe.rinsingWater;
    }

    allMappings[ProductSpecCategory.malt] = maltMappings;
    allMappings[ProductSpecCategory.hop] = hopMappings;
    allMappings[ProductSpecCategory.cookingSugar] = cookingSugarMappings;
    allMappings[ProductSpecCategory.bottleSugar] = bottleSugarMappings;
    allMappings[ProductSpecCategory.yeast] = yeastMappings;
    allMappings[ProductSpecCategory.other] = otherMappings;

    updateBatchAmount(5);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: const Text("Maak brouwplan"),
      actions: [
        if (widget.batch != null)
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Util.showDeleteDialog(context, "batch", () async {
                    await Store.removeBatch(widget.batch!);
                    updateProductAmounts(delete: true);
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => const BatchesOverview(),
                          ),
                              (route) => false);
                    }
                  }, deze: true);
                },
                child: const Icon(
                  Icons.delete,
                  size: 26.0,
                ),
              )),
      ],
    );

    return Scaffold(
        appBar: appBar,
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height -
                      appBar.preferredSize.height -
                      170,
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              DoubleTextFieldRow(
                                label: "Hoeveelheid (L)",
                                initialValue: batchAmount,
                                props: const {"isEditable": false},
                                onChanged: (value) {
                                  if (value != null) updateBatchAmount(value);
                                },
                              ),
                              const SizedBox(height: 10),
                              if (widget.batch != null) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const Text("Datum", style: TextStyle(fontWeight: FontWeight.bold)),
                                TextFieldRow(label: "Brouwdatum", initialValue: brewDate != null ? DateFormat("dd-MM-yyyy").format(brewDate!) : null, onChanged: (value) {
                                  DateTime? date = DateFormat("dd-MM-yyyy").tryParse(value);
                                  if (date != null) {
                                    setState(() {
                                      brewDate = date;
                                    });
                                  }
                                }),
                                TextFieldRow(label: "Lagerdatum", initialValue: lagerDate != null ? DateFormat("dd-MM-yyyy").format(lagerDate!) : null, onChanged: (value) {
                                  DateTime? date = DateFormat("dd-MM-yyyy").tryParse(value);
                                  if (date != null) {
                                    setState(() {
                                      lagerDate = date;
                                    });
                                  }
                                }),
                                TextFieldRow(label: "Botteldatum", initialValue: bottleDate != null ? DateFormat("dd-MM-yyyy").format(bottleDate!) : null, onChanged: (value) {
                                  DateTime? date = DateFormat("dd-MM-yyyy").tryParse(value);
                                  if (date != null) {
                                    setState(() {
                                      bottleDate = date;
                                    });
                                  }
                                }),
                              ],),
                              if (widget.batch != null) const SizedBox(height: 10),
                              Wrap(runSpacing: 15, spacing: 15, children: [
                                getCategory(ProductSpecCategory.malt),
                                getCategory(ProductSpecCategory.hop),
                                getCategory(ProductSpecCategory.cookingSugar),
                                getCategory(ProductSpecCategory.yeast),
                                getCategory(ProductSpecCategory.bottleSugar),
                                getCategory(ProductSpecCategory.other)
                              ]),
                                const SizedBox(height: 10),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: const [
                                      Text("Toelichting",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ]),
                                const SizedBox(height: 5),
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
                            ]))),
              const Divider(),
              ElevatedButton(
                onPressed: () {
                  Batch? batch = widget.batch;
                  Recipe? recipe = widget.recipe;
                  Mashing mashing = batch?.mashing ?? recipe!.mashing;
                  mashing.malts = maltMappings;
                  mashing.water = mashWater;
                  Cooking cooking = batch?.cooking ?? recipe!.cooking;
                  for (CookingScheduleStep step in cooking.steps) {
                    for (SpecToProducts stp in step.products) {
                      Iterable<SpecToProducts> allStps =
                          allMappings.values.expand((element) => element);
                      Iterable<SpecToProducts> stpsForSpec =
                          allStps.where((element) => element.spec == stp.spec);
                      step.products.remove(stp);
                      step.products.addAll(stpsForSpec);
                    }
                  }
                  Batch newBatch = Batch(
                      widget.batch?.id,
                      widget.batch?.name ?? widget.recipe!.name,
                      widget.batch?.recipeId ?? widget.recipe!.id!,
                      batchAmount,
                      widget.batch?.style ?? widget.recipe!.style,
                      widget.batch?.expStartSG ?? widget.recipe!.expStartSG,
                      widget.batch?.expFinalSG ?? widget.recipe!.expFinalSG,
                      widget.batch?.color ?? widget.recipe!.color,
                      widget.batch?.bitter ?? widget.recipe!.bitter,
                      mashing,
                      rinsingWater,
                      cooking,
                      yeastMappings.isNotEmpty ? yeastMappings[0] : null,
                      widget.batch?.fermTempMin ?? widget.recipe!.fermTempMin,
                      widget.batch?.fermTempMax ?? widget.recipe!.fermTempMax,
                      bottleSugarMappings.isEmpty
                          ? null
                          : bottleSugarMappings[0],
                      explanation,
                      brewDate,
                      lagerDate,
                      bottleDate,
                      widget.batch?.sgMeasurements ?? {}, widget.batch?.notifications ?? {});
                  Store.saveBatch(newBatch);
                  updateProductAmounts();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                BatchDetails(batch: newBatch)),
                        (Route<dynamic> route) => route.isFirst);
                  }
                },
                child: const Text("Opslaan"),
              ),
            ])));
  }

  selectProductDialog(SpecToProducts stp, Function addProduct) {
    ProductSpec spec = stp.spec;
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
    List products = Store.products[spec.category.product]!;
    Product? selectedProduct;
    num? amount = spec.amount;
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
                  if (spec is MaltSpec) const DataColumn(label: Text("EBC")),
                  const DataColumn(label: Text("Voorraad")),
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
                                if (spec is MaltSpec)
                                  DataCell(
                                      Text((product as Malt).typeToString())),
                                if (spec is MaltSpec)
                                  DataCell(
                                      Text((product as Malt).ebcToString())),
                                DataCell(Text(Util.amountToString(((product as Product).amountInStock ?? 0) - (amountsUsed[product] ?? 0)))),
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
                    padding: const EdgeInsets.all(20),
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
                                  _getRow(
                                      "Soort",
                                      Text((selectedProduct as Malt)
                                          .typeToString())),
                                _getRow("Merk", Text(selectedProduct!.brand)),
                                if (selectedProduct is Malt)
                                  _getRow(
                                      "EBC",
                                      Text((selectedProduct as Malt)
                                          .ebcToString())),
                                _getRow(
                                    "Te koop",
                                    selectedProduct!.stores == null
                                        ? Container()
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: selectedProduct!
                                                .stores!.keys
                                                .map((String store) => RichText(
                                                    text: TextSpan(
                                                        text: store,
                                                        style: const TextStyle(
                                                            color: Colors.blue),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap = () {
                                                                launchUrl(Uri.parse(
                                                                    selectedProduct!
                                                                        .getStoreUrl(
                                                                            store)));
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
                                    child: TextFormField(
                                      initialValue: amount.toString(),
                                      onChanged: (value) {
                                        setState(() {
                                          amount = num.tryParse(value);
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
                                            RegExp(r"[\d.,]")),
                                        TextInputFormatter.withFunction(
                                            (oldValue, newValue) {
                                          try {
                                            final text = newValue.text
                                                .replaceAll(RegExp(r','), ".");
                                            if (text.isNotEmpty) {
                                              num.parse(text);
                                            }
                                            return newValue;
                                          } catch (e) {}
                                          return oldValue;
                                        }),
                                      ],
                                    ))),
                            const SizedBox(height: 5),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: const [
                                  Text("Toelichting",
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
                                ]),
                            const SizedBox(height: 5),
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
                            const SizedBox(height: 10),
                            ElevatedButton(
                                onPressed: amount == null
                                    ? null
                                    : () {
                                        addProduct(
                                            stp, selectedProduct, amount);
                                        Navigator.pop(context);
                                      },
                                child: const Text("Voeg toe"))
                          ]),
                  ),
                ]);
          });
        });
  }

  isInStock(ProductInstance sel) {
    if (!amountsUsed.containsKey(sel.product)) return true;
    return (sel.product.amountInStock ?? 0) >= amountsUsed[sel.product]!;
  }
}
