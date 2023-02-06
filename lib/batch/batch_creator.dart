import 'package:beer_brewer/batch/batches_overview.dart';
import 'package:beer_brewer/form/DoubleTextFieldRow.dart';
import 'package:beer_brewer/form/TextFieldRow.dart';
import 'package:beer_brewer/screen.dart';
import 'package:beer_brewer/util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/label.dart';
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

  late Recipe recipe;

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

  bool biab = true;
  num? mashWater;
  TextEditingController mashWaterController = TextEditingController();
  num? rinsingWater;

  DateTime? brewDate;
  DateTime? lagerDate;
  DateTime? bottleDate;

  Future<void> updateProductAmounts({delete = false}) async {
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
        Store.updateAmountForProduct(
            p, (p.amountInStock ?? 0) - (amountsUsed[p] ?? 0));
      }
    }
  }

  void addProductForSpec(
      SpecToProducts stp, Product product, num amount, String? explanation) {
    setState(() {
      stp.products ??= [];
      stp.products!.add(ProductInstance(product, amount, explanation));
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
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: isInStock(sel) ? null : Colors.red),
              )),
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
                pi.amount =
                    num.parse(Util.prettify(pi.amount * ingredientRatio) ?? "");
              }
            }
          }
        }
        if (mashWater != null) {
          mashWater = mashWater! * ingredientRatio;
          mashWaterController.text = mashWater?.toString() ?? "";
        }
        if (rinsingWater != null)
          rinsingWater = rinsingWater! * ingredientRatio;
        batchAmount = amount;
      });
    }
  }

  @override
  void initState() {
    batchAmount = widget.batch?.amount ?? widget.recipe!.amount!;
    Store.loadData(loadBatches: false, loadRecipes: false)
        .then((value) => setState(() {
              loading = false;
            }));

    if (widget.batch != null) {
      Batch batch = widget.batch!;
      recipe =
          Store.recipes.firstWhere((element) => element.id == batch.recipeId);
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
      recipe = widget.recipe!;
      maltMappings = recipe.mashing.malts;
      hopMappings = recipe.cooking.steps
          .expand((step) => step.products
              .where((p) => p.spec.category == ProductSpecCategory.hop))
          .toList();
      yeastMappings =
          recipe.yeast == null ? [] : [SpecToProducts(recipe.yeast!, [])];
      cookingSugarMappings = recipe.cooking.steps
          .expand((step) => step.products.where(
              (p) => p.spec.category == ProductSpecCategory.cookingSugar))
          .toList();
      bottleSugarMappings = recipe.bottleSugar == null
          ? []
          : [SpecToProducts(recipe.bottleSugar!, [])];
      otherMappings = recipe.cooking.steps
          .expand((step) => step.products
              .where((p) => p.spec.category == ProductSpecCategory.other))
          .toList();

      mashWater = batchAmount * 1.5;
      rinsingWater = null;
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
    return Screen(
        title: widget.recipe == null ? "Maak batch" : "Bewerk batch",
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
                              builder: (BuildContext context) =>
                                  const BatchesOverview(),
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
        loading: loading,
        bottomButton: ElevatedButton(
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
                biab,
                mashing,
                rinsingWater,
                cooking,
                yeastMappings.isNotEmpty ? yeastMappings[0] : null,
                widget.batch?.fermTempMin ?? widget.recipe!.fermTempMin,
                widget.batch?.fermTempMax ?? widget.recipe!.fermTempMax,
                bottleSugarMappings.isEmpty ? null : bottleSugarMappings[0],
                explanation,
                brewDate,
                lagerDate,
                bottleDate,
                widget.batch?.sgMeasurements ?? {},
                widget.batch?.notifications ?? {});
            Store.saveBatch(newBatch);
            updateProductAmounts();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => BatchDetails(batch: newBatch)),
                  (Route<dynamic> route) => route.isFirst);
            }
          },
          child: const Text("Opslaan"),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DoubleTextFieldRow(
            label: "Hoeveelheid (L)",
            initialValue: batchAmount,
            props: const {"isEditable": false},
            onChanged: (value) {
              if (value != null) updateBatchAmount(value);
            },
          ),
          Container(
              padding: EdgeInsets.only(bottom: 5),
              width: 350,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("BIAB"),
                    SizedBox(
                        height: 30,
                        child: ToggleButtons(
                          isSelected: [biab, !biab],
                          onPressed: (value) {
                            setState(() {
                              biab = value == 0;
                              if (biab) {
                                mashWater = batchAmount * 1.5;
                                mashWaterController.text =
                                    mashWater?.toString() ?? "";
                                rinsingWater = null;
                              } else {
                                num ratio = batchAmount / recipe.amount!;
                                mashWater = recipe.mashing.water == null
                                    ? null
                                    : recipe.mashing.water! * ratio;
                                mashWaterController.text =
                                    mashWater?.toString() ?? "";
                                rinsingWater = recipe.rinsingWater == null
                                    ? null
                                    : recipe.rinsingWater! * ratio;
                              }
                            });
                          },
                          children: const [
                            Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Text("Ja")),
                            Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Text("Nee"))
                          ],
                        ))
                  ])),
          DoubleTextFieldRow(
              label: "Maischwater (L)",
              initialValue: mashWater,
              controller: mashWaterController,
              onChanged: (value) {
                setState(() {
                  mashWater = value;
                });
              }),
          if (!biab)
            DoubleTextFieldRow(
                label: "Spoelwater (L)",
                initialValue: rinsingWater,
                onChanged: (value) {
                  setState(() {
                    rinsingWater = value;
                  });
                }),
          const SizedBox(height: 10),
          if (widget.batch != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Datum",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextFieldRow(
                    label: "Brouwdatum",
                    initialValue: brewDate != null
                        ? DateFormat("dd-MM-yyyy").format(brewDate!)
                        : null,
                    onChanged: (value) {
                      DateTime? date = DateFormat("dd-MM-yyyy").tryParse(value);
                      if (date != null) {
                        setState(() {
                          brewDate = date;
                        });
                      }
                    }),
                TextFieldRow(
                    label: "Lagerdatum",
                    initialValue: lagerDate != null
                        ? DateFormat("dd-MM-yyyy").format(lagerDate!)
                        : null,
                    onChanged: (value) {
                      DateTime? date = DateFormat("dd-MM-yyyy").tryParse(value);
                      if (date != null) {
                        setState(() {
                          lagerDate = date;
                        });
                      }
                    }),
                TextFieldRow(
                    label: "Botteldatum",
                    initialValue: bottleDate != null
                        ? DateFormat("dd-MM-yyyy").format(bottleDate!)
                        : null,
                    onChanged: (value) {
                      DateTime? date = DateFormat("dd-MM-yyyy").tryParse(value);
                      if (date != null) {
                        setState(() {
                          bottleDate = date;
                        });
                      }
                    }),
              ],
            ),
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
          Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
            Text("Toelichting", style: TextStyle(fontWeight: FontWeight.bold)),
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
                      left: 10, right: 10, top: 10, bottom: 10),
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
        ]));
  }

  selectProductDialog(SpecToProducts stp, Function addProduct) {
    ProductSpec spec = stp.spec;
    ProductSpecCategory cat = spec.category;

    Product? selectedProduct;
    num? amount = spec.amount;
    String? explanation;

    String ebcMinFilter = "";
    String ebcMaxFilter = "";
    bool filterInStock = true;
    List<String> filteredTypes = [];
    if (spec.name != null) filteredTypes.add(spec.name!);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            Widget getTextFilterWidget(
                String hintText, void Function(String) onChanged,
                {num width = 200}) {
              return SizedBox(
                  width: width.toDouble(),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: hintText,
                      isDense: true,
                      contentPadding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        onChanged(value);
                      });
                    },
                  ));
            }

            Widget getStockFilterWidget() {
              return SizedBox(
                  height: 30,
                  child: ToggleButtons(
                    isSelected: [filterInStock, !filterInStock],
                    onPressed: (value) {
                      setState(() {
                        filterInStock = value == 0;
                      });
                    },
                    children: const [
                      Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Text("Voorraad")),
                      Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Text("Alles"))
                    ],
                  ));
            }

            Widget getFilteringWidgets() {
              double screenWidth = MediaQuery.of(context).size.width;
              return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                const SizedBox(width: 5),
                if (screenWidth >= 630)
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    if (cat == ProductSpecCategory.malt || cat == ProductSpecCategory.hop) getTypeDropdown(
                        cat == ProductSpecCategory.malt
                            ? Store.maltTypes
                            : Store.hopTypes,
                        filteredTypes, (values) {
                      setState(() {
                        filteredTypes = values;
                      });
                    }),
                    if (cat == ProductSpecCategory.malt || cat == ProductSpecCategory.hop) SizedBox(width: 5),
                    if (cat == ProductSpecCategory.malt)
                      getTextFilterWidget(
                          "Min EBC", (value) => ebcMinFilter = value,
                          width: 100),
                    if (cat == ProductSpecCategory.malt) SizedBox(width: 5),
                    if (cat == ProductSpecCategory.malt)
                      getTextFilterWidget(
                          "Max EBC", (value) => ebcMaxFilter = value,
                          width: 100),
                    if (cat == ProductSpecCategory.malt) SizedBox(width: 5),
                    getStockFilterWidget()
                  ]),
                if (screenWidth < 630 && screenWidth >= 380)
                  Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      getStockFilterWidget(),
                      if (cat == ProductSpecCategory.malt || cat == ProductSpecCategory.hop) SizedBox(height: 5),
                      getTypeDropdown(
                          cat == ProductSpecCategory.malt
                              ? Store.maltTypes
                              : Store.hopTypes,
                          filteredTypes, (values) {
                        setState(() {
                          filteredTypes = values;
                        });
                      }),
                    ]),
                    if (cat == ProductSpecCategory.malt) SizedBox(width: 5),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (cat == ProductSpecCategory.malt)
                        getTextFilterWidget(
                            "Min EBC", (value) => ebcMinFilter = value,
                            width: 100),
                      if (cat == ProductSpecCategory.malt) SizedBox(height: 5),
                      if (cat == ProductSpecCategory.malt)
                        getTextFilterWidget(
                            "Max EBC", (value) => ebcMaxFilter = value,
                            width: 100),
                    ])
                  ]),
                if (screenWidth < 380)
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    getTypeDropdown(
                        cat == ProductSpecCategory.malt
                            ? Store.maltTypes
                            : Store.hopTypes,
                        filteredTypes, (values) {
                      setState(() {
                        filteredTypes = values;
                      });
                    }),
                    if (cat == ProductSpecCategory.malt || cat == ProductSpecCategory.hop) SizedBox(height: 5),
                    if (cat == ProductSpecCategory.malt)
                      getTextFilterWidget(
                          "Min EBC", (value) => ebcMinFilter = value,
                          width: 100),
                    if (cat == ProductSpecCategory.malt) SizedBox(height: 5),
                    if (cat == ProductSpecCategory.malt)
                      getTextFilterWidget(
                          "Max EBC", (value) => ebcMaxFilter = value,
                          width: 100),
                    if (cat == ProductSpecCategory.malt) SizedBox(height: 5),
                    getStockFilterWidget()
                  ]),
              ]);
            }

            List<Product> filteredProducts() {
              List<Product> products = Store.products[cat.product]!
                  .where((p) => filterInStock
                      ? p.amountInStock != null && p.amountInStock! > 0
                      : true)
                  .toList();

              if (cat == ProductSpecCategory.malt) {
                products = products
                    .where((p) =>
                        filteredTypes.isEmpty ||
                        filteredTypes.contains((p as Malt).type))
                    .toList();
                products = products
                    .where((p) =>
                        (p as Malt).ebcMin == null ||
                        double.tryParse(ebcMinFilter) == null ||
                        p.ebcMin! >= double.parse(ebcMinFilter))
                    .toList();
                products = products
                    .where((p) =>
                        (p as Malt).ebcMax == null ||
                        double.tryParse(ebcMaxFilter) == null ||
                        p.ebcMax! <= double.parse(ebcMaxFilter))
                    .toList();
              } else if (cat == ProductSpecCategory.hop) {
                products = products
                    .where((p) =>
                        filteredTypes.isEmpty ||
                        filteredTypes.contains((p as Hop).type))
                    .toList();
              }

              return products;
            }

            DataTable getTable() {
              return DataTable(
                showCheckboxColumn: false,
                border: TableBorder.all(),
                columns: [
                  const DataColumn(label: Text("Naam", style: TextStyle(fontWeight: FontWeight.bold),)),
                  if (spec is MaltSpec || spec is HopSpec) const DataColumn(label: Text("Type", style: TextStyle(fontWeight: FontWeight.bold),)),
                  if (spec is MaltSpec) const DataColumn(label: Text("EBC", style: TextStyle(fontWeight: FontWeight.bold),)),
                  const DataColumn(label: Text("Voorraad", style: TextStyle(fontWeight: FontWeight.bold),)),
                  const DataColumn(label: Text("Te koop", style: TextStyle(fontWeight: FontWeight.bold),)),
                ],
                rows: [
                  ...(selectedProduct == null
                          ? filteredProducts()
                          : [selectedProduct])
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
                                if (spec is HopSpec)
                                  DataCell(
                                      Text((product as Hop).type ?? "-")),
                                if (spec is MaltSpec)
                                  DataCell(
                                      Text((product as Malt).ebcToString())),
                                DataCell(Text(Util.amountToString(
                                    (product.amountInStock ?? 0) -
                                        (amountsUsed[product] ?? 0)))),
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
                            getFilteringWidgets(),
                            const SizedBox(height: 15),
                            SizedBox(
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                        child: getTable())))
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
                                        addProduct(stp, selectedProduct, amount,
                                            explanation);
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

  void _showMultiSelect(BuildContext context, List<String> items,
      List<String> selectedItems, onChange) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return MultiSelectDialog(
          items: items.map((e) => MultiSelectItem(e, e)).toList(),
          initialValue: selectedItems,
          searchable: true,
          onConfirm: onChange,
          listType: MultiSelectListType.CHIP,
          title: Text("Selecteer type"),
          confirmText: Text("Opslaan"),
          cancelText: Text("Annuleren"),
        );
      },
    );
  }

  SizedBox getTypeDropdown(
      List<String> items, List<String> selectedItems, onChange) {
    return SizedBox(
        height: 30,
        width: 130,
        child: GestureDetector(
            child: Container(
                padding:
                    EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade600),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        selectedItems.isEmpty
                            ? "Type"
                            : selectedItems
                                .join(", ")
                                .replaceAll(' ', '\u00A0'),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14),
                      )),
                      const Icon(Icons.keyboard_arrow_down)
                    ])),
            onTap: () =>
                _showMultiSelect(context, items, selectedItems, onChange)));
  }
}
