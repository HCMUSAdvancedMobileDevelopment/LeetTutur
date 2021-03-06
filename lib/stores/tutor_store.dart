import 'package:get_it/get_it.dart';
import 'package:leet_tutur/models/favorite_tutor.dart';
import 'package:leet_tutur/models/requests/report_request.dart';
import 'package:leet_tutur/models/responses/report_response.dart';
import 'package:leet_tutur/models/row_of_tutor.dart';
import 'package:leet_tutur/models/tutor.dart';
import 'package:leet_tutur/models/requests/tutor_request.dart';
import 'package:leet_tutur/models/responses/tutor_response.dart';
import 'package:leet_tutur/services/tutor_service.dart';
import 'package:mobx/mobx.dart';

part 'tutor_store.g.dart';

class TutorStore = _TutorStore with _$TutorStore;

abstract class _TutorStore with Store {
  final _tutorService = GetIt.instance.get<TutorService>();

  @observable
  ObservableFuture<TutorResponse>? tutorResponseFuture;

  @observable
  String selectedTutorId = "";

  @observable
  ObservableFuture<Tutor>? tutorDetailFuture;

  @observable
  ObservableMap<String, String> tutorSpecialtyMap = ObservableMap();

  @observable
  ObservableMap<String, String> tutorCountryCodeMap = ObservableMap();

  @observable
  String selectedSpecialty = "";

  @computed
  RowOfTutor? get rowOfTutor => tutorResponseFuture?.value?.tutors;

  @computed
  List<FavoriteTutor>? get favoriteTutorList =>
      tutorResponseFuture?.value?.favoriteTutor;

  bool isFavoriteTutor(Tutor tutor) {
    var index = favoriteTutorList
        ?.indexWhere((element) => element.secondId == tutor.userId);
    return favoriteTutorList != null && index != null && index >= 0;
  }

  @action
  Future<TutorResponse> searchTutorsAsync({TutorRequest? request}) async =>
      tutorResponseFuture =
          ObservableFuture(_tutorService.searchTutorsAsync(request: request));

  @action
  Future<Tutor> getTutorDetail({String id = "0"}) async => tutorDetailFuture =
      ObservableFuture(_tutorService.getTutorDetail(id: id));

  @action
  void unSelectTutor() {
    tutorDetailFuture = null;
  }

  Future addToFavoriteTutorAsync(String? tutorId) async {
    await _tutorService.addToFavoriteTutorAsync(tutorId);

    if (isFavoriteTutor(Tutor(userId: tutorId))) {
      favoriteTutorList?.removeWhere((element) => element.secondId == tutorId);
    } else {
      favoriteTutorList?.add(FavoriteTutor(secondId: tutorId));
    }
  }

  @action
  Future getTutorSpecialtiesAsync() async =>
      tutorSpecialtyMap = ObservableMap.of(
        await _tutorService.getTutorSpecialtiesAsync(),
      );

  @action
  Future<Map<String, String>> getTutorCountryAsync() async =>
      tutorCountryCodeMap =
          ObservableMap.of(await _tutorService.getTutorCountryAsync());

  Future<ReportResponse> reportTutorAsync(ReportRequest request) async =>
      await _tutorService.reportTutorAsync(request);
}
