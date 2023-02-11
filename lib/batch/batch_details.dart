import 'dart:math';

import 'package:beer_brewer/form/DoubleTextFieldRow.dart';
import 'package:beer_brewer/form/TextFieldRow.dart';
import 'package:beer_brewer/screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/spec_to_products.dart';
import '../steps/bottling.dart';
import '../data/store.dart';
import '../models/batch.dart';
import '../models/product.dart';
import '../steps/lagering.dart';
import '../steps/preparation.dart';
import '../util.dart';
import 'batch_creator.dart';

class BatchDetails extends StatefulWidget {
  final Batch batch;

  const BatchDetails({Key? key, required this.batch}) : super(key: key);

  @override
  State<BatchDetails> createState() => _BatchDetailsState();
}

class _BatchDetailsState extends State<BatchDetails> {
  late Batch batch;
  late BatchStatus status;
  late double availableWidth;

  Row _getRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
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

  @override
  void initState() {
    batch = widget.batch;
    status = batch.getStatus();

    super.initState();
  }

  Widget brewInfo() {
    Map<Product, num> shoppingList = batch.getShoppingList();

    return SizedBox(
        width: 350,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Algemeen",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _getRow("Naam", Text(batch.name)),
              _getRow("Stijl", Text(batch.style ?? "-")),
              _getRow("Hoeveelheid", Text("${batch.amount} liter")),
              const SizedBox(height: 10),
              _getRow(
                  "Start",
                  Text(batch.expStartSG == null
                      ? "-"
                      : ("${batch.expStartSG!.toStringAsFixed(3)} SG"))),
              _getRow(
                  "Eind",
                  Text(batch.expFinalSG == null
                      ? "-"
                      : ("${batch.expFinalSG!.toStringAsFixed(3)} SG"))),
              _getRow(
                  "Alcohol",
                  Text(batch.expFinalSG == null || batch.expStartSG == null
                      ? "-"
                      : ("${((batch.expStartSG! - batch.expFinalSG!) * 131.25).toStringAsFixed(1)}%"))),
              const SizedBox(height: 10),
              _getRow("Kleur",
                  Text(batch.color == null ? "-" : "${batch.color} EBC")),
              _getRow("Bitterheid",
                  Text(batch.bitter == null ? "-" : "${batch.bitter} EBU")),
              const SizedBox(height: 10),
              _getRow("BIAB", Text(batch.biab ? "Ja" : "Nee")),
              _getRow(
                  "Maischwater",
                  Text(batch.mashing.water == null
                      ? "-"
                      : "${batch.mashing.water} liter")),
              if (!batch.biab)
                _getRow(
                    "Spoelwater",
                    Text(batch.rinsingWater == null
                        ? "-"
                        : "${batch.rinsingWater} liter")),
              _getRow(
                  "Bottelsuiker",
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                        Text(batch.bottleSugar == null ||
                                batch.bottleSugar!.products == null ||
                                batch.bottleSugar!.products!.isEmpty
                            ? "-"
                            : "${Util.amountToString(batch.bottleSugar!.products![0].amount)}/L ${batch.bottleSugar!.products![0].product.name}"),
                        if (batch.bottleSugar?.products?[0].explanation != null)
                          Text(
                            batch.bottleSugar!.products![0].explanation!,
                            style: TextStyle(fontStyle: FontStyle.italic),
                            textAlign: TextAlign.right,
                          )
                      ]))),
              const SizedBox(height: 20),
              const Text(
                "Status",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _getRow(
                  "Brouwdatum",
                  batch.brewDate == null
                      ? const Text("-")
                      : Text(DateFormat("dd-MM-yyyy").format(batch.brewDate!))),
              _getRow(
                  "Lagerdatum",
                  batch.lagerDate == null
                      ? const Text("-")
                      : Text(
                          DateFormat("dd-MM-yyyy").format(batch.lagerDate!))),
              _getRow(
                  "Botteldatum",
                  batch.bottleDate == null
                      ? const Text("-")
                      : Text(
                          DateFormat("dd-MM-yyyy").format(batch.bottleDate!))),
              _getRow(
                  "Status",
                  Text(batch.getStatus().text +
                      (batch.daysLeft(batch.getStatus()) == null
                          ? ""
                          : " (nog ${batch.daysLeft(batch.getStatus())} dagen)"))),
              const SizedBox(height: 20),
              if (batch.sgMeasurements.isNotEmpty)
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  const Text(
                    "SG-metingen",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (batch.brewDate != null)
                    TextButton(
                        onPressed: () {
                          addSGMeasurement((DateTime date, num value) async {
                            if (value >= 1000) value = value / 1000;
                            Batch updatedBatch =
                                await Store.addSGToBatch(batch, date, value);
                            setState(() {
                              batch.sgMeasurements =
                                  updatedBatch.sgMeasurements;
                            });
                          });
                        },
                        child: const Text("Voeg toe"))
                ]),
              if (batch.sgMeasurements.isNotEmpty) const SizedBox(height: 10),
              if (batch.sgMeasurements.isNotEmpty)
                SizedBox(
                    width: availableWidth,
                    child: Table(
                      border: TableBorder.all(),
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        const TableRow(children: [
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Datum",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: Text("SG",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: Text("Alcohol",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ]),
                        ...(batch.sgMeasurements.keys.toList()..sort()).map(
                          (date) {
                            num sg = batch.sgMeasurements[date]!;
                            num? alcohol = batch.getAlcoholPercentage(sg);
                            return TableRow(children: [
                              Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                      DateFormat("dd-MM-yyyy").format(date))),
                              Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(sg.toStringAsFixed(3))),
                              Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(alcohol == 0
                                      ? "-"
                                      : ("${alcohol!.toStringAsFixed(1)}%"))),
                            ]);
                          },
                        )
                      ],
                    )),
              const SizedBox(height: 20),
              if (shoppingList.isNotEmpty)
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  const Text(
                    "Boodschappenlijst",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ]),
              if (shoppingList.isNotEmpty) const SizedBox(height: 10),
              if (shoppingList.isNotEmpty)
                SizedBox(
                    width: availableWidth,
                    child: Table(
                      border: TableBorder.all(),
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        const TableRow(children: [
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Product",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: Text("Nodig",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ]),
                        ...(shoppingList.keys.toList()).map(
                          (product) => TableRow(children: [
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(product.name)),
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(Util.amountToString(
                                    shoppingList[product]))),
                          ]),
                        )
                      ],
                    )),
            ]));
  }

  Widget generalInfo() {
    return SizedBox(
        width: 350,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Maischen",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      batch.mashing.malts.isEmpty
                          ? const Text("Geen mouten beschikbaar.",
                              style: TextStyle(fontStyle: FontStyle.italic))
                          : SizedBox(
                              width: availableWidth,
                              child: Table(
                                border: TableBorder.all(),
                                defaultColumnWidth:
                                    const IntrinsicColumnWidth(),
                                children: [
                                  const TableRow(children: [
                                    Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "Type",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text("EBC",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text("Gewicht",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)))
                                  ]),
                                  ...batch.mashing.malts
                                      .expand((stp) => stp.products ?? [])
                                      .map(
                                        (pi) => TableRow(children: [
                                          Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(pi.product.name),
                                                    if (pi.explanation != null)
                                                      Text(pi.explanation,
                                                          style: TextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic))
                                                  ])),
                                          Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text((pi.product as Malt)
                                                  .ebcToString())),
                                          Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(Util.amountToString(
                                                  (pi as ProductInstance)
                                                      .amount)))
                                        ]),
                                      )
                                ],
                              )),
                      const SizedBox(height: 10),
                      SizedBox(
                          width: availableWidth,
                          child: batch.getMashingSchedule())
                    ])
              ]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Koken",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                          width: availableWidth,
                          child: batch.getCookingSchedule())
                    ])
              ]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Vergisten",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      batch.yeast == null ||
                              batch.yeast!.products == null ||
                              batch.yeast!.products!.isEmpty ||
                              batch.yeast?.products?[0].product.name == null &&
                                  batch.yeast?.products?[0].product
                                          .amountInStock ==
                                      null
                          ? const Text("Geen gist beschikbaar.",
                              style: TextStyle(fontStyle: FontStyle.italic))
                          : SizedBox(
                              width: availableWidth,
                              child: Table(
                                  border: TableBorder.all(),
                                  defaultColumnWidth: FixedColumnWidth(50.0),
                                  children: [
                                    TableRow(children: [
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            "Gist",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          child: Text("Gewicht",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis)),
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          child: Text("Temperatuur",
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    ]),
                                    if (batch.yeast != null)
                                      TableRow(children: [
                                        Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(batch.yeast?.products?[0]
                                                          .product.name ??
                                                      "-"),
                                                  if (batch.yeast?.products?[0]
                                                          .explanation !=
                                                      null)
                                                    Text(
                                                        batch
                                                            .yeast!
                                                            .products![0]
                                                            .explanation!,
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic))
                                                ])),
                                        Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(batch
                                                    .yeast?.products?[0].product
                                                    .amountToString() ??
                                                "-")),
                                        Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                                "${batch.fermTempMin} - ${batch.fermTempMax}ºC")),
                                      ]),
                                  ])),
                    ])
              ]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Opmerkingen",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Text(batch.remarks ?? "-")),
                    ])
              ]),
            ]));
  }

  getBottomButton() {
    if (status == BatchStatus.readyToBrew) {
      return ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => PreparationStep(batch: batch)),
            );
          },
          child: Text("Brouwen"));
    }
    if (status == BatchStatus.readyToLager) {
      return ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => LageringStep(batch: batch)),
            );
          },
          child: Text("Lageren"));
    }
    if (status == BatchStatus.waitingForFermentation) {
      return OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => LageringStep(batch: batch)),
            );
          },
          child: Text("Lageren"));
    }
    if (status == BatchStatus.readyToBottle) {
      return ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => BottlingStep(batch: batch)),
            );
          },
          child: Text("Bottelen"));
    }
    if (status == BatchStatus.waitingForLagering) {
      return OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => BottlingStep(batch: batch)),
            );
          },
          child: Text("Bottelen"));
    }
  }

  @override
  Widget build(BuildContext context) {
    availableWidth = min(MediaQuery.of(context).size.width - 40, 350);

    return Screen(
        title: "Batch",
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => BatchCreator(batch: batch)),
                  );
                },
                child: const Icon(
                  Icons.edit,
                  size: 26.0,
                ),
              )),
        ],
        bottomButton: getBottomButton(),
        child: Column(children: [
          // width: 400,
          MediaQuery.of(context).size.width >= 800
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    brewInfo(),
                    const SizedBox(width: 50),
                    generalInfo()
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    brewInfo(),
                    const SizedBox(width: 50),
                    generalInfo()
                  ],
                )
        ]));
  }

  addSGMeasurement(Function addMeasurement) {
    String sgDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
    num? sgValue;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            bool fieldsAreValid() {
              bool dateIsValid =
                  DateFormat("dd-MM-yyyy").tryParse(sgDate) != null;
              bool valueIsValid = sgValue != null;
              return dateIsValid && valueIsValid;
            }

            return SimpleDialog(
                title: const Center(child: Text("Voeg SG-meting toe")),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      TextFieldRow(
                        label: "Datum",
                        initialValue: sgDate,
                        onChanged: (value) {
                          setState(() {
                            sgDate = value;
                          });
                        },
                      ),
                      const SizedBox(height: 5),
                      DoubleTextFieldRow(
                        label: "Waarde",
                        onChanged: (value) {
                          setState(() {
                            sgValue = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: fieldsAreValid()
                              ? () {
                                  addMeasurement(
                                      DateFormat("dd-MM-yyyy").parse(sgDate),
                                      sgValue);
                                  Navigator.pop(context);
                                }
                              : null,
                          child: const Text("Voeg toe"))
                    ]),
                  ),
                ]);
          });
        });
  }
}
