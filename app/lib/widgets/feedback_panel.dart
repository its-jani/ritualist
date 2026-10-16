import 'package:flutter/material.dart' hide Feedback;
import 'package:ritualist_engine/ritualist_engine.dart';

import '../theme.dart';
import 'primary_button.dart';

/// The instant-feedback panel that slides up after every answer: green tint
/// with praise for a hit, red tint with the correct solution, the explanation
/// and the source reference for a miss. This is the app's core learning loop.
class FeedbackPanel extends StatelessWidget {
  const FeedbackPanel({
    super.key,
    required this.feedback,
    required this.onContinue,
    this.continueLabel = 'Continue',
  });

  final Feedback feedback;
  final VoidCallback onContinue;
  final String continueLabel;

  static const List<String> _praise = <String>[
    'Correct!',
    'Nice!',
    'Great!',
    'Amazing!',
    'Outstanding!',
  ];

  @override
  Widget build(BuildContext context) {
    final bool correct = feedback.correct;
    final Color tint =
        correct ? RitualColors.correctTint : RitualColors.roseTint;
    final Color ink =
        correct ? RitualColors.correctInk : RitualColors.roseInk;
    final IconData icon =
        correct ? Icons.check_circle_rounded : Icons.cancel_rounded;

    final String title = correct
        ? (feedback.combo >= 2
            ? '${_praise[feedback.combo % _praise.length]} ${feedback.combo} in a row!'
            : _praise[0])
        : 'Correct solution:';

    final Widget? detail = correct ? null : _SolutionBox(
          solution: feedback.solution ?? '',
        );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: ink.withValues(alpha: 0.25), width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, color: ink, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: AppText.title.copyWith(color: ink),
                    ),
                  ),
                  if (feedback.heartLost) const _HeartLostBadge(),
                ],
              ),
              if (detail != null) ...<Widget>[
                const SizedBox(height: 12),
                detail,
              ],
              if (feedback.explanation != null &&
                  feedback.explanation!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  feedback.explanation!,
                  style: AppText.bodyMuted.copyWith(color: RitualColors.ink),
                ),
              ],
              if (feedback.source != null) ...<Widget>[
                const SizedBox(height: 10),
                _SourcePill(source: feedback.source!),
              ],
              const SizedBox(height: 14),
              RitualButton(
                label: continueLabel,
                onPressed: onContinue,
                variant:
                    correct ? RitualButtonVariant.primary : RitualButtonVariant.danger,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SolutionBox extends StatelessWidget {
  const _SolutionBox({required this.solution});

  final String solution;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RitualColors.roseLip.withValues(alpha: 0.4), width: 2),
      ),
      child: Text(
        solution,
        style: AppText.body.copyWith(color: RitualColors.roseInk),
      ),
    );
  }
}

class _HeartLostBadge extends StatelessWidget {
  const _HeartLostBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RitualColors.roseLip.withValues(alpha: 0.5), width: 2),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.heart_broken_rounded, size: 16, color: RitualColors.rose),
          SizedBox(width: 4),
          Text(
            '-1',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: RitualColors.roseInk,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small citation chip: "Sahih al-Bukhari 6324 (sahih)".
class _SourcePill extends StatelessWidget {
  const _SourcePill({required this.source});

  final SourceRef source;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RitualColors.line, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.menu_book_rounded, size: 15, color: RitualColors.subInk),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              source.display,
              style: AppText.caption,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
