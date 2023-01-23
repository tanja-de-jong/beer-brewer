import 'package:beer_brewer/data/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseController {
  static FirebaseFirestore db = FirebaseFirestore.instance;

  static Map _getIngredientMap(SpecToProduct ingredient) {
    ProductSpec spec = ingredient.spec;
    Map specMap = {
      "name": spec.name,
      "amount": spec.amount,
    };
    if (spec is MaltSpec) {
      specMap["ebcMin"] = spec.ebcMin;
      specMap["ebcMax"] = spec.ebcMax;
    } else if (spec is HopSpec) {
      specMap["alphaAcid"] = spec.alphaAcid;
    }

    return {
      "spec": specMap,
      "product": ingredient.product.id,
      "amount": ingredient.amount,
      "explanation": ingredient.explanation
    };
  }
  
  static Future<List<Recipe>> getRecipes() async {
    List<Recipe> result = [];
    List docs = (await db.collection("recipes").get()).docs;
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
      Map data = doc.data();
      Recipe recipe = Recipe.create(doc.id, data);
      result.add(recipe);
    }
    return result;
  }

  static Future<Recipe> saveRecipe(
      String? id,
      String name,
      String style,
      String? source,
      double amount,
      double? expStartSG,
      double? expFinalSG,
      double? efficiency,
      double? color,
      double? bitter,
      double mashWater,
      double rinsingWater,
      List<MaltSpec> malts,
      List<MashStep> mashSchedule,
      Map<double?, List<HopSpec>> hops,
      String? yeastName,
      double? yeastAmount,
      String? cookingSugarName,
      double? cookingSugarAmount,
      double? cookingSugarTime,
      String? bottleSugarName,
      double? bottleSugarAmount,
      Map<double?, List<ProductSpec>> otherIngredients,
      double? yeastTempMin,
      double? yeastTempMax,
      String? remarks) async {

    Cooking cooking = Cooking(hops.keys.map((time) => CookingStep(time, hops[time]!)).toList());
    if (cookingSugarName != null) cooking.addStep(cookingSugarTime, [CookingSugarSpec(cookingSugarName, cookingSugarAmount)]);
    for (double? time in otherIngredients.keys) {
      cooking.addStep(time, otherIngredients[time]!);
    }

    Map<String, dynamic> data = {
      "name": name,
      "style": style,
      "source": source,
      "amount": amount,
      "expStartSG": expStartSG,
      "expFinalSG": expFinalSG,
      "efficiency": efficiency,
      "color": color,
      "bitter": bitter,
      "mashing": {
        "malts": malts.map((malt) => {
          "name": malt.name,
          "amount": malt.amount,
          "ebcMin": malt.ebcMin,
          "ebcMax": malt.ebcMax,
        }).toList(),
        "steps": mashSchedule.map((step) => {
          "temp": step.temp,
          "time": step.time
        }).toList(),
        "water": mashWater
      },
      "rinsingWater": rinsingWater,
      "cooking": {
        "steps": cooking.steps.map((step) => {
            "time": step.time,
            "products": step.products.map((product) => product.toMap()).toList()
          }).toList(),
      },
      "yeast": {
        "name": yeastName,
        "amount": yeastAmount,
      },
      "yeastTempMin": yeastTempMin,
      "yeastTempMax": yeastTempMax,
      "bottleSugar": {
        "name": bottleSugarName,
        "amount": bottleSugarAmount,
      },
      "remarks": remarks
    };

    if (id == null) {
      id = (await db.collection("recipes").add(data)).id;
    } else {
      await db.collection("recipes").doc(id).set(data);
    }
    return Recipe.create(id, data);
  }

  static Future<void> removeRecipe(Recipe recipe) async {
    await db.collection("recipes").doc(recipe.id).delete();
  }

  // Create empty batch
  static void addBatch(
      Recipe recipe, double amount, List<SpecToProduct> ingredients) {
    db.collection("batches").add({
      "recipe": {"id": recipe.id, "name": recipe.name, "style": recipe.style},
      "amount": amount,
      "ingredients": ingredients.map((i) => _getIngredientMap(i))
    });
  }
}
