# Changelog
## Unreleased
### Fixed
- Set min/max date for the calendar to 1900-01-01 and 2100-01-01
- Canceling the directory picker won't throw an error
- Remember start/endtime when re-enterin date picker
- Update timestamp in Add Event dialog after changing in date picker
## 1.7.0 - 2026-09-29
### Added
- Pull to refresh for reloading files
- Reloading when when reopening the app while the app was not fully closed
- Add weekday text to timestamp
- Logger for logging errors and warning
- Add copy log button in the settings
- Timestamp repeaters are now handlet
### Fixed
- Don't allow invalid DateTimeRanges.
- Directly select date when creating new event
- Don't allow adding of inboxFile to agenda files or the other way around
- Find timestamps after a range timestamp in the same section
- Keep event of selected Day loaded when scrolling to other calendar pages
- Error when trying to save a file which is newer on disk
- Edits to a file that changed outside the app work again without a restart of the app
- A missing agenda file no longer hides all other files. The app shows the names of the missing files
- Saving a file works again. Before it tried to reread the old file after saving
- Keep repeaters and delays, like `+1w` or `-3d`, when you change the date of an event
- Keep the tags when you change the title of an event
- Keep the text after a timestamp in the headline when you change the date
- Keep the space between the title and a timestamp in the headline
- Show titles without the spaces before the tags
- Loading indicator no longer stays on when saving an edit fails
- Replacing a timestamp in a heading could lead to replacing everything from the first '<' to the last '>'. This is now fixed.
- Disable save button while saving to avoid double saving.
## 1.6.2 - 2026-09-11
Same as 1.6.1. Still ci Issues
## 1.6.1 - 2026-09-10
The same as 1.6.0. Some issues with the ci, therefore this "new" release.
## 1.6.0 - 2026-09-10
### Added
- Old calendar entries show until the new ones are loaded
- Calendorg build are now signed, so the app can updated not always reinstalled
### Changed
- Reduced loading times
## 1.5.0 - 2026-08-25
### Added
- Now occurences also load on page change in the calendar view.
## 1.4.4 - 2026-08-19
### Changed
- Run file parsing in one persistent threads, not one thread for each file. Should improve performance.
## 1.4.3 - 2026-07-03
### Changed
- Replaced the loading spinner with a simpler loading indicator
## 1.4.2 - 2026-07-03
### Changed
- Allow org file to be read in parallel, which should speed up the app
## 1.4.1 - 2026-06-29
### Changed
- Changed algorithm for comparing files, because the former method didn't work on android :(
## 1.4.0 - 2026-06-29
### Added
- Loading animation while org files are loaded
### Changed
- Completely overhauled the file picking workings. Instead of picking
  içgndividual files, you have to pick a org files directory first, and
  then pick the individual files from this directory.
## 1.3.1 - 2026-06-27
I forgot to bump the the version number for 1.3.0, therefore this is
more of a fixup.

### Removed
- Unused permission
## 1.3.0 - 2026-06-25
### Added
- Include more debug information
## 1.2.0 - 2026-06-19
### Changed
- UI improvements in dialogs. Dialogs now show icons and the dialog itself is rounded.
## 1.1.0 - 2026-06-16
### Added
- Debug page to the settings menu, which helps developers to look into the internals of the App.
### Changed
- Directly parse file when adding it to the agenda files. Therefore the events are directly displayed.
- Await loading of todoStates so their availability is guaranteed.
- Use loaded todoStates for the first event parsing. 

## 1.0.2 - 2026-04-27
### Changed
- Many files and functions were split into seperate services. This
  unexpectetly came with perfomance improvments, therefore the
  release.

## 1.0.1 - 2026-04-25
### Removed
- Loading animation

