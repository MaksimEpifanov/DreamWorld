import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/safety.dart';
import '../safety_controller.dart';

/// Показывает шторку подачи жалобы на пользователя или контент.
///
/// Возвращает `true`, если жалоба отправлена.
Future<bool> showReportSheet(
  BuildContext context,
  WidgetRef ref, {
  required String targetId,
  required String targetName,
  required ReportTarget target,
  bool autoBlock = false,
}) async {
  final bool? result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
    builder: (BuildContext context) => _ReportSheet(
      targetId: targetId,
      targetName: targetName,
      target: target,
      autoBlock: autoBlock,
    ),
  );
  return result ?? false;
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({
    required this.targetId,
    required this.targetName,
    required this.target,
    this.autoBlock = false,
  });

  final String targetId;
  final String targetName;
  final ReportTarget target;

  /// Всегда скрывать нарушителя после жалобы (например, для заметок на карте).
  final bool autoBlock;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  ReportReason? _reason;
  final TextEditingController _comment = TextEditingController();
  late bool _blockToo = widget.autoBlock;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _submit() {
    final ReportReason? reason = _reason;
    if (reason == null) return;

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Report report = ref.read(safetyProvider.notifier).submitReport(
          targetId: widget.targetId,
          targetName: widget.targetName,
          target: widget.target,
          reason: reason,
          comment: _comment.text.trim(),
        );

    if (_blockToo || widget.autoBlock) {
      ref.read(safetyProvider.notifier).block(
            userId: widget.targetId,
            name: widget.targetName,
            reason: reason.label,
          );
    }

    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          report.autoHidden
              ? 'Жалоба принята, контент скрыт. Спасибо за бдительность!'
              : 'Жалоба отправлена на проверку. Спасибо!',
        ),
        backgroundColor: scheme.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.page.left,
        right: AppSpacing.page.right,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.flag_outlined, color: scheme.error),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Жалоба на ${widget.target.label.toLowerCase()}',
                      style: AppTextStyles.title()),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.targetName,
              style: AppTextStyles.caption(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Что произошло?', style: AppTextStyles.bodyBold()),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReportReason.values.map((ReportReason reason) {
                final bool selected = _reason == reason;
                return ChoiceChip(
                  label: Text('${reason.emoji} ${reason.label}'),
                  selected: selected,
                  onSelected: (_) => setState(() => _reason = reason),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _comment,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Комментарий (необязательно)',
                hintText: 'Опишите ситуацию',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _blockToo,
              onChanged: widget.autoBlock
                  ? null
                  : (bool? value) =>
                        setState(() => _blockToo = value ?? false),
              title: const Text('Также заблокировать пользователя'),
              subtitle: Text(
                widget.autoBlock
                    ? 'Все его заметки на карте скроются'
                    : 'Он исчезнет из подбора и чатов',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ваша жалоба анонимна. Ложные жалобы могут ограничить аккаунт.',
              style: AppTextStyles.caption(),
            ),
            const SizedBox(height: AppSpacing.md),
            NeonButton(
              label: 'Отправить жалобу',
              icon: Icons.send_rounded,
              color: scheme.error,
              expanded: true,
              onPressed: _reason == null ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}
