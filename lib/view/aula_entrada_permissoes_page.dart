import 'package:flutter/material.dart';

import '../viewmodel/aula_entrada_permissoes_view_model.dart';

// =============================================================================
// AULA — GERENCIAMENTO DE ENTRADA E PERMISSÕES DO SO (1.1.2) — VERSÃO RESOLVIDA
// =============================================================================

class AulaEntradaPermissoesPage extends StatefulWidget {
  const AulaEntradaPermissoesPage({super.key});

  @override
  State<AulaEntradaPermissoesPage> createState() =>
      _AulaEntradaPermissoesPageState();
}

class _AulaEntradaPermissoesPageState extends State<AulaEntradaPermissoesPage> {
  final AulaEntradaPermissoesViewModel _viewModel =
      AulaEntradaPermissoesViewModel();
  final _formKey = GlobalKey<FormState>();

  FocusNode? _nomeFocus;
  FocusNode? _emailFocus;
  FocusNode? _telefoneFocus;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _nomeFocus = FocusNode();
    _emailFocus = FocusNode();
    _telefoneFocus = FocusNode();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _nomeFocus?.dispose();
    _emailFocus?.dispose();
    _telefoneFocus?.dispose();
    super.dispose();
  }

  void _onViewModelChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Entrada e permissões'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. Gerenciamento de entrada',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _viewModel.nomeController,
                          focusNode: _nomeFocus,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            border: OutlineInputBorder(),
                            hintText: 'Digite seu nome',
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            _emailFocus?.requestFocus();
                          },
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Informe seu nome';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _viewModel.emailController,
                          focusNode: _emailFocus,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            border: OutlineInputBorder(),
                            hintText: 'email@exemplo.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            _telefoneFocus?.requestFocus();
                          },
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Informe seu e-mail';
                            }
                            if (!v.contains('@')) {
                              return 'E-mail inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _viewModel.telefoneController,
                          focusNode: _telefoneFocus,
                          decoration: const InputDecoration(
                            labelText: 'Telefone',
                            border: OutlineInputBorder(),
                            hintText: '(00) 00000-0000',
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                          },
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Informe seu telefone';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Olá, ${_viewModel.nomeController.text}!',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Enviar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2. Permissões do SO (no web: navegador)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _viewModel.cameraLoading
                                  ? null
                                  : () {
                                      _viewModel.requestCamera();
                                    },
                              icon: _viewModel.cameraLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.camera_alt_outlined),
                              label: const Text('Câmera'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _viewModel.locationLoading
                                  ? null
                                  : () {
                                      _viewModel.requestLocation();
                                    },
                              icon: _viewModel.locationLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.location_on_outlined),
                              label: const Text('Localização'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Câmera: ${_viewModel.cameraStatus}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Localização: ${_viewModel.locationStatus}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
