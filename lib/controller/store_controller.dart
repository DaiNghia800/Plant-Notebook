import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plant_notebook/data/models/store.dart';
import 'package:plant_notebook/data/services/store_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreController extends ChangeNotifier {
  final StoreService _storeService = StoreService();

  List<Store> _stores = [];
  bool _isLoading = false;
  String? _errorMessage;
  Store? _selectedStore;
  Position? _userPosition;
  String _selectedFilter = 'Tất cả';

  // Getters
  List<Store> get stores => _stores;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Store? get selectedStore => _selectedStore;
  Position? get userPosition => _userPosition;
  String get selectedFilter => _selectedFilter;

  // Filter options
  final List<String> filterOptions = const ['Tất cả', 'Vườn ươm', 'Vật tư & Cây cảnh'];

  void selectFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      fetchStores();
    }
  }

  void selectStore(Store? store) {
    _selectedStore = store;
    notifyListeners();
  }

  // Determine current position
  Future<void> determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      _userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  // Fetch all stores
  Future<void> fetchStores() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get location first to calculate distance
      if (_userPosition == null) {
        await determinePosition();
      }

      final fetchedStores = await _storeService.getStores(type: _selectedFilter);
      _stores = fetchedStores;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch store details (with reviews)
  Future<void> fetchStoreDetails(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final detailedStore = await _storeService.getStoreById(id);
      _selectedStore = detailedStore;

      // Update in local stores list if exists
      final idx = _stores.indexWhere((s) => s.id == id);
      if (idx != -1) {
        _stores[idx] = detailedStore;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit review
  Future<bool> addReview({
    required String storeId,
    required int rating,
    required String comment,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');

      await _storeService.createReview(
        storeId: storeId,
        rating: rating,
        comment: comment,
        userId: userId,
      );
      
      // Refresh details to load new review and average rating
      await fetchStoreDetails(storeId);
      // Refresh list to sync average rating
      final fetchedStores = await _storeService.getStores(type: _selectedFilter);
      _stores = fetchedStores;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Helper function to calculate distance
  String getDistanceTo(double storeLat, double storeLng) {
    if (_userPosition == null) return 'N/A';
    
    double distanceInMeters = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      storeLat,
      storeLng,
    );

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toInt()}m';
    } else {
      double kms = distanceInMeters / 1000;
      return '${kms.toStringAsFixed(1)}km';
    }
  }
}
