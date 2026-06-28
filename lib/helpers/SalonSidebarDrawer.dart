import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class SalonSidebarDrawer extends StatefulWidget {
  final Map<String, LatLng> salonesUbicaciones;
  final Function(String) onSalonSelected;

  const SalonSidebarDrawer({
    Key? key,
    required this.salonesUbicaciones,
    required this.onSalonSelected,
  }) : super(key: key);

  @override
  State<SalonSidebarDrawer> createState() => _SalonSidebarDrawerState();
}

class _SalonSidebarDrawerState extends State<SalonSidebarDrawer> {
  Map<String, List<String>> _salonesAgrupados = {};
  Set<String> _edificiosExpandidos = {};
  String _busqueda = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _agruparSalonesPorEdificio();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _agruparSalonesPorEdificio() {
    _salonesAgrupados.clear();

    for (var salon in widget.salonesUbicaciones.keys) {
      String prefijo = '';
      
      if (salon.length >= 2) {
        prefijo = salon.substring(0, 2);
      } else {
        prefijo = salon[0];
      }

      String nombreEdificio = _obtenerNombreEdificio(prefijo);

      if (!_salonesAgrupados.containsKey(nombreEdificio)) {
        _salonesAgrupados[nombreEdificio] = [];
      }
      _salonesAgrupados[nombreEdificio]!.add(salon);
    }

    for (var salones in _salonesAgrupados.values) {
      salones.sort();
    }
  }

  String _obtenerNombreEdificio(String prefijo) {
    switch (prefijo) {
      case 'EA':
        return 'Edificio A';
      case 'EB':
        return 'Edificio B';
      case 'EC':
        return 'Edificio C';
      case 'ED':
        return 'Edificio D';
      case 'EE':
        return 'Edificio E';
      case 'EF':
        return 'Edificio F';
      case 'CC':
        return 'Centro de Cómputo';
      case 'LA':
        return 'Laboratorios';
      case 'BI':
        return 'Biblioteca';
      default:
        return 'Otros ($prefijo)';
    }
  }

  List<String> _getSalonesFiltrados() {
    if (_busqueda.isEmpty) {
      return [];
    }

    return widget.salonesUbicaciones.keys
        .where((salon) => salon.toLowerCase().contains(_busqueda.toLowerCase()))
        .toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    final edificiosOrdenados = _salonesAgrupados.keys.toList()..sort();
    final salonesFiltrados = _getSalonesFiltrados();

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_city,
                  color: Color(0xff1b3a6b),
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'Salones y Edificios',
                  style: TextStyle(
                    color: Color(0xff1b3a6b),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar salón...',
                prefixIcon: Icon(Icons.search, color: Color(0xff1b3a6b)),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _busqueda = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xff1b3a6b), width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _busqueda = value;
                });
              },
            ),
          ),
          Expanded(
            child: _busqueda.isNotEmpty
                ? _buildResultadosBusqueda(salonesFiltrados)
                : _buildListaEdificios(edificiosOrdenados),
          ),
        ],
      ),
    );
  }

  Widget _buildResultadosBusqueda(List<String> salonesFiltrados) {
    if (salonesFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No se encontraron salones',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: salonesFiltrados.length,
      itemBuilder: (context, index) {
        final salon = salonesFiltrados[index];
        return ListTile(
          leading: Icon(Icons.location_on, color: Colors.red[700]),
          title: Text(
            salon,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          onTap: () {
            widget.onSalonSelected(salon);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildListaEdificios(List<String> edificiosOrdenados) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: edificiosOrdenados.length,
      itemBuilder: (context, index) {
        final edificio = edificiosOrdenados[index];
        final salones = _salonesAgrupados[edificio]!;
        final estaExpandido = _edificiosExpandidos.contains(edificio);

        return Column(
          children: [
            ListTile(
              leading: Icon(
                _getIconoEdificio(edificio),
                color: Color(0xff1b3a6b),
              ),
              title: Text(
                edificio,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '${salones.length} salones',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: Icon(
                estaExpandido ? Icons.expand_less : Icons.expand_more,
                color: Color(0xff1b3a6b),
              ),
              onTap: () {
                setState(() {
                  if (estaExpandido) {
                    _edificiosExpandidos.remove(edificio);
                  } else {
                    _edificiosExpandidos.add(edificio);
                  }
                });
              },
            ),
            if (estaExpandido)
              Material(
                color: Colors.grey[100],
                child: Column(
                  children: salones.map((salon) {
                    return ListTile(
                      contentPadding: EdgeInsets.only(left: 72, right: 16),
                      dense: true,
                      title: Text(
                        salon,
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: Icon(
                        Icons.location_on,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      onTap: () {
                        widget.onSalonSelected(salon);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            Divider(height: 1),
          ],
        );
      },
    );
  }

  IconData _getIconoEdificio(String nombreEdificio) {
    if (nombreEdificio.contains('Edificio')) {
      return Icons.business;
    } else if (nombreEdificio.contains('Centro de Cómputo')) {
      return Icons.computer;
    } else if (nombreEdificio.contains('Laboratorio')) {
      return Icons.science;
    } else if (nombreEdificio.contains('Auditorio')) {
      return Icons.theater_comedy;
    } else if (nombreEdificio.contains('Biblioteca')) {
      return Icons.menu_book;
    } else if (nombreEdificio.contains('Cafetería')) {
      return Icons.restaurant;
    } else {
      return Icons.place;
    }
  }
}