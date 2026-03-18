import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// =============================================================================
// AULA 1.5 — MAPAS E GEOLOCALIZAÇÃO — VIEW MODEL (MVVM) — VERSÃO EXERCÍCIO
// =============================================================================
// O ViewModel guarda a posição atual (lat/lng) e o estado de carregamento/erro.
// A lógica de obter a localização do usuário fica aqui; na View só exibimos o
// mapa e reagimos ao estado. No Flutter Web o navegador pede permissão de
// localização (igual à aula de permissões).
// =============================================================================

class AulaMapasGeolocalizacaoViewModel extends ChangeNotifier {
  /// Centro inicial do mapa (ex.: Brasil) até o usuário clicar em "Minha localização".
  static const LatLng centroInicialPadrao = LatLng(-23.5505, -46.6333);

  LatLng? _posicaoAtual;
  bool _loading = false;
  String? _mensagemErro;

  List<LatLng> _pontosRota = [];
  bool _rotaLoading = false;
  String? _rotaErro;

  LatLng? get posicaoAtual => _posicaoAtual;
  bool get loading => _loading;
  String? get mensagemErro => _mensagemErro;
  List<LatLng> get pontosRota => _pontosRota;
  bool get rotaLoading => _rotaLoading;
  String? get rotaErro => _rotaErro;

  /// Chamado quando o usuário toca em "Minha localização".
  /// Deve obter a posição via Geolocator, atualizar _posicaoAtual (ou _mensagemErro)
  /// e chamar notifyListeners().
  Future<void> obterMinhaLocalizacao() async {
    _loading = true;
    _mensagemErro = null;
    notifyListeners();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de localización están desactivados.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permisos de ubicación denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Los permisos de ubicación están denegados permanentemente; no podemos solicitarlos.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      _posicaoAtual = LatLng(position.latitude, position.longitude);
    } catch (e) {
      _mensagemErro = 'Error al obtener localización: $e';
      _posicaoAtual = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Chamado quando o usuário define origem/destino e toca em "Rota até".
  /// Deve chamar a API OSRM (GET com os dois pontos), parsear a resposta,
  /// preencher _pontosRota com a lista de LatLng da geometria e chamar notifyListeners().
  Future<void> buscarRota(LatLng origem, LatLng destino) async {
    _rotaLoading = true;
    _rotaErro = null;
    _pontosRota = [];
    notifyListeners();

    // TODO: implementar obtenção da rota via OSRM.
    // Dicas:
    // 1. Montar a URL: https://router.project-osrm.org/route/v1/driving/
    //    {lngOrigem},{latOrigem};{lngDestino},{latDestino}?overview=full&geometries=geojson
    //    (OSRM usa longitude,latitude na URL).
    // 2. Fazer GET com o pacote http (import 'package:http/http.dart' as http).
    // 3. Parsear o JSON: response.body → jsonDecode → routes[0].geometry.coordinates.
    //    Cada item é [longitude, latitude]; converter para LatLng(lat, lng).
    // 4. Atribuir a lista a _pontosRota. Em erro (status != 200 ou exceção), setar _rotaErro.
    // 5. _rotaLoading = false e notifyListeners().

    print(origem.latitude);
    print(origem.longitude);

    final uri = Uri.parse(
      "https://router.project-osrm.org/route/v1/driving/$origem.longitude,$origem.latitude;$destino.longitude,$destino.latitude?overview=full&geometries=geojson",
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      final List coordinates =
          jsonResponse['routes'][0]['geometry']['coordinates'];

      _pontosRota = coordinates.map((coord) {
        return LatLng(coord[1], coord[0]);
      }).toList();

      _rotaLoading = false;
      notifyListeners();
    } else {
      _rotaErro = uri.toString();
      throw Exception('Error al buscar ruta.');
    }
  }
}
