import '../../Globals/index.dart';

class Counting_LocationService {
  final api = GetIt.I<Api>();
  BehaviorSubject<Map<int, bool>> currentList$ = BehaviorSubject.seeded({});
  BehaviorSubject<FixAssetLocation?> selectedLocation$ = BehaviorSubject.seeded(null);
  BehaviorSubject<String> note$ = BehaviorSubject.seeded("");
}
