import 'package:beer_brewer/form/DoubleTextFieldRow.dart';
import 'package:beer_brewer/form/TextFieldRow.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../brew_step.dart';
import '../data/store.dart';
import '../main.dart';
import '../models/batch.dart';
import '../models/product.dart';
import '../steps/cooking.dart';
import '../steps/cooling.dart';
import '../steps/fermentation.dart';
import '../steps/filtering.dart';
import '../steps/malting.dart';
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

  Row _getRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        value
      ],
    );
  }

  List<Map<String, dynamic>> getTexts(Batch batch) {
    return [
      {"title": "Voorbereiding", "description": PreparationStep(batch: batch)},
      {"title": "Maischen", "description": MaltingStep(batch: batch)},
      {"title": "Filteren", "description": FilterStep(batch: batch)},
      {"title": "Koken", "description": CookingStep(batch: batch)},
      {
        "title": "Afkoelen",
        "description": CoolingStep(
          batch: batch,
        )
      },
      {
        "title": "Vergisten",
        "description": FermentationStep(
          batch: batch,
        )
      },
    ];
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const MyHomePage(
            title: 'Bier Brouwen',
            selectedPage: 0,
          ),
        ),
        (route) => false);
    return true;
  }

  @override
  void initState() {
    batch = widget.batch;
    status = batch.getStatus();
    super.initState();
  }

  Widget brewInfo() {
    return SizedBox(
        width: 350,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              _getRow("Status", Text(batch.getStatus().text)),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                const Text(
                  "SG-metingen",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (batch.brewDate != null) TextButton(
                    onPressed:() {
                      addSGMeasurement((DateTime date, double value) async {
                        Batch updatedBatch =
                            await Store.addSGToBatch(batch, date, value);
                        setState(() {
                          batch.sgMeasurements = updatedBatch.sgMeasurements;
                        });
                      });
                    },
                    child: const Text("Voeg toe"))
              ]),
              const SizedBox(height: 10),
              batch.sgMeasurements.isEmpty
                  ? const Text("Geen metingen beschikbaar.",
                      style: TextStyle(fontStyle: FontStyle.italic))
                  : Table(
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
                        ]),
                        ...(batch.sgMeasurements.keys.toList()..sort()).map(
                          (date) => TableRow(children: [
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                    DateFormat("dd-MM-yyyy").format(date))),
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(batch.sgMeasurements[date]!
                                    .toStringAsFixed(3))),
                          ]),
                        )
                      ],
                    ),
            ]));
  }

  Widget generalInfo() {
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
              _getRow("Maischwater", Text("${batch.mashing.water} liter")),
              _getRow("Spoelwater", Text("${batch.rinsingWater} liter")),
              _getRow(
                  "Bottelsuiker",
                  Text(batch.bottleSugar == null || batch.bottleSugar!.products == null || batch.bottleSugar!.products!.isEmpty ? "-" : batch.bottleSugar!.products![0].product
                          .getProductString())),
              const SizedBox(height: 20),
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
                          : Table(
                              border: TableBorder.all(),
                              defaultColumnWidth: const IntrinsicColumnWidth(),
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
                                            child: Text(pi.product.name)),
                                        Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text((pi.product as Malt)
                                                .ebcToString())),
                                        Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                                Util.amountToString(pi.amount)))
                                      ]),
                                    )
                              ],
                            ),
                      const SizedBox(height: 10),
                      batch.getMashingSchedule()
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
                      batch.getCookingSchedule()
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
                      batch.yeast == null || batch.yeast!.products == null || batch.yeast!.products!.isEmpty ||
                      batch.yeast?.products?[0].product.name == null &&
                              batch.yeast?.products?[0].product.amount == null
                          ? const Text("Geen gist beschikbaar.",
                              style: TextStyle(fontStyle: FontStyle.italic))
                          : Table(
                              border: TableBorder.all(),
                              defaultColumnWidth: const IntrinsicColumnWidth(),
                              children: [
                                  const TableRow(children: [
                                    Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "Gist",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text("Gewicht",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text("Temperatuur",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ]),
                                  if (batch.yeast != null)
                                    TableRow(children: [
                                      Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(batch.yeast?.products?[0]
                                                  .product.name ??
                                              "-")),
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
                                ]),
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
                      SizedBox(width: 300, child: Text(batch.remarks ?? "-")),
                    ])
              ]),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: const Text("Batch"),
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
    );

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            appBar: appBar,
            body: Column(children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height -
                      appBar.preferredSize.height -
                      80,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                            child: SingleChildScrollView(
                                child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(children: [
                                      // width: 400,
                                      MediaQuery.of(context).size.width >= 700
                                          ? Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                brewInfo(),
                                                const SizedBox(width: 50),
                                                generalInfo()
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                brewInfo(),
                                                const SizedBox(width: 50),
                                                generalInfo()
                                              ],
                                            )
                                    ]))))
                      ])),
              const Divider(),
              const SizedBox(height: 15),
              if (status == BatchStatus.readyToBrew)
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => BrewStep(
                                batch: batch, contentList: getTexts(batch))),
                      );
                    },
                    child: Text("Brouwen")),
              if (status == BatchStatus.readyToLager)
                ElevatedButton(onPressed: () {}, child: Text("Lageren")),
              if (status == BatchStatus.waitingForFermentation)
                OutlinedButton(onPressed: () {}, child: Text("Lageren")),
              if (status == BatchStatus.readyToBottle)
                ElevatedButton(onPressed: () {}, child: Text("Bottelen")),
              if (status == BatchStatus.waitingForLagering)
                OutlinedButton(onPressed: () {}, child: Text("Bottelen")),
            ])));
  }

  addSGMeasurement(Function addMeasurement) {
    String sgDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
    double? sgValue;

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
