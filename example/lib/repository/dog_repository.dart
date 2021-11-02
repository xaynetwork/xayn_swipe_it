import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xayn_swipe_it_example/models/dog.dart';

const String _storeKey = 'dogsStoreKey';

class DogRepository {
  const DogRepository();

  Future<bool> addDog(Dog dog) async {
    final prefs = await SharedPreferences.getInstance();
    final dogs = await getSavedDogs(preferences: prefs);
    if (dogs.contains(dog)) return true;
    dogs.add(dog);
    final encodedDogs = _getEncodedDogs(dogs);
    return prefs.setStringList(_storeKey, encodedDogs);
  }

  Future<bool> removeDog(Dog dog) async {
    final prefs = await SharedPreferences.getInstance();
    final dogs = await getSavedDogs(preferences: prefs);
    if (dogs.isEmpty || !dogs.contains(dog)) return false;
    dogs.remove(dog);
    final encodedDogs = _getEncodedDogs(dogs);
    return prefs.setStringList(_storeKey, encodedDogs);
  }

  Future<bool> isDogSaved(Dog dog) async {
    final prefs = await SharedPreferences.getInstance();
    final dogs = await getSavedDogs(preferences: prefs);
    return dogs.contains(dog);
  }

  Future<List<Dog>> getSavedDogs({SharedPreferences? preferences}) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final dogs = prefs.getStringList(_storeKey) ?? [];
    if (dogs.isEmpty) return [];
    return dogs.map(jsonDecode).map((e) => Dog.fromJson(e)).toList();
  }

  List<String> _getEncodedDogs(List<Dog> dogs) =>
      dogs.map((e) => e.toJson()).map(jsonEncode).toList();

  Future<Dog> fetchDog() async {
    final response =
        await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      final url = decodedResponse['message'] as String;
      return Dog(url);
    } else {
      throw Exception('Failed to load');
    }
  }
}
