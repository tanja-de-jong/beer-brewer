import 'dart:convert';

import 'package:beer_brewer/data/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseController {
  static FirebaseFirestore db = FirebaseFirestore.instance;

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
    Cooking cooking = Cooking(
        hops.keys.map((time) => CookingStep(time, hops[time]!)).toList());
    if (cookingSugarName != null)
      cooking.addStep(cookingSugarTime,
          [CookingSugarSpec(cookingSugarName, cookingSugarAmount)]);
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
        "malts": malts
            .map((malt) => {
                  "name": malt.name,
                  "amount": malt.amount,
                  "ebcMin": malt.ebcMin,
                  "ebcMax": malt.ebcMax,
                })
            .toList(),
        "steps": mashSchedule
            .map((step) => {"temp": step.temp, "time": step.time})
            .toList(),
        "water": mashWater
      },
      "rinsingWater": rinsingWater,
      "cooking": {
        "steps": cooking.steps
            .map((step) => {
                  "time": step.time,
                  "products":
                      step.products.map((product) => product.toMap()).toList()
                })
            .toList(),
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

  static Future<List<Batch>> getBatches() async {
    List<Batch> result = [];
    List docs = (await db.collection("batches").get()).docs;
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
      Map data = doc.data();
      Batch batch = Batch.create(doc.id, data);
      result.add(batch);
    }
    return result;
  }

  static Future<Batch> saveBatch(String? id,
      Recipe recipe, Map<ProductSpec, List<SpecToProduct>> ingredients) async {
    Map<String, dynamic> data = {
      "name": recipe.name, // TODO
      "recipe": {"id": recipe.id, "name": recipe.name, "style": recipe.style},
      "amount": recipe.amount, // TODO
      "ingredients": ingredients.keys.map((ProductSpec spec) => {
        "spec": spec.toMap(),
        "products": ingredients[spec]!.map((mapping) => {
          mapping.toMap()
        })
      }).toList()
    };

    if (id == null) {
      id = (await db.collection("batches").add(data)).id;
    } else {
      await db.collection("batches").doc(id).set(data);
    }
    return Batch.create(id, data);
  }

  static Future<Batch> brewBatch(Batch batch, double startSG) async {
    DateTime brewDate = DateTime.now();

    await db.collection("batches").doc(batch.id).update({
      "brewDate": brewDate,
      "sgMeasurements": [{
        "date": brewDate,
        "SG": startSG
      }]
    });

    batch.brewDate = brewDate;
    batch.sgMeasurements = {
      brewDate: startSG
    };
    return batch;
  }

  static Future<List<Product>> getProducts() async {
    List<Product> result = [];
    List docs = (await db.collection("products").get()).docs;
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
      Map data = doc.data();
      Product product = Product.create(doc.id, data);
      result.add(product);
    }
    return result;
  }

  static Future<Product> saveProduct(String? id, ProductCategory category, String name, String? brand, Map<String, Map<String, dynamic>>? stores, double? amount, Map? extraProps) async {
    Map<String, dynamic> data = {
      "category": describeEnum(category),
      "name": name,
      "brand": brand,
      "stores": stores,
      "amount": amount,
      ...?extraProps
    };

    if (id == null) {
      id = (await db.collection("products").add(data)).id;
    } else {
      await db.collection("products").doc(id).set(data);
    }
    return Product.create(id, data);
  }
}
