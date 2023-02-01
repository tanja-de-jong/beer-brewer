import 'spec_to_products.dart';

class Mashing {
  List<SpecToProducts> malts;
  List<MashStep> steps;
  double? water;

  Mashing(this.malts, this.steps, this.water);

  static Mashing create(Map<String, dynamic> data) {
    List<SpecToProducts> maltsData =
    (data["malts"] as List).map((m) => SpecToProducts.create(m)).toList();
    List<MashStep> mashSchedule = (data["steps"] as List)
        .map((s) => MashStep(s["temp"], s["time"]))
        .toList();
    return Mashing(maltsData, mashSchedule, data["water"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "malts": malts.map((e) => e.toMap()),
      "steps": steps.map((e) => e.toMap()),
      "water": water
    };
  }
}

class MashStep {
  int temp;
  int time;

  MashStep(this.temp, this.time);

  Map<String, dynamic> toMap() {
    return {"temp": temp, "time": time};
  }
}