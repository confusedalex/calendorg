part of 'theme_bloc.dart';

sealed class ThemeEvent {}

final class ThemeSwitchEvent extends ThemeEvent {
  final ThemeMode theme;
  ThemeSwitchEvent(this.theme);
}
