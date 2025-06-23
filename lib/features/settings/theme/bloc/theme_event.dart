part of 'theme_bloc.dart';

sealed class ThemeEvent {}

final class ThemeSwitchEvent extends ThemeEvent {
  final ThemeData theme;
  ThemeSwitchEvent(this.theme);
}
