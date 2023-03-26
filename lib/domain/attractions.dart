import 'package:intl/intl.dart';

class Attraction {
  static const ID = 'id';
  static const DESCRIPTION = 'description';
  static const REGISTERED = 'createdDate';

  int id;
  String content;
  String title;
  String registeredDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  Attraction({required this.id, required this.content, required this.title});
}
