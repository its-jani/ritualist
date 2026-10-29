import 'package:flutter/material.dart' hide Feedback;
import 'package:ritualist_engine/ritualist_engine.dart';

import '../theme.dart';
import 'motion.dart';
import 'primary_button.dart';

/// The instant-feedback panel that slides up after every answer: a green
/// state with praise for a hit, a red state with the correct solution for a
/// miss - plus the "why" callout and the citation pill in both cases.
///
/// This is the app's core learning loop, so the contrast is deliberately
/// stronger than the rest of the UI: a saturated top rule, a white icon disc
/// and a solid white solution card on the failure state.
class FeedbackPanel extends StatelessWidget {
  const FeedbackPanel({
    super.key,
    required this.feedback,
    required this.onContinue,
    this.continueLabel,
  });

  final Feedback feedback;
  final VoidCallback onContinue;

  /// Defaults to "Continue" on a hit and "Got it" on a miss.
  final String? continueLabel;

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
    final Color ink = correct ? RitualColors.correctInk : RitualColors.roseInk;
    final IconData icon =
        correct ? Icons.check_rounded : Icons.close_rounded;

    final String title = correct
        ? (feedback.combo >= 2
            ? '${_praise[feedback.combo % _praise.length]} ${feedback.combo} in a row!'
            : _praise[0])
        : 'Not quite';
    final String subtitle = correct
        ? 'Keep the run going.'
        : 'The correct answer is highlighted above.';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: ink, width: 3)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          PopIn(
                            beginScale: 0.3,
                            beginOffset: Offset.zero,
                            duration: const Duration(milliseconds: 340),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: ink, width: 2.5),
                              ),
                              child: Icon(icon, color: ink, size: 26),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  title,
                                  style: AppText.title.copyWith(color: ink),
                                ),
                                Text(
                                  subtitle,
                                  style: AppText.caption.copyWith(
                                    color: ink.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (feedback.heartLost) const _HeartLostBadge(),
                        ],
                      ),
                      if (!correct) ...<Widget>[
                        const SizedBox(height: 14),
                        _SolutionBox(solution: feedback.solution ?? ''),
                      ],
                      if (feedback.explanation != null &&
                          feedback.explanation!.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        _TipCallout(
                          text: feedback.explanation!,
                          label:
                              correct ? 'WHY IT IS RIGHT' : 'WHY',
                        ),
                      ],
                      if (feedback.source != null) ...<Widget>[
                        const SizedBox(height: 12),
                        _SourcePill(source: feedback.source!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              RitualButton(
                label: continueLabel ?? (correct ? 'Continue' : 'Got it'),
                onPressed: onContinue,
                variant: correct
                    ? RitualButtonVariant.primary
                    : RitualButtonVariant.danger,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The correct-answer card: solid white so it reads first in the red state.
class _SolutionBox extends StatelessWidget {
  const _SolutionBox({required this.solution});

  final String solution;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RitualColors.rose, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'CORRECT SOLUTION',
            style: AppText.label.copyWith(
              color: RitualColors.roseInk,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            solution,
            style: AppText.body.copyWith(color: RitualColors.ink),
          ),
        ],
      ),
    );
  }
}

/// A quiet "why" card: the pedagogy, separated from the verdict above it.
class _TipCallout extends StatelessWidget {
  const _TipCallout({required this.text, required this.label});

  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RitualColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RitualColors.lineStrong, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.lightbulb_outline_rounded,
            size: 18,
            color: RitualColors.amberLip,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: AppText.label.copyWith(
                    color: RitualColors.amberLip,
                    fontSize: 10.5,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: AppText.bodyMuted.copyWith(color: RitualColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartLostBadge extends StatelessWidget {
  const _HeartLostBadge();

  @override
  Widget build(BuildContext context) {
    return PopIn(
      delay: const Duration(milliseconds: 140),
      beginScale: 0.5,
      beginOffset: Offset.zero,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: RitualColors.roseLip.withValues(alpha: 0.5),
            width: 2,
          ),
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
      ),
    );
  }
}

/// Citation chip: "Sahih al-Bukhari 6324 (sahih)", labelled so the source is
/// never mistaken for a recommendation.
class _SourcePill extends StatelessWidget {
  const _SourcePill({required this.source});

  final SourceRef source;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RitualColors.lineStrong, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.menu_book_rounded, size: 15, color: RitualColors.subInk),
          const SizedBox(width: 6),
          Text(
            'SOURCE',
            style: AppText.label.copyWith(
              fontSize: 10,
              letterSpacing: 1,
              color: RitualColors.subInk,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              source.display,
              style: AppText.caption.copyWith(color: RitualColors.ink),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
