import 'package:bloc_test/bloc_test.dart';
import 'package:calendorg/features/date_picker/model/date_picker_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  group('Date Picker Cubit Test', () {
    final OrgSimpleTimestamp timestamp = OrgDocument.parse(
      '<2025-12-04>',
    ).find<OrgSimpleTimestamp>((node) => true)!.node;
    late DatePickerCubit cubit;

    setUp(() {
      cubit = DatePickerCubit(DatePickerState.initial(timestamp));
    });

    group('initialization tests', () {
      test('OrgSimpleTimestamp without time parses correctly', () {
        expect(
          cubit.state,
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 12, 04)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endDateActive, 'endDateActive', isFalse)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isFalse,
              )
              .having(
                (state) => state.startTime,
                'startTime',
                equals(const TimeOfDay(hour: 12, minute: 00)),
              )
              .having(
                (state) => state.endTime,
                'endTime',
                equals(const TimeOfDay(hour: 12, minute: 00)),
              ),
        );
      });

      test('OrgSimpleTimestamp with time parses correctly', () {
        final OrgSimpleTimestamp timestamp = OrgDocument.parse(
          '<2025-12-04 13:21>',
        ).find<OrgSimpleTimestamp>((node) => true)!.node;

        final cubit = DatePickerCubit(DatePickerState.initial(timestamp));

        expect(
          cubit.state,
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 12, 04, 13, 21)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endDateActive, 'endDateActive', isFalse)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isTrue,
              )
              .having(
                (state) => state.startTime,
                'startTime',
                equals(const TimeOfDay(hour: 13, minute: 21)),
              )
              .having(
                (state) => state.endTime,
                'endTime',
                equals(const TimeOfDay(hour: 12, minute: 00)),
              ),
        );
      });

      test('OrgTimeRangeTimestamp parses correctly', () {
        final OrgTimeRangeTimestamp timestamp = OrgDocument.parse(
          '<2025-12-04 13:21-14:56>',
        ).find<OrgTimeRangeTimestamp>((node) => true)!.node;

        final cubit = DatePickerCubit(DatePickerState.initial(timestamp));

        expect(
          cubit.state,
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 12, 04, 13, 21)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endDateActive, 'endDateActive', isFalse)
              .having((state) => state.endTimeActive, 'endTimeActive', isTrue)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isTrue,
              )
              .having(
                (state) => state.startTime,
                'startTime',
                equals(const TimeOfDay(hour: 13, minute: 21)),
              )
              .having(
                (state) => state.endTime,
                'endTime',
                equals(const TimeOfDay(hour: 14, minute: 56)),
              ),
        );
      });

      test('OrgDateRangeTimestamp without times parses correctly', () {
        final OrgDateRangeTimestamp timestamp = OrgDocument.parse(
          '<2025-12-04>--<2026-01-07>',
        ).find<OrgDateRangeTimestamp>((node) => true)!.node;

        final cubit = DatePickerCubit(DatePickerState.initial(timestamp));

        expect(
          cubit.state,
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 12, 04)),
              )
              .having(
                (state) => state.endDate,
                'endDate',
                equals(DateTime(2026, 01, 07)),
              )
              .having((state) => state.endDateActive, 'endDateActive', isTrue)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isFalse,
              )
              .having(
                (state) => state.startTime,
                'startTime',
                equals(const TimeOfDay(hour: 12, minute: 00)),
              )
              .having(
                (state) => state.endTime,
                'endTime',
                equals(const TimeOfDay(hour: 12, minute: 00)),
              ),
        );
      });
      test(
        'OrgDateRangeTimestamp with start time but without end time parses correctly',
        () {
          final OrgDateRangeTimestamp timestamp = OrgDocument.parse(
            '<2025-12-04 14:36>--<2026-01-07>',
          ).find<OrgDateRangeTimestamp>((node) => true)!.node;

          final cubit = DatePickerCubit(DatePickerState.initial(timestamp));

          expect(
            cubit.state,
            const TypeMatcher<DatePickerState>()
                .having(
                  (state) => state.startDate,
                  'startDate',
                  equals(DateTime(2025, 12, 04, 14, 36)),
                )
                .having(
                  (state) => state.endDate,
                  'endDate',
                  equals(DateTime(2026, 01, 07)),
                )
                .having((state) => state.endDateActive, 'endDateActive', isTrue)
                .having(
                  (state) => state.endTimeActive,
                  'endTimeActive',
                  isFalse,
                )
                .having(
                  (state) => state.startTimeActive,
                  'startTimeActive',
                  isTrue,
                )
                .having(
                  (state) => state.startTime,
                  'startTime',
                  equals(const TimeOfDay(hour: 14, minute: 36)),
                )
                .having(
                  (state) => state.endTime,
                  'endTime',
                  equals(const TimeOfDay(hour: 12, minute: 00)),
                ),
          );
        },
      );
      test(
        'OrgDateRangeTimestamp with end time but without start time parses correctly',
        () {
          final OrgDateRangeTimestamp timestamp = OrgDocument.parse(
            '<2025-12-04>--<2026-01-07 09:31>',
          ).find<OrgDateRangeTimestamp>((node) => true)!.node;

          final cubit = DatePickerCubit(DatePickerState.initial(timestamp));

          expect(
            cubit.state,
            const TypeMatcher<DatePickerState>()
                .having(
                  (state) => state.startDate,
                  'startDate',
                  equals(DateTime(2025, 12, 04)),
                )
                .having(
                  (state) => state.endDate,
                  'endDate',
                  equals(DateTime(2026, 01, 07, 09, 31)),
                )
                .having((state) => state.endDateActive, 'endDateActive', isTrue)
                .having((state) => state.endTimeActive, 'endTimeActive', isTrue)
                .having(
                  (state) => state.startTimeActive,
                  'startTimeActive',
                  isFalse,
                )
                .having(
                  (state) => state.startTime,
                  'startTime',
                  equals(const TimeOfDay(hour: 12, minute: 00)),
                )
                .having(
                  (state) => state.endTime,
                  'endTime',
                  equals(const TimeOfDay(hour: 9, minute: 31)),
                ),
          );
        },
      );
      test(
        'OrgDateRangeTimestamp with end- and start times parses correctly',
        () {
          final OrgDateRangeTimestamp timestamp = OrgDocument.parse(
            '<2025-12-04 19:56>--<2026-01-07 09:31>',
          ).find<OrgDateRangeTimestamp>((node) => true)!.node;

          final cubit = DatePickerCubit(DatePickerState.initial(timestamp));

          expect(
            cubit.state,
            const TypeMatcher<DatePickerState>()
                .having(
                  (state) => state.startDate,
                  'startDate',
                  equals(DateTime(2025, 12, 04, 19, 56)),
                )
                .having(
                  (state) => state.endDate,
                  'endDate',
                  equals(DateTime(2026, 01, 07, 09, 31)),
                )
                .having((state) => state.endDateActive, 'endDateActive', isTrue)
                .having((state) => state.endTimeActive, 'endTimeActive', isTrue)
                .having(
                  (state) => state.startTimeActive,
                  'startTimeActive',
                  isTrue,
                )
                .having(
                  (state) => state.startTime,
                  'startTime',
                  equals(const TimeOfDay(hour: 19, minute: 56)),
                )
                .having(
                  (state) => state.endTime,
                  'endTime',
                  equals(const TimeOfDay(hour: 9, minute: 31)),
                ),
          );
        },
      );
    });

    group('Event tests', () {
      late DatePickerCubit datePickerCubit;

      setUp(() {
        datePickerCubit = DatePickerCubit(
          DatePickerState.initial(
            OrgSimpleTimestamp(
              '<',
              (day: '01', month: '05', year: '2025', dayName: 'justaday'),
              null,
              [],
              '>',
            ),
          ),
        );
      });

      blocTest(
        'Changing DateTime works',
        build: () => datePickerCubit,
        act: (cubit) => cubit.changeStartDate(DateTime(2010, 01, 05)),
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2010, 01, 05)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isFalse,
              ),
        ],
      );

      blocTest(
        'Activate endDate will flip bool',
        build: () => datePickerCubit,
        act: (cubit) => cubit.changeEndDateActive(true),
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 05)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endDateActive, 'endDateActive', isTrue)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isFalse,
              ),
        ],
      );

      blocTest(
        'Deactivate endDate will flip bool',
        build: () => datePickerCubit,
        act: (cubit) => cubit.changeEndDateActive(false),
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 05)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endDateActive, 'endDateActive', isFalse)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isFalse,
              ),
        ],
      );

      blocTest(
        'Activate startTime will flip bool',
        build: () => datePickerCubit,
        act: (cubit) => cubit.changeStartTimeActive(true),
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 05)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isTrue,
              ),
        ],
      );

      blocTest(
        'Deactivate startTime will flip bool',
        build: () => datePickerCubit,
        act: (cubit) => cubit.changeStartTimeActive(false),
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 05)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isFalse,
              ),
        ],
      );

      blocTest(
        'Activate endTime will flip bool',
        build: () => datePickerCubit,
        act: (cubit) => cubit.changeEndTimeActive(true),
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 05)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endTimeActive, 'endTimeActive', isTrue)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isFalse,
              ),
        ],
      );

      blocTest(
        'Deactivate endTime will flip bool',
        build: () => datePickerCubit,
        act: (cubit) => cubit.changeEndTimeActive(false),
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 05)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isFalse,
              ),
        ],
      );

      blocTest(
        'Setting StartTime works',
        build: () => datePickerCubit,
        act: (cubit) => cubit.changeTime(
          const TimeOfDay(hour: 14, minute: 50),
          DatePickerType.start,
        ),
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 05)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isFalse,
              )
              .having(
                (state) => state.startTime,
                'startTime',
                equals(const TimeOfDay(hour: 14, minute: 50)),
              ),
        ],
      );
      blocTest(
        'Setting StartTime works',
        build: () => datePickerCubit,
        act: (cubit) => cubit.changeTime(
          const TimeOfDay(hour: 14, minute: 50),
          DatePickerType.start,
        ),
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 05)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isFalse,
              )
              .having(
                (state) => state.startTime,
                'startTime',
                equals(const TimeOfDay(hour: 14, minute: 50)),
              )
              .having(
                (state) => state.endTime,
                'endTime',
                equals(const TimeOfDay(hour: 12, minute: 00)),
              ),
        ],
      );

      blocTest(
        'Setting EndTime works',
        build: () => datePickerCubit,
        act: (cubit) => cubit.changeTime(
          const TimeOfDay(hour: 12, minute: 50),
          DatePickerType.end,
        ),
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 05)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isFalse,
              )
              .having(
                (state) => state.startTime,
                'startTime',
                equals(const TimeOfDay(hour: 12, minute: 00)),
              )
              .having(
                (state) => state.endTime,
                'endTime',
                equals(const TimeOfDay(hour: 12, minute: 50)),
              ),
        ],
      );

      blocTest(
        'Setting EndDate works',
        build: () => datePickerCubit,
        act: (cubit) => cubit.changeEndDate(DateTime(2026, 02)),
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 05)),
              )
              .having(
                (state) => state.endDate,
                'endDate',
                equals(DateTime(2026, 02)),
              )
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isFalse,
              )
              .having(
                (state) => state.startTime,
                'startTime',
                equals(const TimeOfDay(hour: 12, minute: 00)),
              )
              .having(
                (state) => state.endTime,
                'endTime',
                equals(const TimeOfDay(hour: 12, minute: 00)),
              ),
        ],
      );

      blocTest(
        'Deactivating startTime without an end date turns endTime off',
        build: () => datePickerCubit,
        act: (cubit) {
          cubit
            ..changeStartTimeActive(true)
            ..changeEndTimeActive(true)
            ..changeStartTimeActive(false);
        },
        skip: 2,
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isFalse,
              )
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse),
        ],
      );

      blocTest(
        'Deactivating endDate without a start time turns endTime off',
        build: () => datePickerCubit,
        act: (cubit) {
          cubit
            ..changeEndDateActive(true)
            ..changeEndTimeActive(true)
            ..changeEndDateActive(false);
        },
        skip: 2,
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having((state) => state.endDateActive, 'endDateActive', isFalse)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse),
        ],
      );

      blocTest(
        'Activating startTime keeps endTime off',
        build: () => datePickerCubit,
        act: (cubit) => cubit.changeStartTimeActive(true),
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isTrue,
              )
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse),
        ],
      );

      blocTest(
        "Setting EndTimeActive while StartTimeActive is true won't set StartTimeActive to false",
        build: () => datePickerCubit,
        act: (cubit) {
          cubit
            ..changeStartTimeActive(true)
            ..changeEndTimeActive(true);
        },
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 05)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endTimeActive, 'endTimeActive', isFalse)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isTrue,
              ),
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.startDate,
                'startDate',
                equals(DateTime(2025, 05)),
              )
              .having((state) => state.endDate, 'endDate', isNull)
              .having((state) => state.endTimeActive, 'endTimeActive', isTrue)
              .having(
                (state) => state.startTimeActive,
                'startTimeActive',
                isTrue,
              ),
        ],
      );
    });

    group('Range check tests', () {
      DatePickerState parse(String text) => DatePickerState.initial(
        OrgDocument.parse(text).find<OrgTimestamp>((node) => true)!.node,
      );

      test('A valid time range is not flagged', () {
        final state = parse('<2026-10-01 Thu 12:00-14:00>');
        expect(state.endTimeBeforeStart, isFalse);
      });

      test('An end time before the start time is flagged', () {
        final state = parse('<2026-10-01 Thu 14:00-12:00>');
        expect(state.endTimeBeforeStart, isTrue);
      });

      test('An earlier end time on a later day is not flagged', () {
        final state = parse('<2026-10-01 Thu 14:00>--<2026-10-02 Fri 12:00>');
        expect(state.endTimeBeforeStart, isFalse);
      });

      blocTest(
        'Picking an end time before the start time keeps the value',
        build: () => DatePickerCubit(parse('<2026-10-01 Thu 10:00-12:00>')),
        act: (cubit) => cubit.changeTime(
          const TimeOfDay(hour: 9, minute: 0),
          DatePickerType.end,
        ),
        expect: () => [
          const TypeMatcher<DatePickerState>()
              .having(
                (state) => state.endTime,
                'endTime',
                const TimeOfDay(hour: 9, minute: 0),
              )
              .having(
                (state) => state.endTimeBeforeStart,
                'endTimeBeforeStart',
                isTrue,
              ),
        ],
      );
    });
  });
}
