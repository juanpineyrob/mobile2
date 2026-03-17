import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// =============================================================================
// AULA ENTRADA E PERMISSÕES — VIEW MODEL (MVVM) — VERSÃO RESOLVIDA
// =============================================================================

class AulaEntradaPermissoesViewModel extends ChangeNotifier {
  AulaEntradaPermissoesViewModel() {
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _telefoneController = TextEditingController();
  }

  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefoneController;

  TextEditingController get nomeController => _nomeController;
  TextEditingController get emailController => _emailController;
  TextEditingController get telefoneController => _telefoneController;

  String _cameraStatus = 'Não verificado';
  String _locationStatus = 'Não verificado';
  bool _locationLoading = false;
  bool _cameraLoading = false;

  String get cameraStatus => _cameraStatus;
  String get locationStatus => _locationStatus;
  bool get locationLoading => _locationLoading;
  bool get cameraLoading => _cameraLoading;

  Future<void> requestCamera() async {
    _cameraLoading = true;
    notifyListeners();

    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      _cameraStatus = 'Concedido';
    } else if (status.isDenied) {
      _cameraStatus = 'Negado';
    } else if (status.isPermanentlyDenied) {
      _cameraStatus = 'Negado permanentemente';
    } else {
      _cameraStatus = 'Status: $status';
    }

    _cameraLoading = false;
    notifyListeners();
  }

  Future<void> requestLocation() async {
    _locationLoading = true;
    notifyListeners();

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationStatus = 'Serviço de localização desativado';
      _locationLoading = false;
      notifyListeners();
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _locationStatus = 'Permissão negada';
      _locationLoading = false;
      notifyListeners();
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    _locationStatus =
        'Lat: ${position.latitude.toStringAsFixed(4)}, '
        'Lng: ${position.longitude.toStringAsFixed(4)}';

    _locationLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }
}
