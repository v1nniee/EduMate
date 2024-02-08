import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteTutorsProvider extends ChangeNotifier {
  List<String> _favoriteTutors = [];

  List<String> get favoriteTutors => _favoriteTutors;

  void addFavoriteTutor(String tutorId) {
    if (!_favoriteTutors.contains(tutorId)) {
      _favoriteTutors.add(tutorId);
      _saveFavorites();
      notifyListeners();
    }
  }

  void removeFavoriteTutor(String tutorId) {
    _favoriteTutors.remove(tutorId);
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String tutorId) {
    return _favoriteTutors.contains(tutorId);
  }

  void _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite_tutors', _favoriteTutors);
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteTutors = prefs.getStringList('favorite_tutors') ?? [];
    notifyListeners();
  }
}
