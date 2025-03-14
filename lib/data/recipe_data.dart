import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RecipeHelper {
  static final RecipeHelper _instance = RecipeHelper._internal();
  factory RecipeHelper() => _instance;
  RecipeHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'recipes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE recipes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        );
      ''');
        await db.execute('''
        CREATE TABLE nutrients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          recipe_id INTEGER,
          type TEXT CHECK(type IN ('macro', 'micro')),
          name TEXT NOT NULL,
          value REAL,
          FOREIGN KEY(recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
        );
      ''');
        await _insertInitialData(db);
      },
    );
  }

  Future<void> _insertInitialData(Database db) async {
    Map<String, dynamic> initialData = {
      "recipes": {
        "VEGETATIF": {
          "nutrients": {
            "macro": {"N": 120, "P": 26, "K": 50, "Mg": 30, "Ca": 135, "S": 56},
            "micro": {
              "Fe": 5,
              "Mn": 1,
              "Zn": 2,
              "B": 0.1,
              "Cu": 0.5,
              "Mo": 0.025
            }
          }
        },
        "GENERATIF": {
          "nutrients": {
            "macro": {
              "N": 150,
              "P": 52,
              "K": 280,
              "Mg": 52,
              "Ca": 122,
              "S": 100
            },
            "micro": {
              "Fe": 3,
              "Mn": 1,
              "Zn": 1,
              "B": 0.2,
              "Cu": 0.5,
              "Mo": 0.05
            }
          }
        },
        "Chilli (maximumyield)": {
          "nutrients": {
            "macro": {
              "N": 320,
              "P": 103,
              "K": 364,
              "Mg": 96,
              "Ca": 330,
              "S": 174
            },
            "micro": {
              "Fe": 4.9,
              "Mn": 1.97,
              "Zn": 0.25,
              "B": 0.7,
              "Cu": 0.07,
              "Mo": 0.05
            }
          }
        },
        "Cucumber (Howard Resh)": {
          "nutrients": {
            "macro": {
              "N": 140,
              "P": 50,
              "K": 350,
              "Mg": 50,
              "Ca": 200,
              "S": 150
            },
            "micro": {
              "Fe": 3,
              "Mn": 0.8,
              "Zn": 0.1,
              "B": 0.3,
              "Cu": 0.07,
              "Mo": 0.03
            }
          }
        },
        "Generic Bloom (maximumyield)": {
          "nutrients": {
            "macro": {
              "N": 130,
              "P": 60,
              "K": 300,
              "Mg": 30,
              "Ca": 100,
              "S": 60
            },
            "micro": {
              "Fe": 2,
              "Mn": 0.5,
              "Zn": 0.1,
              "B": 0.5,
              "Cu": 0.05,
              "Mo": 0.05
            }
          }
        },
        "Generic Dry Season (Howard Resh)": {
          "nutrients": {
            "macro": {
              "N": 230,
              "P": 60,
              "K": 200,
              "Mg": 36,
              "Ca": 250,
              "S": 129
            },
            "micro": {
              "Fe": 5,
              "Mn": 0.5,
              "Zn": 0.05,
              "B": 0.5,
              "Cu": 0.03,
              "Mo": 0.02
            }
          }
        },
        "Generic for Berries (Growing Edge)": {
          "nutrients": {
            "macro": {
              "N": 207,
              "P": 55,
              "K": 289,
              "Mg": 38,
              "Ca": 155,
              "S": 51
            },
            "micro": {
              "Fe": 6.8,
              "Mn": 1.97,
              "Zn": 0.25,
              "B": 0.7,
              "Cu": 0.07,
              "Mo": 0.05
            }
          }
        },
        "Generic Grow (maximumyield)": {
          "nutrients": {
            "macro": {
              "N": 160,
              "P": 30,
              "K": 230,
              "Mg": 30,
              "Ca": 100,
              "S": 60
            },
            "micro": {
              "Fe": 2,
              "Mn": 0.5,
              "Zn": 0.1,
              "B": 0.5,
              "Cu": 0.05,
              "Mo": 0.05
            }
          }
        },
        "Generic Wet Season (Howard Resh)": {
          "nutrients": {
            "macro": {
              "N": 147,
              "P": 50,
              "K": 150,
              "Mg": 50,
              "Ca": 150,
              "S": 50
            },
            "micro": {
              "Fe": 5,
              "Mn": 0.55,
              "Zn": 0.05,
              "B": 0.5,
              "Cu": 0.03,
              "Mo": 0.02
            }
          }
        },
        "Hoagland solution": {
          "nutrients": {
            "macro": {
              "N": 210,
              "P": 31,
              "K": 235,
              "Mg": 49,
              "Ca": 200,
              "S": 64
            },
            "micro": {
              "Fe": 2.9,
              "Mn": 0.5,
              "Zn": 0.05,
              "B": 0.5,
              "Cu": 0.02,
              "Mo": 0.05
            }
          }
        },
        "Lettuce General (Howard Resh)": {
          "nutrients": {
            "macro": {
              "N": 180,
              "P": 50,
              "K": 210,
              "Mg": 45,
              "Ca": 190,
              "S": 65
            },
            "micro": {
              "Fe": 4,
              "Mn": 0.5,
              "Zn": 0.1,
              "B": 0.5,
              "Cu": 0.1,
              "Mo": 0.05
            }
          }
        },
        "Tropical Lettuce (Douglas Peckenpaugh)": {
          "nutrients": {
            "macro": {"N": 190, "P": 25, "K": 98, "Mg": 25, "Ca": 216, "S": 33},
            "micro": {
              "Fe": 4.9,
              "Mn": 1.97,
              "Zn": 0.25,
              "B": 0.7,
              "Cu": 0.07,
              "Mo": 0.05
            }
          }
        },
        "Pepper (Howard Resh)": {
          "nutrients": {
            "macro": {
              "N": 208,
              "P": 40,
              "K": 340,
              "Mg": 85,
              "Ca": 175,
              "S": 113
            },
            "micro": {
              "Fe": 6.8,
              "Mn": 1.97,
              "Zn": 0.25,
              "B": 0.7,
              "Cu": 0.07,
              "Mo": 0.05
            }
          }
        },
        "Melons (Douglas Peckenpaugh)": {
          "nutrients": {
            "macro": {
              "N": 215,
              "P": 86,
              "K": 343,
              "Mg": 85,
              "Ca": 175,
              "S": 113
            },
            "micro": {
              "Fe": 6.8,
              "Mn": 1.97,
              "Zn": 0.25,
              "B": 0.7,
              "Cu": 0.07,
              "Mo": 0.05
            }
          }
        },
        "Rice (Douglas Peckenpaugh)": {
          "nutrients": {
            "macro": {"N": 249, "P": 58, "K": 80, "Mg": 65, "Ca": 317, "S": 87},
            "micro": {
              "Fe": 5,
              "Mn": 0.8,
              "Zn": 0.4,
              "B": 0.7,
              "Cu": 0.07,
              "Mo": 0.05
            }
          }
        },
        "Strawberry Drip Irrigation (schundler.com)": {
          "nutrients": {
            "macro": {
              "N": 80,
              "P": 45,
              "K": 200,
              "Mg": 50,
              "Ca": 180,
              "S": 100
            },
            "micro": {
              "Fe": 3,
              "Mn": 0.5,
              "Zn": 0.5,
              "B": 0.5,
              "Cu": 0.05,
              "Mo": 0.05
            }
          }
        },
        "Strawberry Fruiting (growing edge)": {
          "nutrients": {
            "macro": {
              "N": 58,
              "P": 128,
              "K": 211,
              "Mg": 40,
              "Ca": 104,
              "S": 54
            },
            "micro": {
              "Fe": 5,
              "Mn": 2,
              "Zn": 0.25,
              "B": 0.7,
              "Cu": 0.07,
              "Mo": 0.05
            }
          }
        },
        "Tomato (Howard Resh)": {
          "nutrients": {
            "macro": {
              "N": 140,
              "P": 50,
              "K": 352,
              "Mg": 50,
              "Ca": 180,
              "S": 168
            },
            "micro": {
              "Fe": 5,
              "Mn": 0.8,
              "Zn": 0.1,
              "B": 0.3,
              "Cu": 0.07,
              "Mo": 0.03
            }
          }
        },
        "Tomato Stage.1 - 10-14 days (Howard Resh)": {
          "nutrients": {
            "macro": {
              "N": 100,
              "P": 40,
              "K": 200,
              "Mg": 20,
              "Ca": 100,
              "S": 53
            },
            "micro": {
              "Fe": 3,
              "Mn": 0.8,
              "Zn": 0.1,
              "B": 0.3,
              "Cu": 0.07,
              "Mo": 0.03
            }
          }
        },
        "Tomato Stage.2 - first cluster (Howard Resh)": {
          "nutrients": {
            "macro": {
              "N": 130,
              "P": 55,
              "K": 300,
              "Mg": 33,
              "Ca": 150,
              "S": 109
            },
            "micro": {
              "Fe": 3,
              "Mn": 0.8,
              "Zn": 0.1,
              "B": 0.3,
              "Cu": 0.07,
              "Mo": 0.03
            }
          }
        },
        "Tomato Stage.3 - to plant maturity (Howard Resh)": {
          "nutrients": {
            "macro": {
              "N": 180,
              "P": 65,
              "K": 400,
              "Mg": 45,
              "Ca": 400,
              "S": 144
            },
            "micro": {
              "Fe": 3,
              "Mn": 0.8,
              "Zn": 0.1,
              "B": 0.3,
              "Cu": 0.07,
              "Mo": 0.03
            }
          }
        }
      }
    };

    for (var recipe in initialData['recipes'].entries) {
      int recipeId = await db.insert('recipes', {'name': recipe.key});
      // Debugging line

      // Insert macro and micro nutrients
      for (var type in ['macro', 'micro']) {
        var nutrients = recipe.value['nutrients'][type];
        if (nutrients != null) {
          for (var nutrient in nutrients.entries) {
            await db.insert('nutrients', {
              'recipe_id': recipeId,
              'type': type,
              'name': nutrient.key,
              'value': nutrient.value,
            });
          }
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('recipes');
    // Debugging line
    return result;
  }

  Future<List<Map<String, dynamic>>> getNutrients(int recipeId) async {
    final db = await database;
    return await db
        .query('nutrients', where: 'recipe_id = ?', whereArgs: [recipeId]);
  }
}
