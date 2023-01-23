import 'dart:core';

import 'package:beer_brewer/data/database_controller.dart';
import 'package:beer_brewer/recipe_details.dart';
import 'package:flutter/material.dart';
import 'data/store.dart';
import 'form/DoubleTextFieldRow.dart';
import 'form/DropDownRow.dart';
import 'form/TextFieldRow.dart';
import 'main.dart';

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
  double? endSG;
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

  String? yeastName;
  double? yeastAmount;

  String? cookingSugarName;
  double? cookingSugarAmount;
  double? cookingSugarTime;

  String? bottleSugarName;
  double? bottleSugarAmount;

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
      TextFieldRow(
          focusNode: addOtherFocusNode,
          label: "Soort",
          initialValue: otherName,
          onChanged: (value) {
            setState(() {
              otherName = value;
            });
          }),
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
          items: [
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

  void initData() {
    setState(() {
      if (recipe != null) {
        name = recipe?.name;
        style = recipe?.style;
        source = recipe?.source;
        amount = recipe?.amount;
        startSG = recipe?.expStartSG;
        endSG = recipe?.expFinalSG;
        efficiency =
            recipe?.efficiency == null ? null : (recipe?.efficiency)! * 100;
        color = recipe?.color;
        bitter = recipe?.bitter;
        mashWater = recipe?.mashing.water;
        rinsingWater = recipe?.rinsingWater;

        malts = recipe?.mashing.malts ?? [];
        mashSteps = recipe?.mashing.steps ?? [];
        for (CookingStep step in recipe!.cooking.steps) {
          List<HopSpec> hopsForTime =
              step.products.whereType<HopSpec>().toList();
          if (hopsForTime.isNotEmpty) hops[step.time] = hopsForTime;
        }
        for (CookingStep step in recipe!.cooking.steps) {
          List<ProductSpec> othersForTime = step.products
              .where((p) => !(p is HopSpec || p is CookingSugarSpec))
              .toList();
          if (othersForTime.isNotEmpty) others[step.time] = othersForTime;
        }

        yeastName = recipe?.yeast.name;
        yeastAmount = recipe?.yeast.amount;

        Iterable<CookingStep> steps = recipe!.cooking.steps.where((step) =>
            step.products.any((product) => product is CookingSugarSpec));

        if (steps.isNotEmpty) {
          CookingStep step = steps.first;
          CookingSugarSpec css =
              step.products.whereType<CookingSugarSpec>().first;
          cookingSugarName = css.name;
          cookingSugarAmount = css.amount;
          cookingSugarTime = step.time;
        }

        bottleSugarName = recipe!.bottleSugar.name;
        bottleSugarAmount = recipe!.bottleSugar.amount;

        minTemp = recipe!.yeastTempMin;
        maxTemp = recipe!.yeastTempMax;

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
      title: Text("Maak recept"),
      actions: [
        if (widget.recipe != null)
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  showDeleteDialog();
                },
                child: Icon(
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
                              Text(
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
                                  items: [
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
                              Text(
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
                              Text(
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
                                  initialValue: endSG,
                                  onChanged: (value) {
                                    setState(() {
                                      endSG = value;
                                    });
                                  }),
                              DoubleTextFieldRow(
                                  label: "Rendement (%)",
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
                              Text(
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
                      SizedBox(height: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ingrediënten",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Mout",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 5),
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
                                              if (showAddMalt)
                                                addMaltFocusNode.requestFocus();
                                            },
                                          ),
                                        ]),
                                    ...malts.map((malt) => Row(children: [
                                          Text(
                                              "${malt.amount}g ${malt.name} (${malt.ebcToString()})"),
                                          IconButton(
                                            icon: const Icon(Icons.close),
                                            splashRadius: 12,
                                            iconSize: 15,
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                            onPressed: () {
                                              setState(() {
                                                malts.remove(malt);
                                              });
                                            },
                                          )
                                        ])),
                                  ])
                            ]),
                            SizedBox(
                              height: 10,
                            ),
                            if (showAddMalt)
                              Container(
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      ...getMaltFields(),
                                      SizedBox(height: 5),
                                      OutlinedButton(
                                          onPressed: maltType == null ||
                                                  maltAmount == null
                                              ? null
                                              : () {
                                                  setState(() {
                                                    MaltSpec malt = MaltSpec(
                                                        maltType!,
                                                        maltMinEBC,
                                                        maltMaxEBC,
                                                        maltAmount!);
                                                    malts.add(malt);

                                                    maltType = null;
                                                    maltMinEBC = null;
                                                    maltMaxEBC = null;
                                                    maltAmount = null;
                                                  });
                                                },
                                          child: Text("Voeg toe")),
                                      SizedBox(height: 5),
                                    ],
                                  )),
                            SizedBox(height: 10),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Hop",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 5),
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
                                              if (showAddHop)
                                                addHopFocusNode.requestFocus();
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
                                                  ..sort((a, b) =>
                                                      b!.compareTo(a!)))
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
                                                            style: TextStyle(
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
                                                                              .isEmpty)
                                                                            hops.remove(time);
                                                                        });
                                                                      },
                                                                      icon: Icon(
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
                                                                          BoxConstraints(),
                                                                    )
                                                                  ]))
                                                        ])))
                                                .toList()),
                                  ])
                            ]),
                            SizedBox(
                              height: 10,
                            ),
                            if (showAddHop)
                              Container(
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      ...getHopFields(),
                                      SizedBox(height: 5),
                                      OutlinedButton(
                                          onPressed: hopType == null ||
                                                  hopAmount == null ||
                                                  hopTime == null
                                              ? null
                                              : () {
                                                  setState(() {
                                                    HopSpec hop = HopSpec(
                                                        hopType!,
                                                        hopAlphaAcid ?? 0,
                                                        hopAmount!);
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
                                          child: Text("Voeg toe")),
                                      SizedBox(height: 5),
                                    ],
                                  )),
                            SizedBox(height: 10),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Gist",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Wrap(spacing: 70, children: [
                                    TextFieldRow(
                                        label: "Naam",
                                        initialValue: yeastName,
                                        onChanged: (value) {
                                          setState(() {
                                            yeastName = value;
                                          });
                                        }),
                                    DoubleTextFieldRow(
                                        label: "Hoeveelheid (g)",
                                        initialValue: yeastAmount,
                                        onChanged: (value) {
                                          setState(() {
                                            yeastAmount = value;
                                          });
                                        }),
                                  ]),
                                ]),
                            SizedBox(height: 10),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Kooksuiker",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Wrap(spacing: 70, children: [
                                    TextFieldRow(
                                        label: "Naam",
                                        initialValue: cookingSugarName,
                                        onChanged: (value) {
                                          setState(() {
                                            cookingSugarName = value;
                                          });
                                        }),
                                    DoubleTextFieldRow(
                                        label: "Hoeveelheid (g)",
                                        initialValue: cookingSugarAmount,
                                        onChanged: (value) {
                                          setState(() {
                                            cookingSugarAmount = value;
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
                            SizedBox(height: 10),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bottelsuiker",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Wrap(spacing: 70, children: [
                                    TextFieldRow(
                                        label: "Naam",
                                        initialValue: bottleSugarName,
                                        onChanged: (value) {
                                          setState(() {
                                            bottleSugarName = value;
                                          });
                                        }),
                                    DoubleTextFieldRow(
                                        label: "Hoeveelheid (g/L)",
                                        initialValue: bottleSugarAmount,
                                        onChanged: (value) {
                                          setState(() {
                                            bottleSugarAmount = value;
                                          });
                                        }),
                                  ])
                                ]),
                            SizedBox(height: 10),
                            Column(children: [
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Overige",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 5),
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
                                        if (showAddOther)
                                          addOtherFocusNode.requestFocus();
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
                                                  ..sort((a, b) =>
                                                      b!.compareTo(a!)))
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
                                                            style: TextStyle(
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
                                                                          BoxConstraints(),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          others[time]!
                                                                              .remove(other);
                                                                          if (others[time]!
                                                                              .isEmpty)
                                                                            others.remove(time);
                                                                        });
                                                                      },
                                                                    )
                                                                  ]))
                                                        ])))
                                                .toList())
                                  ]),
                            ]),
                            SizedBox(
                              height: 10,
                            ),
                            if (showAddOther)
                              Container(
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      ...getOtherFields(),
                                      SizedBox(height: 5),
                                      OutlinedButton(
                                          onPressed: otherName == null ||
                                                  otherAmount == null ||
                                                  otherTime == null
                                              ? null
                                              : () {
                                                  setState(() {
                                                    ProductSpec other =
                                                        ProductSpec(otherName!,
                                                            otherAmount!);
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
                                          child: Text("Voeg toe")),
                                      SizedBox(height: 5),
                                    ],
                                  )),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Maischschema",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 5),
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
                                      if (showAddMalt)
                                        addMaltFocusNode.requestFocus();
                                    },
                                  ),
                                ]),
                            SizedBox(height: 10),
                            ...mashSteps.map((step) =>
                                Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .start,
                                    children: [
                                      Text("${step.temp}°C: ${step.time} minuten"),
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
                                        BoxConstraints(),
                                        onPressed:
                                            () {
                                          setState(
                                                  () {
                                                mashSteps.remove(step);
                                              });
                                        },
                                      )
                                    ])),
                            SizedBox(height: 10),
                            if (showAddMashStep)
                              Container(
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      ...getMashStepFields(),
                                      SizedBox(height: 5),
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
                                          child: Text("Voeg toe")),
                                      SizedBox(height: 5),
                                    ],
                                  )),
                          ]),
                      SizedBox(height: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Opmerkingen",
                              style:
                              TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
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
                onPressed: name == null ||
                        style == null ||
                        amount == null ||
                        mashWater == null ||
                        rinsingWater == null
                    ? null
                    : () async {
                        Recipe finalRecipe = await Store.saveRecipe(
                          widget.recipe?.id,
                          name!,
                          style!,
                          source,
                          amount!,
                          startSG,
                          endSG,
                          efficiency == null ? null : efficiency! / 100,
                          color,
                          bitter,
                          mashWater!,
                          rinsingWater!,
                          malts,
                          mashSteps,
                          hops,
                          yeastName,
                          yeastAmount,
                          cookingSugarName,
                          cookingSugarAmount,
                          cookingSugarTime,
                          bottleSugarName,
                          bottleSugarAmount,
                          others,
                          minTemp,
                          maxTemp,
                          remarks
                        );
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) =>
                                    RecipeDetails(recipe: finalRecipe)),
                            (Route<dynamic> route) => route.isFirst);
                      },
                child: Text("Opslaan"),
              ),
            ])));
  }

  showDeleteDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: const SelectableText('Recept verwijderen'),
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: const SelectableText(
                          'Weet je zeker dat je dit recept wil verwijderen?')),
                  const SizedBox(height: 20),
                  Center(
                      child: Wrap(spacing: 10, children: [
                    OutlinedButton(
                        onPressed: () async {
                          await Store.removeRecipe(recipe!);
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    MyHomePage(title: 'Bier Brouwen'),
                              ),
                              (route) => false);
                        },
                        child: const Text('Ja')),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Nee')),
                  ]))
                ])
              ]);
        });
  }
}
