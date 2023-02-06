import 'dart:math';

import 'package:beer_brewer/form/DropDownRow.dart';
import 'package:beer_brewer/data/store.dart';
import 'package:beer_brewer/screen.dart';
import 'package:beer_brewer/util.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import 'form/DoubleTextFieldRow.dart';
import 'form/TextFieldRow.dart';
import 'models/product.dart';

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
  String minEBCFilter = "";
  String maxEBCFilter = "";
  List<String> filteredMaltTypes = [];
  List<String> filteredHopTypes = [];

  Set<String> brands = {};

  Widget getProductGroup(ProductCategory cat) {
    products = Store.products[cat.productType]! as List<Product>;
    filterProducts(cat);
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      DataTable(
        columnSpacing: 20,
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
                  DataCell(SizedBox(
                      width: 150,
                      child: Text(
                        product.name,
                        overflow: TextOverflow.ellipsis,
                      ))),
                  if (product is Malt)
                    DataCell(SizedBox(
                        width: 75,
                        child: Text(
                          product.typeToString(),
                          overflow: TextOverflow.ellipsis,
                        ))),
                  if (product is Hop)
                    DataCell(SizedBox(
                        width: 75,
                        child: Text(
                          product.type ?? "-",
                          overflow: TextOverflow.ellipsis,
                        ))),
                  if (product is Hop)
                    DataCell(SizedBox(
                        width: 50,
                        child: Text(
                          product.shape.name,
                          overflow: TextOverflow.ellipsis,
                        ))),
                  DataCell(SizedBox(
                      width: 100,
                      child: Text(
                        product.brand,
                        overflow: TextOverflow.ellipsis,
                      ))),
                  DataCell(SizedBox(
                      width: 60,
                      child: Text(
                        product.amountToString(),
                        overflow: TextOverflow.ellipsis,
                      ))),
                  if (product is Malt)
                    DataCell(SizedBox(
                        width: 100,
                        child: Text(
                          product.ebcToString(),
                          overflow: TextOverflow.ellipsis,
                        ))),
                  if (product is Hop)
                    DataCell(SizedBox(
                        width: 50,
                        child: Text(
                          product.alphaAcid == null
                              ? "-"
                              : "${product.alphaAcid}%",
                          overflow: TextOverflow.ellipsis,
                        ))),
                  DataCell(SizedBox(
                      width: 100,
                      child: Text(
                        product.storesToString(),
                        overflow: TextOverflow.ellipsis,
                      ))),
                ],
              ),
            )
            .toList(),
        columns: [
          const DataColumn(
              label:
              SizedBox(
                  width: 150,
                  child: Text("Naam", style: TextStyle(fontWeight: FontWeight.bold)))),
          if (cat == ProductCategory.malt || cat == ProductCategory.hop)
            const DataColumn(
                label: SizedBox(
                    width: 75,
                    child: Text("Type",
                        style: TextStyle(fontWeight: FontWeight.bold)))),
          if (cat == ProductCategory.hop)
            const DataColumn(
                label: SizedBox(
                    width: 50,
                    child: Text("Vorm",
                        style: TextStyle(fontWeight: FontWeight.bold)))),
          const DataColumn(
              label:
              SizedBox(
                  width: 100,
                  child: Text("Merk", style: TextStyle(fontWeight: FontWeight.bold)))),
          const DataColumn(
              label: SizedBox(
                  width: 60,
                  child: Text("Voorraad",
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          if (cat == ProductCategory.malt)
            const DataColumn(
                label:
                SizedBox(
                    width: 100,
                    child: Text("EBC", style: TextStyle(fontWeight: FontWeight.bold)))),
          if (cat == ProductCategory.hop)
            const DataColumn(
                label: SizedBox(
                    width: 50,
                    child: Text("Alfazuur",
                        style: TextStyle(fontWeight: FontWeight.bold)))),
          const DataColumn(
              label: SizedBox(
                  width: 100,
                  child: Text("Te koop",
                      style: TextStyle(fontWeight: FontWeight.bold)))),
        ],
      )
    ]);
  }

  void filterProducts(ProductCategory cat, {bool changeCategory = false}) {
    setState(() {
      products = Store.products[cat.productType]! as List<Product>;
      if (changeCategory) brands = products.map((p) => p.brand).toSet();

      if (filterInStock) {
        products = products
            .where((product) =>
                product.amountInStock != null && product.amountInStock! > 0)
            .toList();
      }
      if (cat == ProductCategory.malt && filteredMaltTypes.isNotEmpty) {
        products = products
            .where(
                (product) => filteredMaltTypes.contains((product as Malt).type))
            .toList();
      } else if (cat == ProductCategory.hop && filteredHopTypes.isNotEmpty) {
        products = products
            .where(
                (product) => filteredHopTypes.contains((product as Hop).type))
            .toList();
      }
      if (searchFilter != "") {
        String filter = searchFilter.toLowerCase();
        products = products
            .where((product) =>
                Util.search(product.name, filter) ||
                Util.search(product.brand, filter) ||
                (product is Malt &&
                    Util.search(product.typeToString(), filter)) ||
                (product is Hop && Util.search(product.shape.name, filter)))
            .toList();
      }
      if (minEBCFilter != "" && cat == ProductCategory.malt) {
        num? minEbc = num.tryParse(minEBCFilter);
        if (minEbc != null) {
          products = products.where((product) {
            num? ebcMin = (product as Malt).ebcMin;
            return ebcMin == null || ebcMin >= minEbc;
          }).toList();
        }
      }
      if (maxEBCFilter != "" && cat == ProductCategory.malt) {
        num? maxEbc = num.tryParse(maxEBCFilter);
        if (maxEbc != null) {
          products = products.where((product) {
            num? ebcMax = (product as Malt).ebcMax;
            return ebcMax == null || ebcMax <= maxEbc;
          }).toList();
        }
      }
    });
  }

  void loadData(ProductCategory cat) async {
    await Store.loadData(loadBatches: false, loadRecipes: false);
    setState(() {
      brands = products.map((p) => p.brand).toSet();
      loading = false;
    });
  }

  Widget getSearchWidget(ProductCategory cat) {
    return getTextFilterWidget(
        cat, "Zoek product...", (value) => searchFilter = value);
  }

  Widget getMinEBCWidget(ProductCategory cat) {
    return getTextFilterWidget(cat, "Min EBC", (value) => minEBCFilter = value,
        width: 85);
  }

  Widget getMaxEBCWidget(ProductCategory cat) {
    return getTextFilterWidget(cat, "Max EBC", (value) => maxEBCFilter = value,
        width: 85);
  }

  Widget getTextFilterWidget(
      ProductCategory cat, String hintText, void Function(String) onChanged,
      {num width = 200}) {
    return SizedBox(
        width: width.toDouble(),
        child: TextField(
          decoration: InputDecoration(
            hintText: hintText,
            //Add isDense true and zero Padding.
            //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
            isDense: true,
            contentPadding:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
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

  Widget getStockFilterWidget(ProductCategory cat) {
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

  Widget getAddWidget() {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.all(2.5),
        height: 25,
        width: 25,
        alignment: Alignment.center,
        decoration: const ShapeDecoration(
          color: Colors.lightBlue,
          shape: CircleBorder(),
        ),
        child: const Icon(
          Icons.add,
          size: 25,
          color: Colors.white,
        ),
      ),
      onTap: () => showAddDialog(null, (Product newProduct) {
        setState(() {
          brands.add(Util.capitalize(newProduct.brand));
        });
        Navigator.pop(context);
      }),
    );
  }

  Widget getButtonBar(ProductCategory cat) {
    num tableWidth = 150 + 100 + 50 + 100 + 3 * 20 + 40 + 20;
    if (cat == ProductCategory.malt) {
      tableWidth += 75 + 100 + 2 * 20;
    } else if (cat == ProductCategory.hop) {
      tableWidth += 75 + 50 + 50 + 3 * 20;
    }
    num screenWidth = MediaQuery.of(context).size.width;
    num barWidth = min(tableWidth, screenWidth - 30);
    return Row(children: [
      if (screenWidth > barWidth)
        SizedBox(width: (screenWidth - barWidth) / 2 - 15 + 30),
      SizedBox(
          width: barWidth - 20,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: barWidth - 100,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        getSearchWidget(cat),
                        if (cat == ProductCategory.malt)
                          getTypeDropdown(Store.maltTypes, cat),
                        if (cat == ProductCategory.malt) getMinEBCWidget(cat),
                        if (cat == ProductCategory.malt) getMaxEBCWidget(cat),
                        if (cat == ProductCategory.hop)
                          getTypeDropdown(Store.hopTypes, cat),
                        getStockFilterWidget(cat)
                      ],
                    )),
                getAddWidget()
              ]))
    ]);
  }

  @override
  void initState() {
    loadData(ProductCategory.values.first);
    super.initState();
  }

  Map<String, Widget> getTabs() {
    Map<String, Widget> result = {};
    for (var cat in ProductCategory.values) {
      result[cat.name] = getTabView(cat);
    }
    return result;
  }

  Widget getTabView(ProductCategory cat) {
    return Column(children: [
      Padding(padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10), child: getButtonBar(cat)),
      Expanded(
        child: ListView(
          children: [Center(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                child: getProductGroup(cat))
                          ]))))]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
        title: 'Products',
        page: OverviewPage.products,
        loading: loading,
        scroll: false,
        tabs: getTabs());
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
                      ? (product as Hop).shape.name
                      : null;
          String? brand = product?.brand;
          Map<String, Map<String, dynamic>>? stores = product?.stores;
          num? amount = product?.amountInStock;
          num? ebcMin = product is Malt ? product.ebcMin : null;
          num? ebcMax = product is Malt ? product.ebcMax : null;
          num? alphaAcid = product is Hop ? product.alphaAcid : null;
          String? hopType = product is Hop ? product.type : null;
          String? hopShape =
              product is Hop ? product.shape.name : HopShape.korrels.name;

          return StatefulBuilder(builder: (context, setState) {
            return SimpleDialog(
                title: Center(
                    child: Text("Voeg ${category.name.toLowerCase()} toe")),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFieldRow(
                            label: 'Naam',
                            width: MediaQuery.of(context).size.width - 250,
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
                              width: MediaQuery.of(context).size.width - 250,
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
                            width: MediaQuery.of(context).size.width - 250,
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
                                width: MediaQuery.of(context).size.width - 250,
                                initialValue: ebcMin,
                                onChanged: (value) {
                                  setState(() {
                                    ebcMin = num.parse(value);
                                  });
                                }),
                          if (category == ProductCategory.malt)
                            TextFieldRow(
                                label: "Max EBC",
                                width: MediaQuery.of(context).size.width - 250,
                                initialValue: ebcMax,
                                onChanged: (value) {
                                  setState(() {
                                    ebcMax = num.parse(value);
                                  });
                                }),
                          if (category == ProductCategory.hop)
                            DropDownRow(
                                label: "Type",
                                width: MediaQuery.of(context).size.width - 250,
                                initialValue: hopType,
                                onChanged: (value) {
                                  setState(() {
                                    hopType = value;
                                  });
                                },
                                items: Store.hopTypes),
                          if (category == ProductCategory.hop)
                            DropDownRow(
                              label: "Vorm",
                              width: MediaQuery.of(context).size.width - 250,
                              initialValue: hopShape,
                              onChanged: (value) {
                                setState(() {
                                  hopShape = value;
                                });
                              },
                              items:
                                  HopShape.values.map((t) => t.name).toList(),
                            ),
                          if (category == ProductCategory.hop)
                            DoubleTextFieldRow(
                                label: "Alfazuur (%)",
                                width: MediaQuery.of(context).size.width - 250,
                                initialValue: alphaAcid,
                                onChanged: (value) {
                                  setState(() {
                                    alphaAcid = value;
                                  });
                                }),
                          TextFieldRow(label: 'Te koop', width: MediaQuery.of(context).size.width - 250,),
                          DoubleTextFieldRow(
                            label: 'Op voorraad (g)',
                            width: MediaQuery.of(context).size.width - 250,
                            initialValue: amount,
                            onChanged: (value) {
                              setState(() {
                                amount = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
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
                                          if (mounted) {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          }
                                        });
                                      },
                                      child: const Text(
                                        "Verwijderen",
                                        style: TextStyle(color: Colors.red),
                                      )),
                                if (product != null) const SizedBox(width: 10),
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
                                              extraProps["type"] = hopType;
                                              extraProps["alphaAcid"] =
                                                  alphaAcid;
                                              extraProps["shape"] = hopShape;
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

  SizedBox getTypeDropdown(List<String> items, ProductCategory cat) {
    return SizedBox(
        height: 30,
        width: 80,
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
                        cat == ProductCategory.malt
                            ? filteredMaltTypes.isEmpty
                                ? "Type"
                                : filteredMaltTypes
                                    .join(", ")
                                    .replaceAll(' ', '\u00A0')
                            : filteredHopTypes.isEmpty
                                ? "Type"
                                : filteredHopTypes
                                    .join(", ")
                                    .replaceAll(' ', '\u00A0'),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14),
                      )),
                      const Icon(Icons.keyboard_arrow_down)
                    ])),
            onTap: () => _showMultiSelect(context, items, cat)));
  }

  void _showMultiSelect(
      BuildContext context, List<String> items, ProductCategory cat) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return MultiSelectDialog(
          items: items.map((e) => MultiSelectItem(e, e)).toList(),
          initialValue: cat == ProductCategory.malt ? filteredMaltTypes : filteredHopTypes,
          searchable: true,
          onConfirm: (values) {
            setState(() {
              if (cat == ProductCategory.malt) {
                filteredMaltTypes = values.cast<String>();
              } else {
                filteredHopTypes = values.cast<String>();
              }
            });
          },
          listType: MultiSelectListType.CHIP,
          title: Text("Selecteer type"),
          confirmText: Text("Opslaan"),
          cancelText: Text("Annuleren"),
        );
      },
    );
  }
}
