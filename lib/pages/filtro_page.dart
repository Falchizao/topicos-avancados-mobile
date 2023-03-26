import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/attractions.dart';

class FiltroPage extends StatefulWidget {
  static const routeName = '/filtro';
  static const chaveCampoOrdenacao = 'campoOrdenacao';
  static const chaveUsarOrdemDecrescente = 'usarOrdemDecrescente';
  static const keyFilterContent = 'contentFilter';
  static const keyFilterDate = 'dateFilter';

  @override
  _FiltroPageState createState() => _FiltroPageState();
}

class _FiltroPageState extends State<FiltroPage> {
  final _camposParaOrdenacao = {
    Attraction.ID: 'ID',
    Attraction.DESCRIPTION: 'Content',
    Attraction.REGISTERED: 'Registered_day'
  };

  late final SharedPreferences _prefs;
  final _contentController = TextEditingController();
  String _campoOrdenacao = Attraction.ID;
  bool _usarOrdemDecrescente = false;
  bool _alterouValores = false;

  @override
  void initState() {
    super.initState();
    _carregarSharedPreferences();
  }

  void _carregarSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _campoOrdenacao =
          _prefs.getString(FiltroPage.chaveCampoOrdenacao) ?? Attraction.ID;
      _usarOrdemDecrescente =
          _prefs.getBool(FiltroPage.chaveUsarOrdemDecrescente) == true;
      _contentController.text =
          _prefs.getString(FiltroPage.keyFilterContent) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onVoltarClick,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Filter'),
        ),
        body: _criarBody(),
      ),
    );
  }

  Widget _criarBody() => ListView(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, top: 10),
            child: Text('Campo para ordenação'),
          ),
          for (final campo in _camposParaOrdenacao.keys)
            Row(
              children: [
                Radio(
                  value: campo,
                  groupValue: _campoOrdenacao,
                  onChanged: _onCampoOrdenacaoChanged,
                ),
                Text(_camposParaOrdenacao[campo]!),
              ],
            ),
          const Divider(),
          Row(
            children: [
              Checkbox(
                value: _usarOrdemDecrescente,
                onChanged: _onUsarOrdemDecrescenteChanged,
              ),
              const Text('Usar ordem decrescente'),
            ],
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Content starts with',
              ),
              controller: _contentController,
              onChanged: _onFiltroDescricaoChanged,
            ),
          ),
        ],
      );

  void _onCampoOrdenacaoChanged(String? valor) {
    _prefs.setString(FiltroPage.chaveCampoOrdenacao, valor!);
    _alterouValores = true;
    setState(() {
      _campoOrdenacao = valor;
    });
  }

  void _onUsarOrdemDecrescenteChanged(bool? valor) {
    _prefs.setBool(FiltroPage.chaveUsarOrdemDecrescente, valor!);
    _alterouValores = true;
    setState(() {
      _usarOrdemDecrescente = valor;
    });
  }

  void _onFiltroDescricaoChanged(String? valor) {
    _prefs.setString(FiltroPage.keyFilterContent, valor ?? '');
    _alterouValores = true;
  }

  Future<bool> _onVoltarClick() async {
    var att = [
      _alterouValores,
      _contentController.text,
      _usarOrdemDecrescente,
    ];
    Navigator.of(context).pop(att);
    return true;
  }
}
