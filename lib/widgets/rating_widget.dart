import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color color;
  final bool allowHalfRating;
  final Function(double)? onRatingChanged;

  const RatingWidget({
    Key? key,
    required this.rating,
    this.starCount = 5,
    this.size = 20,
    this.color = const Color(0xFFFFA500),
    this.allowHalfRating = true,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(index + 1.0)
              : null,
          child: Icon(
            _getIconData(index),
            size: size,
            color: color,
          ),
        );
      }),
    );
  }

  IconData _getIconData(int index) {
    double difference = rating - index;
    
    if (difference >= 1) {
      return Icons.star;
    } else if (difference >= 0.5 && allowHalfRating) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }
}

class RatingSelector extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingChanged;
  final double size;
  final Color color;

  const RatingSelector({
    Key? key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 30,
    this.color = const Color(0xFFFFA500),
  }) : super(key: key);

  @override
  State<RatingSelector> createState() => _RatingSelectorState();
}

class _RatingSelectorState extends State<RatingSelector> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1.0;
            });
            widget.onRatingChanged(_rating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              size: widget.size,
              color: widget.color,
            ),
          ),
        );
      }),
    );
  }
}
