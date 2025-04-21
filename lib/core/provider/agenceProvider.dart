
import '../../data/models/agenceModel.dart';
import '../../data/repositories/agenceRepositorie.dart';


final agencyRepositoryProvider = Provider<AgencyRepository>((ref) {
  return AgencyRepository();
});

final agenciesProvider = StateNotifierProvider<AgenciesNotifier, List<AgencyModel>>((ref) {
  final repository = ref.watch(agencyRepositoryProvider);
  return AgenciesNotifier(repository);
});

class AgenciesNotifier extends StateNotifier<List<AgencyModel>> {
  final AgencyRepository _repository;

  AgenciesNotifier(this._repository) : super([]);

  Future<void> fetchAgencies() async {
    final agencies = await _repository.getAllAgencies();
    state = agencies;
  }

  Future<void> addAgency(AgencyModel agency) async {
    final newAgency = await _repository.createAgency(agency);
    if (newAgency != null) {
      state = [...state, newAgency];
    }
  }
}
