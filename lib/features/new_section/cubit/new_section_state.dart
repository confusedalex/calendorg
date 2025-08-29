part of 'new_section_cubit.dart';

final class NewSectionState {
  final String? title;
  final OrgTimestamp? timestamp;

  NewSectionState({this.title, this.timestamp});

  NewSectionState copyWith(
      {ValueGetter<String?>? title, ValueGetter<OrgTimestamp?>? timestamp}) {
    return NewSectionState(
        title: title != null ? title() : this.title,
        timestamp: timestamp != null ? timestamp() : this.timestamp);
  }
}
