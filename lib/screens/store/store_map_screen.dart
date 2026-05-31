import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:plant_notebook/controller/store_controller.dart';
import 'package:plant_notebook/data/models/store.dart';
import 'package:plant_notebook/routes/route_constant.dart';

class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  final MapController _mapController = MapController();
  bool _hasMovedToUser = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<StoreController>(context, listen: false);
      controller.fetchStores();
    });
  }

  void _moveToLocation(LatLng position, double zoom) {
    _mapController.move(position, zoom);
  }

  @override
  Widget build(BuildContext context) {
    final storeController = Provider.of<StoreController>(context);
    final userPos = storeController.userPosition;
    final userLatLng = userPos != null ? LatLng(userPos.latitude, userPos.longitude) : null;
    final defaultLatLng = const LatLng(10.762622, 106.660172); // HCMC Center

    // Auto-move map to user location once it is fetched
    if (userLatLng != null && !_hasMovedToUser) {
      _hasMovedToUser = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _moveToLocation(userLatLng, 14.5);
      });
    }

    // Prepare map markers
    final markers = <Marker>[];

    // Add user marker
    if (userLatLng != null) {
      markers.add(
        Marker(
          point: userLatLng,
          width: 55,
          height: 55,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  width: 18,
                  height: 18,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Add store markers
    for (final store in storeController.stores) {
      final isSelected = storeController.selectedStore?.id == store.id;
      final isNursery = store.type == 'nursery';
      final markerColor = isNursery ? primaryColor : Colors.orange.shade800;
      final markerIcon = isNursery ? Icons.spa : Icons.storefront;

      markers.add(
        Marker(
          point: LatLng(store.latitude, store.longitude),
          width: isSelected ? 60 : 48,
          height: isSelected ? 60 : 48,
          child: GestureDetector(
            onTap: () {
              storeController.selectStore(store);
              _moveToLocation(LatLng(store.latitude, store.longitude), 15.0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isSelected ? markerColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : markerColor,
                  width: 3,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Icon(
                markerIcon,
                color: isSelected ? Colors.white : markerColor,
                size: isSelected ? 30 : 22,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: neutral,
      body: Stack(
        children: [
          // 1. Map View
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLatLng ?? defaultLatLng,
              initialZoom: 14.0,
              minZoom: 5.0,
              maxZoom: 18.0,
              onTap: (_, __) {
                // Clear selection if tapping empty map area
                storeController.selectStore(null);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.plant_notebook',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // 2. Custom App Bar / Top Navigation
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Header text box
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: const Text(
                          'Tìm Cửa Hàng & Vườn Ươm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. Filter Chips Row
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: storeController.filterOptions.length,
                    itemBuilder: (context, index) {
                      final option = storeController.filterOptions[index];
                      final isSelected = storeController.selectedFilter == option;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(option),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          disabledColor: Colors.white,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF555555),
                          ),
                          backgroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onSelected: (bool selected) {
                            if (selected) {
                              storeController.selectFilter(option);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 4. Floating Action Buttons (Zoom / Locate User / Refresh)
          Positioned(
            right: 16,
            bottom: storeController.selectedStore != null ? 220 : 32,
            child: Column(
              children: [
                // Zoom In button
                FloatingActionButton(
                  heroTag: 'zoomInBtn',
                  mini: true,
                  onPressed: () {
                    final camera = _mapController.camera;
                    _mapController.move(camera.center, camera.zoom + 1.0);
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  elevation: 4,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                // Zoom Out button
                FloatingActionButton(
                  heroTag: 'zoomOutBtn',
                  mini: true,
                  onPressed: () {
                    final camera = _mapController.camera;
                    _mapController.move(camera.center, camera.zoom - 1.0);
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  elevation: 4,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                // Refresh button
                FloatingActionButton(
                  heroTag: 'refreshBtn',
                  mini: true,
                  onPressed: () {
                    storeController.fetchStores();
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  elevation: 4,
                  child: storeController.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(primaryColor),
                          ),
                        )
                      : const Icon(Icons.refresh),
                ),
                const SizedBox(height: 12),
                // Location button
                FloatingActionButton(
                  heroTag: 'locationBtn',
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await storeController.determinePosition();
                    final pos = storeController.userPosition;
                    if (pos != null) {
                      _moveToLocation(LatLng(pos.latitude, pos.longitude), 15.0);
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Không thể truy cập vị trí. Hãy bật GPS và cấp quyền.'),
                        ),
                      );
                    }
                  },
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),

          // 5. Store Preview sliding drawer
          if (storeController.selectedStore != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _buildStorePreviewCard(context, storeController.selectedStore!, storeController),
            ),
        ],
      ),
    );
  }

  Widget _buildStorePreviewCard(BuildContext context, Store store, StoreController controller) {
    final distance = controller.getDistanceTo(store.latitude, store.longitude);
    final isNursery = store.type == 'nursery';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle & Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge tag type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isNursery ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isNursery ? 'VƯỜN ƯƠM' : 'CỬA HÀNG VẬT TƯ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isNursery ? primaryColor : Colors.orange.shade800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => controller.selectStore(null),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Core info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: store.imageUrl != null
                    ? Image.network(
                        store.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 14),

              // Title & metrics
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B1B1B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          store.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      store.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Close preview card and go to detail screen
                    controller.selectStore(null);
                    Navigator.pushNamed(
                      context,
                      storeDetailRoute,
                      arguments: store.id,
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Xem Chi Tiết'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
