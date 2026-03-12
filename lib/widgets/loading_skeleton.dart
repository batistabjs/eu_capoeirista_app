import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key});

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          children: [
            _buildDateGroupSkeleton(3),
            const SizedBox(height: 8),
            _buildDateGroupSkeleton(2),
            const SizedBox(height: 8),
            _buildDateGroupSkeleton(4),
          ],
        );
      },
    );
  }

  Widget _buildDateGroupSkeleton(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              _SkeletonBox(width: 120, height: 14, shimmer: _animation.value),
              const SizedBox(width: 12),
              Expanded(
                child: Container(height: 1, color: AppTheme.border),
              ),
            ],
          ),
        ),
        ...List.generate(count, (i) => _buildEventSkeleton(i)),
      ],
    );
  }

  Widget _buildEventSkeleton(int index) {
    final widths = [240.0, 180.0, 210.0, 160.0];
    final titleWidth = widths[index % widths.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(width: 3, height: 40, shimmer: _animation.value),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(
                    width: titleWidth, height: 14, shimmer: _animation.value),
                const SizedBox(height: 6),
                _SkeletonBox(width: 90, height: 12, shimmer: _animation.value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double shimmer;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.shimmer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.5, 1.0],
          colors: [
            AppTheme.surfaceVariant,
            AppTheme.border,
            AppTheme.surfaceVariant,
          ],
          transform: GradientRotation(shimmer),
        ),
      ),
    );
  }
}
