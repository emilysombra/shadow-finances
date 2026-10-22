import 'package:shadow_finances/utils/clock.dart';

/// [Clock] parado numa data, para testes.
class FixedClock implements Clock {
  FixedClock(this.today);

  DateTime today;

  @override
  DateTime now() => today;
}
