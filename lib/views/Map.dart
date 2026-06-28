import 'dart:async';
import 'package:applicatec/helpers/salonsidebardrawer.dart';
import 'package:applicatec/helpers/salonesubicaciones.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class Map extends StatefulWidget {
  final LatLng? markerLocation;
  final String? markerLabel;
  final bool showDrawerBackButton;

  const Map({
    Key? key,
    this.markerLocation,
    this.markerLabel,
    this.showDrawerBackButton = false,
  }) : super(key: key);

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> with AutomaticKeepAliveClientMixin {
  final LatLng _esquinaSW = const LatLng( 24.790267, -107.394443);
  final LatLng _esquinaNE = const LatLng( 24.784439, -107.401502);
  final MapController _mapController = MapController();
  
  late final LatLngBounds _limitesDelMapa;
  bool _mounted = true;
  
  LatLng? _selectedSalonLocation;
  String? _selectedSalonLabel;

  LatLng? _ubicacionActual;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _limitesDelMapa = LatLngBounds(_esquinaSW, _esquinaNE);
    
    _escucharEstadoDelGPS();
    
    if (widget.markerLocation != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_mounted) _hacerZoom(widget.markerLocation!);
      });
    }
  }

  // --- NUEVA LÓGICA DE GPS ---
  void _escucharEstadoDelGPS() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (isEnabled) {
      _configurarRastreo();
    } else {
      _mostrarAlertaGPS();
    }

    _serviceStatusStreamSubscription = Geolocator.getServiceStatusStream().listen((
      ServiceStatus status,
    ) {
      if (status == ServiceStatus.enabled) {
        if (_mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
        _configurarRastreo();
      } else {
        _mostrarAlertaGPS();
        if (_mounted) {
          setState(() {
            _ubicacionActual = null;
          });
        }
      }
    });
  }

  void _mostrarAlertaGPS() {
    if (_mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'El GPS está desactivado. Enciéndelo para ver tu ubicación.',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Ajustes',
            textColor: Colors.white,
            onPressed: () {
              Geolocator.openLocationSettings();
            },
          ),
        ),
      );
    }
  }

  Future<void> _configurarRastreo() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (_mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permiso de ubicación denegado. No se podrá mostrar tu posición.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
    );

    await _positionSubscription?.cancel();

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
            if (position != null && _mounted) {
              setState(() {
                _ubicacionActual = LatLng(position.latitude, position.longitude);
              });
            }
          },
        );
  }
  // --- FIN LÓGICA DE GPS ---

  @override
  void deactivate() {
    _mounted = false;
    super.deactivate();
  }

  @override
  void dispose() {
    _mounted = false;
    _positionSubscription?.cancel();
    _serviceStatusStreamSubscription?.cancel();
    super.dispose();
  }

  void _seleccionarSalon(String salon) {
    if (!_mounted) return;
    
    setState(() {
      _selectedSalonLocation = salonesUbicaciones[salon];
      _selectedSalonLabel = salon;
    });
    
    if (_selectedSalonLocation != null) {
      _hacerZoom(_selectedSalonLocation!);
    }
  }

  void _hacerZoom(LatLng location) {
    if (!_mounted) return;
    try {
      _mapController.move(location, 18.0);
    } catch (e) {
      print("Error al hacer zoom: $e");
    }
  }

  bool _estaDentroDelArea(LatLng ubicacion) {
    return _limitesDelMapa.contains(ubicacion);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); 
    
    final LatLng _centro = LatLng(
      (_esquinaSW.latitude + _esquinaNE.latitude) / 2,
      (_esquinaSW.longitude + _esquinaNE.longitude) / 2,
    );

    return WillPopScope(
      onWillPop: () async {
        _mounted = false;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff1b3a6b),
          foregroundColor: Colors.white,
          elevation: 4,
          leading: widget.showDrawerBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _mounted = false; 
                    Navigator.pop(context);
                  },
                )
              : Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
        ),
        drawer: widget.showDrawerBackButton
            ? null
            : SalonSidebarDrawer(
                salonesUbicaciones: salonesUbicaciones,
                onSalonSelected: _seleccionarSalon,
              ),
        body: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedSalonLocation ?? widget.markerLocation ?? _centro,
            initialZoom: 17.5,
            minZoom: 16.0,
            maxZoom: 19.0, 
            cameraConstraint: CameraConstraint.contain(
              bounds: _limitesDelMapa,
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onTap: (tapPosition, point) {
              print('Coordenada: LatLng(${point.latitude}, ${point.longitude}),');
              if (_selectedSalonLocation != null) {
                setState(() {
                  _selectedSalonLocation = null;
                  _selectedSalonLabel = null;
                });
              }
            },
          ),
          children: [
            OverlayImageLayer(
              overlayImages: [
                OverlayImage(
                  bounds: _limitesDelMapa,
                  imageProvider: const AssetImage('lib/assets/images/Mapa_Tec.png'),
                  opacity: 1.0,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                if (_ubicacionActual != null && _estaDentroDelArea(_ubicacionActual!))
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _ubicacionActual!,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.person_pin_circle,
                      color: Color(0xff1b3a6b),
                      size: 40.0,
                    ),
                  ),
                  
                if (_selectedSalonLocation != null && _estaDentroDelArea(_selectedSalonLocation!))
                  Marker(
                    width: 100.0,
                    height: 80.0,
                    point: _selectedSalonLocation!,
                    alignment: Alignment.topCenter, 
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedSalonLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red[700],
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _selectedSalonLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        Icon(
                          Icons.location_on,
                          color: Colors.red[700],
                          size: 40.0,
                        ),
                      ],
                    ),
                  ),
                  
                if (widget.markerLocation != null && _estaDentroDelArea(widget.markerLocation!))
                  Marker(
                    width: 100.0,
                    height: 80.0,
                    point: widget.markerLocation!,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.markerLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red[700],
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.markerLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        Icon(
                          Icons.location_on,
                          color: Colors.red[700],
                          size: 40.0,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        floatingActionButton: _selectedSalonLocation != null
            ? FloatingActionButton(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red[700],
                child: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedSalonLocation = null;
                    _selectedSalonLabel = null;
                  });
                },
              )
            : null,
      ),
    );
  }
}