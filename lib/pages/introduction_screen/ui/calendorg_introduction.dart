import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_cubit.dart';
import '../../../core/tag_colors/tag_color.dart';
import '../../../features/settings/agenda_files/ui/agenda_files_dialog.dart';
import '../../../features/settings/agenda_files/ui/agenda_page.dart';
import '../../../features/settings/tags/ui/edit_tag_color_dialog.dart';
import '../../../features/settings/tags/ui/new_tag_color_dialog.dart';
import '../../../util.dart';

enum _Step { welcome, directory, files, inbox, tags }

const _duration = Duration(milliseconds: 350);
const _curve = Curves.easeOutCubic;

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({required this.onDone, super.key});

  final VoidCallback onDone;

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final _controller = PageController();
  var _step = _Step.welcome;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _canContinue(OrgFilesState files) => switch (_step) {
    _Step.directory => files.directory != null,
    _Step.files => files.filePaths.isNotEmpty,
    _ => true,
  };

  Future<void> _goTo(int index) =>
      _controller.animateToPage(index, duration: _duration, curve: _curve);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLast = _step == _Step.values.last;

    return PopScope(
      canPop: _step.index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_goTo(_step.index - 1));
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<OrgFilesCubit, OrgFilesState>(
            builder: (context, files) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                  child: Row(
                    children: [
                      AnimatedOpacity(
                        opacity: _step.index > 0 ? 1 : 0,
                        duration: _duration,
                        child: IconButton(
                          onPressed: _step.index > 0
                              ? () => _goTo(_step.index - 1)
                              : null,
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _Progress(_step)),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    // Blocks swiping forward until the step is done.
                    physics: _canContinue(files)
                        ? null
                        : const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) =>
                        setState(() => _step = _Step.values[index]),
                    children: [
                      for (final step in _Step.values)
                        _page(context, step, files),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                        textStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                      onPressed: !_canContinue(files)
                          ? null
                          : isLast
                          ? widget.onDone
                          : () => _goTo(_step.index + 1),
                      child: Text(switch (_step) {
                        _Step.tags => l10n.intro_finish,
                        _Step.inbox when files.inboxFile == null =>
                          l10n.intro_skip,
                        _ => l10n.intro_next,
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _page(BuildContext context, _Step step, OrgFilesState files) {
    final l10n = context.l10n;

    return switch (step) {
      _Step.welcome => _StepPage(
        hero: Image(
          image: const AssetImage('assets/calendorg-round.png'),
          // Leaves room for the text on short screens.
          width: (MediaQuery.sizeOf(context).height * 0.28).clamp(120, 200),
        ),
        title: l10n.intro_welcome_title,
        body: l10n.intro_welcome_body,
      ),
      _Step.directory => _StepPage(
        title: l10n.intro_directory_title,
        body: l10n.intro_directory_body,
        action: _SetupCard(
          icon: Icons.folder_outlined,
          label: l10n.pick_org_directory,
          subtitle: files.directory?.fileName ?? l10n.not_set,
          isSet: files.directory != null,
          onTap: () => pickOrgDirectory(context),
        ),
      ),
      _Step.files => _StepPage(
        title: l10n.intro_files_title,
        body: l10n.intro_files_body,
        action: _SetupCard(
          icon: Icons.folder_copy_outlined,
          label: l10n.choose_files,
          subtitle: files.filePaths.isEmpty
              ? l10n.not_set
              : files.filePaths.map((f) => f.fileName).nonNulls.join(', '),
          isSet: files.filePaths.isNotEmpty,
          onTap: () => showDialog(
            context: context,
            builder: (_) => const AgendaFilesDialog(),
          ),
        ),
      ),
      _Step.inbox => _StepPage(
        title: l10n.intro_inbox_title,
        body: l10n.intro_inbox_body,
        action: _SetupCard(
          icon: Icons.move_to_inbox_outlined,
          label: l10n.inbox_file,
          subtitle: files.inboxFile?.fileName ?? l10n.not_set,
          isSet: files.inboxFile != null,
          onTap: () => pickInboxFile(context),
        ),
      ),
      _Step.tags => _StepPage(
        title: l10n.intro_tags_title,
        body: l10n.intro_tags_body,
        action: const _TagsSetup(),
      ),
    };
  }
}

class _Progress extends StatelessWidget {
  const _Progress(this.step);

  final _Step step;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      spacing: 6,
      children: [
        for (final s in _Step.values)
          Expanded(
            child: AnimatedContainer(
              duration: _duration,
              curve: _curve,
              height: 4,
              decoration: BoxDecoration(
                color: s.index <= step.index
                    ? colors.primary
                    : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}

class _StepPage extends StatelessWidget {
  const _StepPage({
    this.hero,
    required this.title,
    required this.body,
    this.action,
  });

  final Widget? hero;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Fades the bottom edge, so that cut-off text hints that the page scrolls.
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.9, 1],
        colors: [Colors.black, Colors.transparent],
      ).createShader(bounds),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            if (hero case final hero?) ...[
              Center(child: hero),
              const SizedBox(height: 40),
            ],
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 32), action!],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isSet = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;
  final bool isSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final subtitle = this.subtitle;

    return Material(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSet ? colors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 16,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSet
                      ? colors.primary
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isSet ? Icons.check_rounded : icon,
                  size: 22,
                  color: isSet ? colors.onPrimary : colors.onSurface,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(label, style: theme.textTheme.titleSmall),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagsSetup extends StatelessWidget {
  const _TagsSetup();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocSelector<SettingsCubit, AppSettings, List<TagColor>>(
      selector: (settings) => settings.tagColors,
      builder: (context, tagColors) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          _SetupCard(
            icon: Icons.add,
            label: context.l10n.intro_add_tag,
            onTap: () => showDialog(
              context: context,
              builder: (_) => const NewTagColorDialog(),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tagColor in tagColors)
                Material(
                  color: tagColor.color.withValues(alpha: 0.15),
                  shape: const StadiumBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => EditTagColorDialog(tagColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6,
                        children: [
                          CircleAvatar(
                            radius: 4,
                            backgroundColor: tagColor.color,
                          ),
                          Text(tagColor.tag, style: theme.textTheme.labelLarge),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
