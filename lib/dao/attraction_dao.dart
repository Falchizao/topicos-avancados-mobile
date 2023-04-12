import 'dart:convert';

import '../database/database_provider.dart';
import '../domain/attractions.dart';

class AttractionDao {
  final dbProvider = DatabaseProvider.instance;

  Future<bool> salvar(Attraction attraction) async {
    final database = await dbProvider.database;
    final valores = attraction.toMap();
    if (attraction.id == null || attraction.id == 0) {
      try {
        attraction.id = await database.insert('attraction', valores);
      } catch (e) {
        print(e);
      }

      return true;
    } else {
      final registrosAtualizados = await database.update(
        'attraction',
        valores,
        where: '${Attraction.ID} = ?',
        whereArgs: [attraction.id],
      );
      return registrosAtualizados > 0;
    }
  }

  Future<bool> remover(int id) async {
    final database = await dbProvider.database;
    final registrosAtualizados = await database.delete(
      'attraction',
      where: '${Attraction.ID} = ?',
      whereArgs: [id],
    );
    return registrosAtualizados > 0;
  }

  Future<List<Attraction>> listar(
      {String filtrotitle = '',
      String filtrocontent = '',
      String campoOrdenacao = Attraction.ID,
      bool usarOrdemDecrescente = false}) async {
    String? where;
    if (filtrocontent.isNotEmpty && filtrocontent != "") {
      where =
          "UPPER(${Attraction.DESCRIPTiON}) LIKE '${filtrocontent.toUpperCase()}%'";
    } else if (filtrotitle.isNotEmpty && filtrotitle != "") {
      where = "UPPER(${Attraction.TITLE}) LIKE '${filtrotitle.toUpperCase()}%'";
    }

    var orderBy = campoOrdenacao;

    if (usarOrdemDecrescente) {
      orderBy += ' DESC';
    }
    final database = await dbProvider.database;
    final resultado = await database.query(
      'attraction',
      columns: [
        Attraction.ID,
        Attraction.DESCRIPTiON,
        Attraction.REGISTERED,
        Attraction.TITLE,
        Attraction.ENDED,
        Attraction.DIFERENTIALS
      ],
      where: where,
      orderBy: orderBy,
    );
    return resultado.map((m) => Attraction.fromMap(m)).toList();
  }
}
