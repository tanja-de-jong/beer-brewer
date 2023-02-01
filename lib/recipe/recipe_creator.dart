import 'dart:core';

import 'package:beer_brewer/recipe/recipe_details.dart';
import 'package:beer_brewer/util.dart';
import 'package:flutter/material.dart';
import '../data/store.dart';
import '../form/DoubleTextFieldRow.dart';
import '../form/DropDownRow.dart';
import '../form/TextFieldRow.dart';
import '../home_page.dart';
import '../main.dart';
import '../models/spec_to_products.dart';
import '../models/cooking.dart';
import '../models/mashing.dart';
import '../models/product.dart';
import '../models/product_spec.dart';
import '../models/recipe.dart';

class RecipeCreator extends StatefulWidget {
  final Recipe? recipe;

  const RecipeCreator({Key? key, this.recipe}) : super(key: key);

  @override
  State<RecipeCreator> createState() => _RecipeCreatorState();
}

class _RecipeCreatorState extends State<RecipeCreator> {
  late Recipe? recipe;

  // Fields
  String? name;
  String? style;
  String? source;
  double? amount;
  double? startSG;
  double? finalSG;
  double? efficiency;
  double? color;
  double? bitter;
  double? mashWater;
  double? rinsingWater;

  List<MaltSpec> malts = [];
  String? maltType;
  double? maltAmount;
  double? maltMinEBC;
  double? maltMaxEBC;
  bool showAddMalt = false;

  Map<double?, List<HopSpec>> hops = {};
  String? hopType;
  TextEditingController hopTypeController = TextEditingController();
  double? hopAmount;
  double? hopAlphaAcid;
  TextEditingController hopAlphaAcidController = TextEditingController();
  double? hopTime;
  bool showAddHop = false;

  YeastSpec yeast = YeastSpec(null, null);

  CookingSugarSpec cookingSugar = CookingSugarSpec(null, null);
  double? cookingSugarTime;

  BottleSugarSpec bottleSugar = BottleSugarSpec(null, null);

  Map<double?, List<ProductSpec>> others = {};
  String? otherName;
  double? otherAmount;
  double? otherTime;
  bool showAddOther = false;

  double? minTemp;
  double? maxTemp;

  List<MashStep> mashSteps = [];
  double? mashTemp;
  double? mashTime;
  bool showAddMashStep = false;

  String? remarks;

  FocusNode addMaltFocusNode = FocusNode();
  FocusNode addHopFocusNode = FocusNode();
  FocusNode addOtherFocusNode = FocusNode();

  List<Widget> getOtherFields() {
    return [
      DropDownRow(
          focusNode: addOtherFocusNode,
          label: "Soort",
          initialValue: otherName,
          onChanged: (value) {
            setState(() {
              otherName = value;
            });
          },
      items: Store.products[Product]?.map((e) => e.name).toList().cast<String>()),
      DoubleTextFieldRow(
          label: "Hoeveelheid (g)",
          initialValue: otherAmount,
          onChanged: (value) {
            setState(() {
              otherAmount = value;
            });
          }),
      DoubleTextFieldRow(
          label: "Tijd (min)",
          initialValue: otherTime,
          onChanged: (value) {
            setState(() {
              otherTime = value;
            });
          }),
    ];
  }

  List<Widget> getHopFields() {
    return [
      DropDownRow(
          focusNode: addHopFocusNode,
          label: "Soort",
          initialValue: hopType,
          onChanged: (value) {
            setState(() {
              hopType = value;
            });
          },
          controller: hopTypeController,
          items: Store.hopTypes),
      DoubleTextFieldRow(
          label: "Alfazuur (%)",
          initialValue: hopAlphaAcid,
          onChanged: (value) {
            setState(() {
              hopAlphaAcid = value;
            });
          },
          controller: hopAlphaAcidController),
      DoubleTextFieldRow(
          label: "Hoeveelheid (g)",
          initialValue: hopAmount,
          onChanged: (value) {
            setState(() {
              hopAmount = value;
            });
          }),
      DoubleTextFieldRow(
          label: "Tijd (min)",
          initialValue: hopTime,
          onChanged: (value) {
            setState(() {
              hopTime = value;
            });
          })
    ];
  }

  List<Widget> getMaltFields() {
    return [
      DropDownRow(
          focusNode: addMaltFocusNode,
          label: "Type",
          initialValue: maltType,
          onChanged: (value) {
            setState(() {
              maltType = value;
            });
          },
          items: const [
            "Pils",
            "Pale",
            "Vienna",
            "Münchener",
            "Amber",
            "Carapils",
            "Carahell",
            "Caramünich",
            "Caracrystal",
            "Biscuit",
            "Chocolade",
            "Zwart",
            "Tarwe"
          ]),
      DoubleTextFieldRow(
          label: "Min EBC",
          initialValue: maltMinEBC,
          onChanged: (value) {
            setState(() {
              maltMinEBC = value;
            });
          }),
      DoubleTextFieldRow(
          label: "Max EBC",
          initialValue: maltMaxEBC,
          onChanged: (value) {
            setState(() {
              maltMaxEBC = value;
            });
          }),
      DoubleTextFieldRow(
          label: "Hoeveelheid (g)",
          initialValue: maltAmount,
          onChanged: (value) {
            setState(() {
              maltAmount = value;
            });
          }),
    ];
  }

  List<Widget> getMashStepFields() {
    return [
      DoubleTextFieldRow(
          label: "Temperatuur (°C)",
          initialValue: mashTemp,
          onChanged: (value) {
            setState(() {
              mashTemp = value;
            });
          }),
      DoubleTextFieldRow(
          label: "Tijd (minuten)",
          initialValue: mashTime,
          onChanged: (value) {
            setState(() {
              mashTime = value;
            });
          })
    ];
  }

  Future<void> initData() async {
    await Store.loadProducts();
    setState(() {
      if (recipe != null) {
        name = recipe?.name;
        style = recipe?.style;
        source = recipe?.source;
        amount = recipe?.amount;
        startSG = recipe?.expStartSG;
        finalSG = recipe?.expFinalSG;
        efficiency =
            recipe?.efficiency == null ? null : (recipe?.efficiency)! * 100;
        color = recipe?.color;
        bitter = recipe?.bitter;
        mashWater = recipe?.mashing.water;
        rinsingWater = recipe?.rinsingWater;
        malts =
            recipe?.mashing.malts.map((stp) => stp.spec as MaltSpec).toList() ??
                [];
        mashSteps = recipe?.mashing.steps ?? [];
        for (CookingScheduleStep step in recipe!.cooking.steps) {
          double? time = step.time;
          List<HopSpec> hopSpecs = [];
          List<ProductSpec> otherSpecs = [];
          for (SpecToProducts stp in step.products) {
            ProductSpec? spec = stp.spec;
            switch (spec.category) {
              case ProductSpecCategory.hop:
                hopSpecs.add(spec as HopSpec);
                break;
              case ProductSpecCategory.cookingSugar:
                cookingSugar = spec as CookingSugarSpec;
                cookingSugarTime = time;
                break;
              default:
                otherSpecs.add(spec);
                break;
            }
          }
          if (hopSpecs.isNotEmpty) hops[time] = hopSpecs;
          if (otherSpecs.isNotEmpty) others[time] = otherSpecs;
        }

        yeast = recipe!.yeast ?? yeast;

        bottleSugar = recipe!.bottleSugar ?? bottleSugar;

        minTemp = recipe!.fermTempMin;
        maxTemp = recipe!.fermTempMax;

        remarks = recipe!.remarks;
      }
    });
  }

  @override
  void initState() {
    recipe = widget.recipe;
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: const Text("Maak recept"),
      actions: [
        if (widget.recipe != null)
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Util.showDeleteDialog(context, "recept", () async {
                    await Store.removeRecipe(recipe!);
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const HomePage(
                            title: 'Recepten',
                            selectedPage: 1,
                          ),
                        ),
                        (route) => false);
                    }
                  });
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
                      100,
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(spacing: 70, runSpacing: 10, children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Algemeen",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextFieldRow(
                                  label: "Naam",
                                  initialValue: name,
                                  onChanged: (value) {
                                    setState(() {
                                      name = value;
                                    });
                                  }),
                              DropDownRow(
                                  label: "Stijl",
                                  initialValue: style,
                                  onChanged: (value) {
                                    setState(() {
                                      style = value;
                                    });
                                  },
                                  items: const [
                                    "Dubbel",
                                    "Tripel",
                                    "IPA",
                                    "Saison",
                                    "Pils",
                                    "NEIPA",
                                    "Blond",
                                    "Weizen",
                                    "Witbier",
                                    "Amber",
                                    "Quadrupel",
                                    "Porter",
                                    "Stout"
                                  ]),
                              TextFieldRow(
                                  label: "Bron",
                                  initialValue: source,
                                  onChanged: (value) {
                                    setState(() {
                                      source = value;
                                    });
                                  }),
                              DoubleTextFieldRow(
                                  label: "Hoeveelheid (L)",
                                  initialValue: amount,
                                  onChanged: (value) {
                                    setState(() {
                                      amount = value;
                                    });
                                  }),
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Overige",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              DoubleTextFieldRow(
                                  label: "Kleur (EBC)",
                                  initialValue: color,
                                  onChanged: (value) {
                                    setState(() {
                                      color = value;
                                    });
                                  }),
                              DoubleTextFieldRow(
                                  label: "Bitterheid (EBU)",
                                  initialValue: bitter,
                                  onChanged: (value) {
                                    setState(() {
                                      bitter = value;
                                    });
                                  }),
                              DoubleTextFieldRow(
                                  label: "Maischwater (L)",
                                  initialValue: mashWater,
                                  onChanged: (value) {
                                    setState(() {
                                      mashWater = value;
                                    });
                                  }),
                              DoubleTextFieldRow(
                                  label: "Spoelwater (L)",
                                  initialValue: rinsingWater,
                                  onChanged: (value) {
                                    setState(() {
                                      rinsingWater = value;
                                    });
                                  }),
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Alcohol",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              DoubleTextFieldRow(
                                  label: "Start SG",
                                  initialValue: startSG,
                                  onChanged: (value) {
                                    setState(() {
                                      startSG = value;
                                    });
                                  }),
                              DoubleTextFieldRow(
                                  label: "Eind SG",
                                  initialValue: finalSG,
                                  onChanged: (value) {
                                    setState(() {
                                      finalSG = value;
                                    });
                                  }),
                              DoubleTextFieldRow(
                                  label: "Rendement (%)",
                                  isPercentage: true,
                                  initialValue: efficiency,
                                  onChanged: (value) {
                                    setState(() {
                                      efficiency = value;
                                    });
                                  }),
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Vergisting",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              DoubleTextFieldRow(
                                  label: "Min.temp. (°C)",
                                  initialValue: minTemp,
                                  onChanged: (value) {
                                    setState(() {
                                      minTemp = value;
                                    });
                                  }),
                              DoubleTextFieldRow(
                                  label: "Max.temp. (°C)",
                                  initialValue: maxTemp,
                                  onChanged: (value) {
                                    setState(() {
                                      maxTemp = value;
                                    });
                                  }),
                            ]),
                      ]),
                      const SizedBox(height: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ingrediënten",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Mout",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 5),
                                          InkWell(
                                            child: Container(
                                              height: 15,
                                              width: 15,
                                              alignment: Alignment.center,
                                              decoration: const ShapeDecoration(
                                                color: Colors.lightBlue,
                                                shape: CircleBorder(),
                                              ),
                                              child: Icon(
                                                showAddMalt
                                                    ? Icons.remove
                                                    : Icons.add,
                                                size: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                showAddMalt = !showAddMalt;
                                                if (showAddMalt) {
                                                  showAddOther = false;
                                                  showAddHop = false;
                                                  showAddMashStep = false;
                                                }
                                              });
                                              if (showAddMalt) {
                                                addMaltFocusNode.requestFocus();
                                              }
                                            },
                                          ),
                                        ]),
                                    ...malts.map((malt) => Row(children: [
                                          Text(
                                              "${malt.amount}g ${malt.name} (${MaltSpec.getEbcToString(malt.ebcMin, malt.ebcMax)})"),
                                          IconButton(
                                            icon: const Icon(Icons.close),
                                            splashRadius: 12,
                                            iconSize: 15,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              setState(() {
                                                malts.remove(malt);
                                              });
                                            },
                                          )
                                        ])),
                                  ])
                            ]),
                            const SizedBox(
                              height: 10,
                            ),
                            if (showAddMalt)
                              Container(
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  padding: const EdgeInsets.all(5),
                                  margin: const EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      ...getMaltFields(),
                                      const SizedBox(height: 10),
                                      OutlinedButton(
                                          onPressed: maltType == null ||
                                                  maltAmount == null
                                              ? null
                                              : () {
                                                  setState(() {
                                                    malts.add(MaltSpec(
                                                        maltType,
                                                        maltMinEBC,
                                                        maltMaxEBC,
                                                        maltAmount));

                                                    maltType = null;
                                                    maltMinEBC = null;
                                                    maltMaxEBC = null;
                                                    maltAmount = null;
                                                  });
                                                },
                                          child: const Text("Voeg toe")),
                                      const SizedBox(height: 5),
                                    ],
                                  )),
                            const SizedBox(height: 10),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Hop",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 5),
                                          InkWell(
                                            child: Container(
                                              height: 15,
                                              width: 15,
                                              alignment: Alignment.center,
                                              decoration: const ShapeDecoration(
                                                color: Colors.lightBlue,
                                                shape: CircleBorder(),
                                              ),
                                              child: Icon(
                                                showAddHop
                                                    ? Icons.remove
                                                    : Icons.add,
                                                size: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                showAddHop = !showAddHop;
                                                if (showAddHop) {
                                                  showAddMalt = false;
                                                  showAddOther = false;
                                                  showAddMashStep = false;
                                                }
                                              });
                                              if (showAddHop) {
                                                addHopFocusNode.requestFocus();
                                              }
                                            },
                                          ),
                                        ]),
                                    Wrap(
                                        alignment: WrapAlignment.start,
                                        runAlignment: WrapAlignment.start,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
                                        runSpacing: 15,
                                        spacing: 15,
                                        children:
                                            (hops.keys.toList()
                                                  // ..sort((a, b) =>
                                                  //     b!.compareTo(a!))
                                            )
                                                .map((time) => SizedBox(
                                                    width: 250,
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            time == null
                                                                ? "-"
                                                                : "$time minuten",
                                                            style: const TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                            ),
                                                          ),
                                                          ...hops[time]!.map((hop) =>
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        "${hop.amount}g ${hop.name} (${hop.alphaAcid}%)"),
                                                                    IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          hops[time]!
                                                                              .remove(hop);
                                                                          if (hops[time]!
                                                                              .isEmpty) {
                                                                            hops.remove(time);
                                                                          }
                                                                        });
                                                                      },
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .close),
                                                                      splashRadius:
                                                                          12,
                                                                      iconSize:
                                                                          15,
                                                                      padding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      constraints:
                                                                          const BoxConstraints(),
                                                                    )
                                                                  ]))
                                                        ])))
                                                .toList()),
                                  ])
                            ]),
                            const SizedBox(
                              height: 10,
                            ),
                            if (showAddHop)
                              Container(
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  padding: const EdgeInsets.all(5),
                                  margin: const EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      ...getHopFields(),
                                      const SizedBox(height: 10),
                                      OutlinedButton(
                                          onPressed: hopType == null ||
                                                  hopAmount == null ||
                                                  hopTime == null
                                              ? null
                                              : () {
                                                  setState(() {
                                                    HopSpec hop = HopSpec(
                                                        hopType,
                                                        hopAlphaAcid,
                                                        hopAmount);

                                                    if (hops
                                                        .containsKey(hopTime)) {
                                                      hops[hopTime]!.add(hop);
                                                    } else {
                                                      hops[hopTime!] = [hop];
                                                    }

                                                    hopType = null;
                                                    hopAlphaAcid = null;
                                                    hopAmount = null;
                                                  });
                                                },
                                          child: const Text("Voeg toe")),
                                      const SizedBox(height: 5),
                                    ],
                                  )),
                            const SizedBox(height: 10),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Gist",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Wrap(spacing: 70, children: [
                                    DropDownRow(
                                        label: "Naam",
                                        initialValue: yeast.name,
                                        onChanged: (value) {
                                          setState(() {
                                            yeast.name = value;
                                          });
                                        }, items: Store.products[Yeast]?.map((e) => e.name).toList().cast<String>()),
                                    DoubleTextFieldRow(
                                        label: "Hoeveelheid (g)",
                                        initialValue: yeast.amount,
                                        onChanged: (value) {
                                          setState(() {
                                            yeast.amount = value;
                                          });
                                        }),
                                  ]),
                                ]),
                            const SizedBox(height: 10),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Kooksuiker",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Wrap(spacing: 70, children: [
                                    DropDownRow(
                                        label: "Naam",
                                        initialValue: cookingSugar.name,
                                        onChanged: (value) {
                                          setState(() {
                                            cookingSugar.name = value;
                                          });
                                        }, items: Store.products[Sugar]?.map((e) => e.name).toList().cast<String>(),),
                                    DoubleTextFieldRow(
                                        label: "Hoeveelheid (g)",
                                        initialValue: cookingSugar.amount,
                                        onChanged: (value) {
                                          setState(() {
                                            cookingSugar.amount = value;
                                          });
                                        }),
                                    DoubleTextFieldRow(
                                        label: "Tijd",
                                        initialValue: cookingSugarTime,
                                        onChanged: (value) {
                                          setState(() {
                                            cookingSugarTime = value;
                                          });
                                        }),
                                  ]),
                                ]),
                            const SizedBox(height: 10),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Bottelsuiker",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Wrap(spacing: 70, children: [
                                    DropDownRow(
                                        label: "Naam",
                                        initialValue: bottleSugar.name,
                                        onChanged: (value) {
                                          setState(() {
                                            bottleSugar.name = value;
                                          });
                                        }, items: Store.products[Sugar]?.map((e) => e.name).toList().cast<String>()),
                                    DoubleTextFieldRow(
                                        label: "Hoeveelheid (g/L)",
                                        initialValue: bottleSugar.amount,
                                        onChanged: (value) {
                                          setState(() {
                                            bottleSugar.amount = value;
                                          });
                                        }),
                                  ])
                                ]),
                            const SizedBox(height: 10),
                            Column(children: [
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Overige",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 5),
                                    InkWell(
                                      child: Container(
                                        height: 15,
                                        width: 15,
                                        alignment: Alignment.center,
                                        decoration: const ShapeDecoration(
                                          color: Colors.lightBlue,
                                          shape: CircleBorder(),
                                        ),
                                        child: Icon(
                                          showAddOther
                                              ? Icons.remove
                                              : Icons.add,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          showAddOther = !showAddOther;
                                          if (showAddOther) {
                                            showAddMalt = false;
                                            showAddHop = false;
                                            showAddMashStep = false;
                                          }
                                        });
                                        if (showAddOther) {
                                          addOtherFocusNode.requestFocus();
                                        }
                                      },
                                    ),
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Wrap(
                                        alignment: WrapAlignment.start,
                                        runAlignment: WrapAlignment.start,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
                                        runSpacing: 15,
                                        spacing: 15,
                                        children:
                                            (others.keys.toList()
                                                  // ..sort((a, b) =>
                                                  //     b!.compareTo(a!))
                                                )
                                                .map((time) => SizedBox(
                                                    width: 250,
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            time == null
                                                                ? "-"
                                                                : "$time minuten",
                                                            style: const TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                            ),
                                                          ),
                                                          ...others[time]!.map((other) =>
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        "${other.amount}g ${other.name}"),
                                                                    IconButton(
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .close),
                                                                      splashRadius:
                                                                          12,
                                                                      iconSize:
                                                                          15,
                                                                      padding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      constraints:
                                                                          const BoxConstraints(),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          others[time]!
                                                                              .remove(other);
                                                                          if (others[time]!
                                                                              .isEmpty) {
                                                                            others.remove(time);
                                                                          }
                                                                        });
                                                                      },
                                                                    )
                                                                  ]))
                                                        ])))
                                                .toList())
                                  ]),
                            ]),
                            const SizedBox(
                              height: 10,
                            ),
                            if (showAddOther)
                              Container(
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  padding: const EdgeInsets.all(5),
                                  margin: const EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      ...getOtherFields(),
                                      const SizedBox(height: 10),
                                      OutlinedButton(
                                          onPressed: otherName == null ||
                                                  otherAmount == null ||
                                                  otherTime == null
                                              ? null
                                              : () {
                                                  setState(() {
                                                    ProductSpec other =
                                                        ProductSpec(
                                                            otherName,
                                                            otherAmount);

                                                    if (others.containsKey(
                                                        otherTime)) {
                                                      others[otherTime]!
                                                          .add(other);
                                                    } else {
                                                      others[otherTime!] = [
                                                        other
                                                      ];
                                                    }

                                                    otherName = null;
                                                    otherTime = null;
                                                    otherAmount = null;
                                                  });
                                                },
                                          child: const Text("Voeg toe")),
                                      const SizedBox(height: 5),
                                    ],
                                  )),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Maischschema",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 5),
                                  InkWell(
                                    child: Container(
                                      height: 15,
                                      width: 15,
                                      alignment: Alignment.center,
                                      decoration: const ShapeDecoration(
                                        color: Colors.lightBlue,
                                        shape: CircleBorder(),
                                      ),
                                      child: Icon(
                                        showAddMashStep
                                            ? Icons.remove
                                            : Icons.add,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        showAddMashStep = !showAddMashStep;
                                        if (showAddMashStep) {
                                          showAddOther = false;
                                          showAddHop = false;
                                          showAddMalt = false;
                                        }
                                      });
                                      if (showAddMalt) {
                                        addMaltFocusNode.requestFocus();
                                      }
                                    },
                                  ),
                                ]),
                            const SizedBox(height: 10),
                            ...mashSteps.map((step) => Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          "${step.temp}°C: ${step.time} minuten"),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        splashRadius: 12,
                                        iconSize: 15,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          setState(() {
                                            mashSteps.remove(step);
                                          });
                                        },
                                      )
                                    ])),
                            const SizedBox(height: 10),
                            if (showAddMashStep)
                              Container(
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  padding: const EdgeInsets.all(5),
                                  margin: const EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      ...getMashStepFields(),
                                      const SizedBox(height: 10),
                                      OutlinedButton(
                                          onPressed: mashTime == null &&
                                                  mashTemp == null
                                              ? null
                                              : () {
                                                  setState(() {
                                                    MashStep step = MashStep(
                                                        mashTemp!.round(),
                                                        mashTime!.round());
                                                    mashSteps.add(step);

                                                    mashTemp = null;
                                                    mashTime = null;
                                                  });
                                                },
                                          child: const Text("Voeg toe")),
                                      const SizedBox(height: 5),
                                    ],
                                  )),
                          ]),
                      const SizedBox(height: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Opmerkingen",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                                height: 100,
                                child: TextFormField(
                                  initialValue: remarks,
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
                                    remarks = value;
                                  },
                                )),
                          ]),
                    ],
                  ))),
              const Divider(),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: name == null
                    ? null
                    : () async {
                        Cooking cooking = Cooking(hops.keys
                            .map((time) => CookingScheduleStep(
                                time,
                                hops[time]
                                        ?.map((hs) =>
                                            SpecToProducts(hs, [], null))
                                        .toList() ??
                                    []))
                            .toList());
                        if (cookingSugar.amount != null || cookingSugar.name != null) {
                          cooking.addStep(cookingSugarTime,
                            [SpecToProducts(cookingSugar, [], null)]);
                        }
                        for (double? time in others.keys) {
                          cooking.addStep(
                              time,
                              others[time]!
                                  .map((ps) =>
                                      SpecToProducts(ps, [], null))
                                  .toList());
                        }

                        Recipe newRecipe = Recipe(
                            widget.recipe?.id,
                            name!,
                            style,
                            source,
                            amount,
                            startSG,
                            finalSG,
                            efficiency == null ? null : efficiency! / 100,
                            color,
                            bitter,
                            Mashing(
                                malts
                                    .map((m) =>
                                        SpecToProducts(m, [], null))
                                    .toList(),
                                mashSteps,
                                mashWater),
                            rinsingWater,
                            cooking,
                            yeast.amount != null || yeast.name != null ? yeast : null,
                            minTemp,
                            maxTemp,
                            bottleSugar.amount != null || bottleSugar.name != null ? bottleSugar : null,
                            remarks);
                        await Store.saveRecipe(newRecipe);

                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) =>
                                    RecipeDetails(recipe: newRecipe)),
                            (Route<dynamic> route) => route.isFirst);
                        }
                      },
                child: const Text("Opslaan"),
              ),
            ])));
  }

  // showDeleteDialog() {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return SimpleDialog(
  //             title: const SelectableText('Recept verwijderen'),
  //             children: [
  //               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //                 Container(
  //                     padding: const EdgeInsets.only(left: 25, right: 25),
  //                     child: const SelectableText(
  //                         'Weet je zeker dat je dit recept wil verwijderen?')),
  //                 const SizedBox(height: 20),
  //                 Center(
  //                     child: Wrap(spacing: 10, children: [
  //                   OutlinedButton(
  //                       onPressed: () async {
  //                         await Store.removeRecipe(recipe!);
  //                         Navigator.of(context).pushAndRemoveUntil(
  //                             MaterialPageRoute<void>(
  //                               builder: (BuildContext context) =>
  //                                   MyHomePage(title: 'Bier Brouwen', selectedPage: 1,),
  //                             ),
  //                             (route) => false);
  //                       },
  //                       child: const Text('Ja')),
  //                   ElevatedButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child: const Text('Nee')),
  //                 ]))
  //               ])
  //             ]);
  //       });
  // }
}
