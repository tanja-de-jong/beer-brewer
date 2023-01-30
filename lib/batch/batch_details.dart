import 'package:flutter/material.dart';

import '../main.dart';
import '../models/batch.dart';
import '../models/product.dart';
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
    super.initState();
  }

  Widget leftColumn() {
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
                  Text(batch.bottleSugar?.products?[0].product
                          .getProductString() ??
                      "-")),
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
            ]));
  }

  Widget rightColumn() {
    return SizedBox(
        width: 350,
        child: Column(children: [
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
                                    // width: 400,
                                    child:
                                        MediaQuery.of(context).size.width >= 700
                                            ? Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  leftColumn(),
                                                  const SizedBox(width: 50),
                                                  rightColumn()
                                                ],
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  leftColumn(),
                                                  const SizedBox(height: 20),
                                                  rightColumn()
                                                ],
                                              ))))
                      ])),
              // const Divider(),
              // const SizedBox(height: 15),
              // ElevatedButton(
              //   onPressed: () {
              //     if (recipe.amount != null && recipe.amount! > 0) {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute<void>(
              //           builder: (BuildContext context) =>
              //               BatchCreator(recipe: recipe),
              //         ),
              //       );
              //     } else {
              //       ScaffoldMessenger.of(context)
              //           .showSnackBar(const SnackBar(
              //           content:
              //           Text("Recept heeft nog geen hoeveelheid.")));
              //     }
              //   },
              //   child: const Text("Brouwplan maken"),
              // ),
            ])));
  }
}
