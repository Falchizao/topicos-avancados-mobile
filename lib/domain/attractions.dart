import 'package:intl/intl.dart';

class Attraction {
  static const ID = 'id';
  static const DESCRIPTiON = 'description';
  static const REGISTERED = 'createdDate';
  static const DIFERENTIALS = 'differentials';
  static const TITLE = 'title';
  static const ENDED = 'ended';

  int? id;
  String content;
  String differentials;
  String title;
  String registeredDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  bool ended;

  Attraction(
      {this.id,
      required this.content,
      required this.title,
      required this.differentials,
      this.ended = false,
      registeredDate});

  Map<String, dynamic> toMap() => {
        ID: id,
        TITLE: title,
        DESCRIPTiON: content,
        DIFERENTIALS: differentials,
        REGISTERED: registeredDate,
        ENDED: ended ? 1 : 0,
      };

  factory Attraction.fromMap(Map<String, dynamic> map) => Attraction(
        id: map[ID] is int ? map[ID] : null,
        registeredDate: map[REGISTERED] is String ? map[REGISTERED] : '',
        differentials: map[DIFERENTIALS] is String ? map[DIFERENTIALS] : '',
        content: map[DESCRIPTiON] is String ? map[DESCRIPTiON] : '',
        title: map[TITLE] is String ? map[TITLE] : '',
        ended: map[ENDED] == 1,
      );
}
