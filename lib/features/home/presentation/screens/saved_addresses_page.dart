import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class SavedAddressesPage extends StatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  State<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  final user = FirebaseAuth.instance.currentUser;

  LatLng currentLocation = const LatLng(15.3694, 44.1910);
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    setState(() {
      currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );
    });
  }

  void _selectLocation(LatLng point) {
    setState(() {
      selectedLocation = point;
    });
  }

  double _distanceKm(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
          from.latitude,
          from.longitude,
          to.latitude,
          to.longitude,
        ) /
        1000;
  }

  int _price(double distance) {
    const basePrice = 1000;
    const pricePerKm = 300;

    return basePrice + (distance * pricePerKm).round();
  }

  Future<void> _saveAddress() async {
    if (user == null) return;

    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("حدد الموقع من الخريطة أولاً"),
        ),
      );
      return;
    }

    final distance = _distanceKm(
      currentLocation,
      selectedLocation!,
    );

    final price = _price(distance);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('addresses')
        .add({
      'lat': selectedLocation!.latitude,
      'lng': selectedLocation!.longitude,
      'distance': distance,
      'price': price,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم حفظ الموقع"),
      ),
    );
  }

  Future<void> _openNavigation(
    double lat,
    double lng,
  ) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    await launchUrl(
      googleMapsUrl,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _deleteAddress(String id) async {
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('addresses')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.black : const Color(0xFFF7F8FC),

      appBar: AppBar(
        title: const Text("العناوين المحفوظة"),
        backgroundColor: const Color(0xFF1670FF),
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAddress,
        backgroundColor: const Color(0xFF1670FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save),
        label: const Text("حفظ الموقع"),
      ),

      body: Column(
        children: [
          SizedBox(
            height: 320,

            child: FlutterMap(
              options: MapOptions(
                initialCenter: currentLocation,
                initialZoom: 13,

                onTap: (_, point) {
                  _selectLocation(point);
                },
              ),

              children: [
                TileLayer(
                  urlTemplate:
                      'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',

                  userAgentPackageName:
                      'com.noon.carwash_go',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLocation,
                      width: 80,
                      height: 80,

                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 42,
                      ),
                    ),

                    if (selectedLocation != null)
                      Marker(
                        point: selectedLocation!,
                        width: 80,
                        height: 80,

                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          if (selectedLocation != null)
            Padding(
              padding: const EdgeInsets.all(14),

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1C1E)
                      : Colors.white,

                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: Column(
                  children: [
                    Text(
                      "الموقع المحدد",

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "المسافة: ${_distanceKm(currentLocation, selectedLocation!).toStringAsFixed(2)} كم",

                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : Colors.grey,
                      ),
                    ),

                    Text(
                      "السعر التقريبي: ${_price(_distanceKm(currentLocation, selectedLocation!))} ريال",

                      style: const TextStyle(
                        color: Color(0xFF1670FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: user == null
                ? const Center(
                    child:
                        Text("يجب تسجيل الدخول"),
                  )

                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .collection('addresses')
                        .orderBy(
                          'createdAt',
                          descending: true,
                        )
                        .snapshots(),

                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      }

                      final docs =
                          snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return Center(
                          child: Text(
                            "لا توجد عناوين محفوظة",

                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,

                              color: isDark
                                  ? Colors.white70
                                  : const Color(
                                      0xFF151B4A),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding:
                            const EdgeInsets.all(16),

                        itemCount: docs.length,

                        itemBuilder: (_, index) {
                          final doc = docs[index];

                          final data =
                              doc.data()
                                  as Map<String, dynamic>;

                          final lat = data['lat'];
                          final lng = data['lng'];

                          final distance =
                              data['distance'];

                          final price =
                              data['price'];

                          return Container(
                            margin:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),

                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(
                                      0xFF1C1C1E)
                                  : Colors.white,

                              borderRadius:
                                  BorderRadius.circular(
                                      18),
                            ),

                            child: ListTile(
                              leading: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),

                              title: Text(
                                "موقع محفوظ",

                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              subtitle: Text(
                                "المسافة: ${distance.toStringAsFixed(2)} كم - السعر: $price ريال",

                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.grey,
                                ),
                              ),

                              trailing: Row(
                                mainAxisSize:
                                    MainAxisSize.min,

                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.navigation,
                                      color:
                                          Colors.blue,
                                    ),

                                    onPressed: () {
                                      _openNavigation(
                                        lat,
                                        lng,
                                      );
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),

                                    onPressed: () {
                                      _deleteAddress(
                                        doc.id,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}