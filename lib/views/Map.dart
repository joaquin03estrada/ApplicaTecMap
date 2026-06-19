import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Map extends StatefulWidget {
  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final bounds = LatLngBounds(
    const LatLng(24.789900,-107.394550,), 
    const LatLng(24.784875, -107.401350), 
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            (bounds.north + bounds.south) / 2,
            (bounds.west + bounds.east) / 2,
          ),
          initialZoom: 17.5,
          minZoom: 16.0,
          maxZoom: 18.0,
          cameraConstraint: CameraConstraint.contain(
              bounds: bounds,
          ),
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          OverlayImageLayer(
            overlayImages: [
              OverlayImage(
                bounds: bounds,
                imageProvider: const AssetImage(
                  'lib/assets/images/Mapa_Tec.png',
                ),
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(24.788953330937495, -107.39803337375095),
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
