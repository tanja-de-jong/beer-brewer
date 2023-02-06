import 'package:beer_brewer/data/store.dart';
import 'package:beer_brewer/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../authentication/authentication.dart';
import '../models/batch.dart';
import '../models/product.dart';
import '../models/recipe.dart';

class DatabaseController {
  static DocumentReference<Map<String, dynamic>>? db;
  
  static Future<void> setDB() async {
    String? groupId = await getGroupId(Authentication.email!.toLowerCase());
    if (groupId == null) {
      groupId = FirebaseFirestore.instance.collection("groups").doc().id;
      FirebaseFirestore.instance.collection("users").doc(Authentication.email!.toLowerCase()).set({"groupId": groupId});
    }
    db = FirebaseFirestore.instance.collection("groups").doc(groupId);
  }

  static Future<String?> getGroupId(String email) async {
    String email = Authentication.email!.toLowerCase();
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance.collection("users").doc(email).get();
    Map<String, dynamic>? data = doc.data();
    if (data != null && data.containsKey("groupId")) {
      return data["groupId"];
    } else {
      String newGroupId = FirebaseFirestore.instance.collection("groups").doc().id;
      FirebaseFirestore.instance.collection("users").doc(email).set({"groupId": newGroupId});
      return newGroupId;
    }
  }
  
  static Future<void> migrateData() async {
    var products = (await FirebaseFirestore.instance.collection("products").get()).docs;
    for (var product in products) {
      db!.collection("products").doc(product.id).set(product.data());
    }

    var recipes = (await FirebaseFirestore.instance.collection("recipes").get()).docs;
    for (var product in recipes) {
      db!.collection("recipes").doc(product.id).set(product.data());
    }
  }

  static Future<List<Recipe>> getRecipes() async {
    List<Recipe> result = [];
    List docs = (await db!.collection("recipes").get()).docs;
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
      Recipe recipe = Recipe.create(doc.id, doc.data());
      result.add(recipe);
    }
    return result;
  }

  static Future<String> saveRecipe(Recipe recipe) async {
    String newId = recipe.id == null ? (db!.collection("recipes").doc()).id : recipe.id!;

    db!.collection("recipes").doc(newId).set(recipe.toMap());

    return newId;
  }

  static Future<void> removeRecipe(Recipe recipe) async {
    await db!.collection("recipes").doc(recipe.id).delete();
  }

  static Future<List<Batch>> getBatches() async {
    List<Batch> result = [];
    List docs = (await db!.collection("batches").get()).docs;
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
      Map data = doc.data();
      Batch batch = Batch.create(doc.id, data);
      result.add(batch);
      if (batch.isReadyToDrink() && batch.notifications.isNotEmpty) {
        db!.collection("batches").doc(batch.id).update({
          "notifications": null
        });
        batch.notifications = {};
      }
    }
    return result;
  }

  static Future<String> saveBatch(Batch batch) async {
    String newId = batch.id == null ? (db!.collection("batches").doc()).id : batch.id!;

    await db!.collection("batches").doc(newId).set(batch.toMap());
    return newId;
  }

  static Future<Batch> brewBatch(Batch batch, DateTime? date, num startSG) async {
    DateTime brewDate = date ?? DateTime.now();

    await db!.collection("batches").doc(batch.id).update({
      "brewDate": brewDate,
      "sgMeasurements": [{
        "date": brewDate,
        "SG": startSG
      }],
      "notifications": batch.notifications.keys.map((e) => {
        "type": e.name,
        "id": batch.notifications[e]
      }).toList()
    });

    batch.brewDate = brewDate;
    batch.sgMeasurements = {
      brewDate: startSG
    };
    return batch;
  }

  static Future<Batch> lagerBatch(Batch batch, DateTime? date) async {
    DateTime lagerDate = date ?? DateTime.now();

    await db!.collection("batches").doc(batch.id).update({
      "lagerDate": lagerDate,
      "notifications": batch.notifications.keys.map((e) => {
        "type": e.name,
        "id": batch.notifications[e]
      }).toList()
    });

    batch.lagerDate = lagerDate;
    return batch;
  }

  static Future<Batch> bottleBatch(Batch batch, DateTime? date) async {
    DateTime bottleDate = date ?? DateTime.now();

    await db!.collection("batches").doc(batch.id).update({
      "bottleDate": bottleDate,
      "notifications": batch.notifications.keys.map((e) => {
        "type": e.name,
        "id": batch.notifications[e]
      }).toList()
    });

    batch.bottleDate = bottleDate;
    return batch;
  }

  static Future<Batch> addSGToBatch(Batch batch, DateTime date, num value) async {
    await db!.collection("batches").doc(batch.id).update({"sgMeasurements": FieldValue.arrayUnion([
        {
          "date": date,
          "SG": value
        }])});

    batch.sgMeasurements[date] = value;
    return batch;
  }

  static Future<void> removeBatch(Batch batch) async {
    await db!.collection("batches").doc(batch.id).delete();
  }

  static Future<List<Product>> getProducts() async {
    List<Product> result = [];
    List docs = (await db!.collection("products").get()).docs;
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
      Map data = doc.data();
      Product product = Product.create(doc.id, data);
      result.add(product);
    }
    return result;
  }

  static Future<Product> saveProduct(String? id, ProductCategory category, String name, String? brand, Map<String, Map<String, dynamic>>? stores, num? amount, Map? extraProps) async {
    Map<String, dynamic> data = {
      "category": describeEnum(category),
      "name": name,
      "brand": brand,
      "stores": stores,
      "amount": amount,
      ...?extraProps
    };

    if (id == null) {
      id = (await db!.collection("products").add(data)).id;
    } else {
      await db!.collection("products").doc(id).set(data);
    }
    Product p = Product.create(id!, data);

    return p;
  }

  static Future<Product> updateAmountForProduct(Product product, num amount) async {
    await db!.collection("products").doc(product.id).update({ "amount": amount });
    product.amountInStock = amount;
    return product;
  }

  static Future<void> removeProduct(Product product) async {
    await db!.collection("products").doc(product.id).delete();
  }
}
