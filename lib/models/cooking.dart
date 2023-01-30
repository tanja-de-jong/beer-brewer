import 'SpecToProducts.dart';

class Cooking {
  List<CookingScheduleStep> steps;

  Cooking(this.steps);

  Set getCookingIngredients() {
    return steps.expand((step) => step.products).toSet();
  }

  void addStep(double? time, List<SpecToProducts> products) {
    Iterable<CookingScheduleStep> matchingSteps =
    steps.where((step) => step.time == time);
    if (matchingSteps.isEmpty) {
      steps.add(CookingScheduleStep(time, products));
    } else {
      matchingSteps.first.products.addAll(products);
    }
  }

  static Cooking create(List data) {
    return Cooking(data
        .map((step) => CookingScheduleStep(
        step["time"],
        (step["products"] as List)
            .map((e) => SpecToProducts.create(e))
            .toList()))
        .toList());
  }

  List<Map<String, dynamic>> toMap() {
    return steps.map((e) => e.toMap()).toList();
  }
}

class CookingScheduleStep {
  List<SpecToProducts> products = [];
  double? time;

  CookingScheduleStep(this.time, List<SpecToProducts> products) {
    this.products.addAll(products);
  }

  Map<String, dynamic> toMap() {
    return {"time": time, "products": products.map((e) => e.toMap()).toList()};
  }
}