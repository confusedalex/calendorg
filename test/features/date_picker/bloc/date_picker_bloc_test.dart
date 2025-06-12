import 'package:bloc_test/bloc_test.dart';
import 'package:calendorg/features/date_picker/bloc/date_picker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  group(
    'Date Picker Bloc Test',
    () {
      group("initialization tests", () {
        test("OrgSimpleTimestamp without time parses correctly", () {
          final OrgSimpleTimestamp timestamp = OrgDocument.parse("<2025-12-04>")
              .find<OrgSimpleTimestamp>((node) => true)!
              .node;

          final bloc = DatePickerBloc(timestamp);

          expect(
              bloc.state,
              TypeMatcher<DatePickerState>()
                  .having((state) => state.startDate, "startDate",
                      equals(DateTime(2025, 12, 04)))
                  .having((state) => state.endDate, "endDate", isNull)
                  .having(
                      (state) => state.endDateActive, "endDateActive", isFalse)
                  .having(
                      (state) => state.endTimeActive, "endTimeActive", isFalse)
                  .having((state) => state.startTimeActive, "startTimeActive",
                      isFalse)
                  .having(
                      (state) => state.startTimeDuration,
                      "startTimeDuration",
                      equals(TimeOfDay(hour: 12, minute: 00)))
                  .having((state) => state.endTimeDuration, "endTimeDuration",
                      equals(TimeOfDay(hour: 12, minute: 00))));
        });

        test("OrgSimpleTimestamp with time parses correctly", () {
          final OrgSimpleTimestamp timestamp =
              OrgDocument.parse("<2025-12-04 13:21>")
                  .find<OrgSimpleTimestamp>((node) => true)!
                  .node;

          final bloc = DatePickerBloc(timestamp);

          expect(
              bloc.state,
              TypeMatcher<DatePickerState>()
                  .having((state) => state.startDate, "startDate",
                      equals(DateTime(2025, 12, 04, 13, 21)))
                  .having((state) => state.endDate, "endDate", isNull)
                  .having(
                      (state) => state.endDateActive, "endDateActive", isFalse)
                  .having(
                      (state) => state.endTimeActive, "endTimeActive", isFalse)
                  .having((state) => state.startTimeActive, "startTimeActive",
                      isTrue)
                  .having(
                      (state) => state.startTimeDuration,
                      "startTimeDuration",
                      equals(TimeOfDay(hour: 13, minute: 21)))
                  .having((state) => state.endTimeDuration, "endTimeDuration",
                      equals(TimeOfDay(hour: 12, minute: 00))));
        });

        test("OrgTimeRangeTimestamp parses correctly", () {
          final OrgTimeRangeTimestamp timestamp =
              OrgDocument.parse("<2025-12-04 13:21-14:56>")
                  .find<OrgTimeRangeTimestamp>((node) => true)!
                  .node;

          final bloc = DatePickerBloc(timestamp);

          expect(
              bloc.state,
              TypeMatcher<DatePickerState>()
                  .having((state) => state.startDate, "startDate",
                      equals(DateTime(2025, 12, 04, 13, 21)))
                  .having((state) => state.endDate, "endDate", isNull)
                  .having(
                      (state) => state.endDateActive, "endDateActive", isFalse)
                  .having(
                      (state) => state.endTimeActive, "endTimeActive", isTrue)
                  .having((state) => state.startTimeActive, "startTimeActive",
                      isTrue)
                  .having(
                      (state) => state.startTimeDuration,
                      "startTimeDuration",
                      equals(TimeOfDay(hour: 13, minute: 21)))
                  .having((state) => state.endTimeDuration, "endTimeDuration",
                      equals(TimeOfDay(hour: 14, minute: 56))));
        });

        test("OrgDateRangeTimestamp without times parses correctly", () {
          final OrgDateRangeTimestamp timestamp =
              OrgDocument.parse("<2025-12-04>--<2026-01-07>")
                  .find<OrgDateRangeTimestamp>((node) => true)!
                  .node;

          final bloc = DatePickerBloc(timestamp);

          expect(
              bloc.state,
              TypeMatcher<DatePickerState>()
                  .having((state) => state.startDate, "startDate",
                      equals(DateTime(2025, 12, 04, 00, 00)))
                  .having((state) => state.endDate, "endDate",
                      equals(DateTime(2026, 01, 07, 00, 00)))
                  .having(
                      (state) => state.endDateActive, "endDateActive", isTrue)
                  .having(
                      (state) => state.endTimeActive, "endTimeActive", isFalse)
                  .having((state) => state.startTimeActive, "startTimeActive",
                      isFalse)
                  .having(
                      (state) => state.startTimeDuration,
                      "startTimeDuration",
                      equals(TimeOfDay(hour: 12, minute: 00)))
                  .having((state) => state.endTimeDuration, "endTimeDuration",
                      equals(TimeOfDay(hour: 12, minute: 00))));
        });
        test(
            "OrgDateRangeTimestamp with start time but without end time parses correctly",
            () {
          final OrgDateRangeTimestamp timestamp =
              OrgDocument.parse("<2025-12-04 14:36>--<2026-01-07>")
                  .find<OrgDateRangeTimestamp>((node) => true)!
                  .node;

          final bloc = DatePickerBloc(timestamp);

          expect(
              bloc.state,
              TypeMatcher<DatePickerState>()
                  .having((state) => state.startDate, "startDate",
                      equals(DateTime(2025, 12, 04, 14, 36)))
                  .having((state) => state.endDate, "endDate",
                      equals(DateTime(2026, 01, 07, 00, 00)))
                  .having(
                      (state) => state.endDateActive, "endDateActive", isTrue)
                  .having(
                      (state) => state.endTimeActive, "endTimeActive", isFalse)
                  .having((state) => state.startTimeActive, "startTimeActive",
                      isTrue)
                  .having(
                      (state) => state.startTimeDuration,
                      "startTimeDuration",
                      equals(TimeOfDay(hour: 14, minute: 36)))
                  .having((state) => state.endTimeDuration, "endTimeDuration",
                      equals(TimeOfDay(hour: 12, minute: 00))));
        });
        test(
            "OrgDateRangeTimestamp with end time but without start time parses correctly",
            () {
          final OrgDateRangeTimestamp timestamp =
              OrgDocument.parse("<2025-12-04>--<2026-01-07 09:31>")
                  .find<OrgDateRangeTimestamp>((node) => true)!
                  .node;

          final bloc = DatePickerBloc(timestamp);

          expect(
              bloc.state,
              TypeMatcher<DatePickerState>()
                  .having((state) => state.startDate, "startDate",
                      equals(DateTime(2025, 12, 04, 00, 00)))
                  .having((state) => state.endDate, "endDate",
                      equals(DateTime(2026, 01, 07, 09, 31)))
                  .having(
                      (state) => state.endDateActive, "endDateActive", isTrue)
                  .having(
                      (state) => state.endTimeActive, "endTimeActive", isTrue)
                  .having((state) => state.startTimeActive, "startTimeActive",
                      isFalse)
                  .having(
                      (state) => state.startTimeDuration,
                      "startTimeDuration",
                      equals(TimeOfDay(hour: 12, minute: 00)))
                  .having((state) => state.endTimeDuration, "endTimeDuration",
                      equals(TimeOfDay(hour: 9, minute: 31))));
        });
        test("OrgDateRangeTimestamp with end- and start times parses correctly",
            () {
          final OrgDateRangeTimestamp timestamp =
              OrgDocument.parse("<2025-12-04 19:56>--<2026-01-07 09:31>")
                  .find<OrgDateRangeTimestamp>((node) => true)!
                  .node;

          final bloc = DatePickerBloc(timestamp);

          expect(
              bloc.state,
              TypeMatcher<DatePickerState>()
                  .having((state) => state.startDate, "startDate",
                      equals(DateTime(2025, 12, 04, 19, 56)))
                  .having((state) => state.endDate, "endDate",
                      equals(DateTime(2026, 01, 07, 09, 31)))
                  .having(
                      (state) => state.endDateActive, "endDateActive", isTrue)
                  .having(
                      (state) => state.endTimeActive, "endTimeActive", isTrue)
                  .having((state) => state.startTimeActive, "startTimeActive",
                      isTrue)
                  .having(
                      (state) => state.startTimeDuration,
                      "startTimeDuration",
                      equals(TimeOfDay(hour: 19, minute: 56)))
                  .having((state) => state.endTimeDuration, "endTimeDuration",
                      equals(TimeOfDay(hour: 9, minute: 31))));

            });
      });

      group("Event tests", () {
        late DatePickerBloc datePickerBloc;

        setUp(() {
          datePickerBloc = DatePickerBloc(OrgSimpleTimestamp(
              "<",
              (day: "01", month: "05", year: "2025", dayName: "justaday"),
              null,
              [],
              ">"));
        });

        blocTest(
          "Changing DateTime works",
          build: () => datePickerBloc,
          act: (bloc) =>
              bloc.add(DatePickerStartDateChanged(DateTime(2010, 01, 05))),
          expect: () => [
            TypeMatcher<DatePickerState>()
                .having((state) => state.startDate, "startDate",
                    equals(DateTime(2010, 01, 05)))
                .having((state) => state.endDate, "endDate", isNull)
                .having(
                    (state) => state.endTimeActive, "endTimeActive", isFalse)
                .having((state) => state.startTimeActive, "startTimeActive",
                    isFalse)
          ],
        );

        blocTest(
          "Activate endDate will flip bool",
          build: () => datePickerBloc,
          act: (bloc) => bloc.add(DatePickerEndDateActiveChanged(true)),
          expect: () => [
            TypeMatcher<DatePickerState>()
                .having((state) => state.startDate, "startDate",
                    equals(DateTime(2025, 05, 01)))
                .having((state) => state.endDate, "endDate", isNull)
                .having((state) => state.endDateActive, "endDateActive", isTrue)
                .having(
                    (state) => state.endTimeActive, "endTimeActive", isFalse)
                .having((state) => state.startTimeActive, "startTimeActive",
                    isFalse)
          ],
        );

        blocTest(
          "Deactivate endDate will flip bool",
          build: () => datePickerBloc,
          act: (bloc) => bloc.add(DatePickerEndDateActiveChanged(false)),
          expect: () => [
            TypeMatcher<DatePickerState>()
                .having((state) => state.startDate, "startDate",
                    equals(DateTime(2025, 05, 01)))
                .having((state) => state.endDate, "endDate", isNull)
                .having(
                    (state) => state.endDateActive, "endDateActive", isFalse)
                .having(
                    (state) => state.endTimeActive, "endTimeActive", isFalse)
                .having((state) => state.startTimeActive, "startTimeActive",
                    isFalse)
          ],
        );

        blocTest(
          "Activate startTime will flip bool",
          build: () => datePickerBloc,
          act: (bloc) => bloc.add(DatePickerStartTimeActiveChanged(true)),
          expect: () => [
            TypeMatcher<DatePickerState>()
                .having((state) => state.startDate, "startDate",
                    equals(DateTime(2025, 05, 01)))
                .having((state) => state.endDate, "endDate", isNull)
                .having(
                    (state) => state.endTimeActive, "endTimeActive", isFalse)
                .having(
                    (state) => state.startTimeActive, "startTimeActive", isTrue)
          ],
        );

        blocTest(
          "Deactivate startTime will flip bool",
          build: () => datePickerBloc,
          act: (bloc) => bloc.add(DatePickerStartTimeActiveChanged(false)),
          expect: () => [
            TypeMatcher<DatePickerState>()
                .having((state) => state.startDate, "startDate",
                    equals(DateTime(2025, 05, 01)))
                .having((state) => state.endDate, "endDate", isNull)
                .having(
                    (state) => state.endTimeActive, "endTimeActive", isFalse)
                .having((state) => state.startTimeActive, "startTimeActive",
                    isFalse)
          ],
        );

        blocTest(
          "Activate endTime will flip bool",
          build: () => datePickerBloc,
          act: (bloc) => bloc.add(DatePickerEndTimeActiveChanged(true)),
          expect: () => [
            TypeMatcher<DatePickerState>()
                .having((state) => state.startDate, "startDate",
                    equals(DateTime(2025, 05, 01)))
                .having((state) => state.endDate, "endDate", isNull)
                .having((state) => state.endTimeActive, "endTimeActive", isTrue)
                .having((state) => state.startTimeActive, "startTimeActive",
                    isFalse)
          ],
        );

        blocTest(
          "Deactivate endTime will flip bool",
          build: () => datePickerBloc,
          act: (bloc) => bloc.add(DatePickerEndTimeActiveChanged(false)),
          expect: () => [
            TypeMatcher<DatePickerState>()
                .having((state) => state.startDate, "startDate",
                    equals(DateTime(2025, 05, 01)))
                .having((state) => state.endDate, "endDate", isNull)
                .having(
                    (state) => state.endTimeActive, "endTimeActive", isFalse)
                .having((state) => state.startTimeActive, "startTimeActive",
                    isFalse)
          ],
        );

        blocTest(
          "Setting StartTime works",
          build: () => datePickerBloc,
          act: (bloc) => bloc.add(
              DatePickerTimeChanged(TimeOfDay(hour: 14, minute: 50), "start")),
          expect: () => [
            TypeMatcher<DatePickerState>()
                .having((state) => state.startDate, "startDate",
                    equals(DateTime(2025, 05, 01)))
                .having((state) => state.endDate, "endDate", isNull)
                .having(
                    (state) => state.endTimeActive, "endTimeActive", isFalse)
                .having((state) => state.startTimeActive, "startTimeActive",
                    isFalse)
                .having((state) => state.startTimeDuration, "startTimeDuration",
                    equals(TimeOfDay(hour: 14, minute: 50)))
          ],
        );
        blocTest(
          "Setting StartTime works",
          build: () => datePickerBloc,
          act: (bloc) => bloc.add(
              DatePickerTimeChanged(TimeOfDay(hour: 14, minute: 50), "start")),
          expect: () => [
            TypeMatcher<DatePickerState>()
                .having((state) => state.startDate, "startDate",
                    equals(DateTime(2025, 05, 01)))
                .having((state) => state.endDate, "endDate", isNull)
                .having(
                    (state) => state.endTimeActive, "endTimeActive", isFalse)
                .having((state) => state.startTimeActive, "startTimeActive",
                    isFalse)
                .having((state) => state.startTimeDuration, "startTimeDuration",
                    equals(TimeOfDay(hour: 14, minute: 50)))
                .having((state) => state.endTimeDuration, "endTimeDuration",
                    equals(TimeOfDay(hour: 12, minute: 00)))
          ],
        );

        blocTest("Setting EndTime works",
            build: () => datePickerBloc,
            act: (bloc) => bloc.add(
                DatePickerTimeChanged(TimeOfDay(hour: 12, minute: 50), "end")),
            expect: () => [
                  TypeMatcher<DatePickerState>()
                      .having((state) => state.startDate, "startDate",
                          equals(DateTime(2025, 05, 01)))
                      .having((state) => state.endDate, "endDate", isNull)
                      .having((state) => state.endTimeActive, "endTimeActive",
                          isFalse)
                      .having((state) => state.startTimeActive,
                          "startTimeActive", isFalse)
                      .having(
                          (state) => state.startTimeDuration,
                          "startTimeDuration",
                          equals(TimeOfDay(hour: 12, minute: 00)))
                      .having(
                          (state) => state.endTimeDuration,
                          "endTimeDuration",
                          equals(TimeOfDay(hour: 12, minute: 50)))
                ]);

        blocTest("Setting EndDate works",
            build: () => datePickerBloc,
            act: (bloc) =>
                bloc.add(DatePickerEndDateChanged(DateTime(2026, 02, 01))),
            expect: () => [
                  TypeMatcher<DatePickerState>()
                      .having((state) => state.startDate, "startDate",
                          equals(DateTime(2025, 05, 01)))
                      .having((state) => state.endDate, "endDate",
                          equals(DateTime(2026, 02, 01)))
                      .having((state) => state.endTimeActive, "endTimeActive",
                          isFalse)
                      .having((state) => state.startTimeActive,
                          "startTimeActive", isFalse)
                      .having(
                          (state) => state.startTimeDuration,
                          "startTimeDuration",
                          equals(TimeOfDay(hour: 12, minute: 00)))
                      .having(
                          (state) => state.endTimeDuration,
                          "endTimeDuration",
                          equals(TimeOfDay(hour: 12, minute: 00)))
                ]);
      });
    },
  );
}
