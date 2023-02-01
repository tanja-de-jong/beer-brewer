import 'dart:math';

import 'package:beer_brewer/form/DropDownRow.dart';
import 'package:beer_brewer/data/store.dart';
import 'package:beer_brewer/util.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import 'data/store.dart';
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
  ProductCategory cat = ProductCategory.values.first;
  List<Product> products = [];

  bool filterInStock = true;
  String searchFilter = "";
  String minEBCFilter = "";
  String maxEBCFilter = "";
  List<String> filteredTypes = [];

  Set<String> brands = {};
  double tableWidth = 150 + 100 + 50 + 100 + 3 * 20;

  Widget getProductGroup() {
    cat = ProductCategory.values[selected];

    return DataTable(
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
                    width: 50,
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
        const DataColumn(label: Text("Naam", style: TextStyle(fontWeight: FontWeight.bold))),
        if (cat == ProductCategory.malt || cat == ProductCategory.hop)
          const DataColumn(label: Text("Type", style: TextStyle(fontWeight: FontWeight.bold))),
        if (cat == ProductCategory.hop) const DataColumn(label: Text("Vorm", style: TextStyle(fontWeight: FontWeight.bold))),
        const DataColumn(label: Text("Merk", style: TextStyle(fontWeight: FontWeight.bold))),
        const DataColumn(label: Text("Voorraad", style: TextStyle(fontWeight: FontWeight.bold))),
        if (cat == ProductCategory.malt) const DataColumn(label: Text("EBC", style: TextStyle(fontWeight: FontWeight.bold))),
        if (cat == ProductCategory.hop)
          const DataColumn(label: Text("Alfazuur", style: TextStyle(fontWeight: FontWeight.bold))),
        const DataColumn(label: Text("Te koop", style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  void filterProducts({bool changeCategory = false}) {
    if (changeCategory) {
      cat = ProductCategory.values[selected];
      filteredTypes = [];
      tableWidth = 150 + 100 + 50 + 100 + 3 * 20;
      if (cat == ProductCategory.malt) {
        tableWidth += 75 + 100 + 2 * 20;
      } else if (cat == ProductCategory.hop) {
        tableWidth += 75 + 50 + 50 + 3 * 20;
      }
    }

    setState(() {
      products = Store.products[cat.productType]! as List<Product>;
      if (changeCategory) brands = products.map((p) => p.brand).toSet();

      if (filterInStock) {
        products = products
            .where((product) => product.amount != null && product.amount! > 0)
            .toList();
      }
      if (filteredTypes.isNotEmpty) {
        if (cat == ProductCategory.malt) {
          products = products
              .where(
                  (product) => filteredTypes.contains((product as Malt).type))
              .toList();
        } else if (cat == ProductCategory.hop) {
          products = products
              .where((product) => filteredTypes.contains((product as Hop).type))
              .toList();
        }
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
        double? minEbc = double.tryParse(minEBCFilter);
        if (minEbc != null) {
          products = products.where((product) {
            double? ebcMin = (product as Malt).ebcMin;
            return ebcMin == null || ebcMin >= minEbc;
          }).toList();
        }
      }
      if (maxEBCFilter != "" && cat == ProductCategory.malt) {
        double? maxEbc = double.tryParse(maxEBCFilter);
        if (maxEbc != null) {
          products = products.where((product) {
            double? ebcMax = (product as Malt).ebcMax;
            return ebcMax == null || ebcMax <= maxEbc;
          }).toList();
        }
      }
    });
  }

  void loadData() async {
    await Store.loadProducts();
    setState(() {
      products = Store.products[ProductCategory.values[selected].productType]!
          as List<Product>;
      brands = products.map((p) => p.brand).toSet();
      filterProducts(changeCategory: true);
      loading = false;
    });
  }

  Widget getSearchWidget() {
    return getTextFilterWidget(
        "Zoek product...", (value) => searchFilter = value);
  }

  Widget getMinEBCWidget() {
    return getTextFilterWidget("Min EBC", (value) => minEBCFilter = value,
        width: 85);
  }

  Widget getMaxEBCWidget() {
    return getTextFilterWidget("Max EBC", (value) => maxEBCFilter = value,
        width: 85);
  }

  Widget getTextFilterWidget(String hintText, void Function(String) onChanged,
      {double width = 200}) {
    return SizedBox(
        width: width,
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
              filterProducts();
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
              filterProducts();
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
        child: const Icon(Icons.add,
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

  Widget getButtonBar() {
    double screenWidth = MediaQuery.of(context).size.width;
    double barWidth = min(tableWidth, screenWidth - 30);
    return Row(children: [
      if (screenWidth > barWidth)
        SizedBox(width: (screenWidth - barWidth) / 2 - 15 + 20),
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
                        getSearchWidget(),
                        if (cat == ProductCategory.malt)
                          getTypeDropdown(Store.maltTypes),
                        if (cat == ProductCategory.malt) getMinEBCWidget(),
                        if (cat == ProductCategory.malt) getMaxEBCWidget(),
                        if (cat == ProductCategory.hop)
                          getTypeDropdown(Store.hopTypes),
                        getStockFilterWidget()
                      ],
                    )),
                getAddWidget()
              ]))
        ]);
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
            ? const CircularProgressIndicator()
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
                                    filterProducts(changeCategory: true);
                                  });
                                },
                              ),
                            )
                            .toList())),
                SizedBox(
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
                    padding: const EdgeInsets.all(10), child: getButtonBar()),
                Expanded(
                    child: ListView(children: [
                  Center(
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: tableWidth,
                                        child: getProductGroup())
                                  ]))))
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
                      ? (product as Hop).shape.name
                      : null;
          String? brand = product?.brand;
          Map<String, Map<String, dynamic>>? stores = product?.stores;
          double? amount = product?.amount;
          double? ebcMin = product is Malt ? product.ebcMin : null;
          double? ebcMax = product is Malt ? product.ebcMax : null;
          double? alphaAcid = product is Hop ? product.alphaAcid : null;
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
                                items: Store.hopTypes),
                          if (category == ProductCategory.hop)
                            DropDownRow(
                              label: "Vorm",
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
                                initialValue: alphaAcid,
                                onChanged: (value) {
                                  setState(() {
                                    alphaAcid = value;
                                  });
                                }),
                          const TextFieldRow(label: 'Te koop'),
                          DoubleTextFieldRow(
                            label: 'Op voorraad (g)',
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

  SizedBox getTypeDropdown(List<String> items) {
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
                        filteredTypes.isEmpty
                            ? "Type"
                            : filteredTypes
                                .join(", ")
                                .replaceAll(' ', '\u00A0'),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14),
                      )),
                      const Icon(Icons.keyboard_arrow_down)
                    ])),
            onTap: () => _showMultiSelect(context, items)));
  }

  void _showMultiSelect(BuildContext context, List<String> items) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return MultiSelectDialog(
          items: items.map((e) => MultiSelectItem(e, e)).toList(),
          initialValue: filteredTypes,
          searchable: true,
          onConfirm: (values) {
            setState(() {
              filteredTypes = values.cast<String>();
              filterProducts();
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
