import 'dart:io';

import 'package:fertilizer_calculator/core/components/space.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/calculator/models/fertilizer_model.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/fertilizer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FertilizerCard extends StatefulWidget {
  final FertilizerModel data;
  final VoidCallback detailFertilizer;

  const FertilizerCard({
    super.key,
    required this.data,
    required this.detailFertilizer,
  });

  @override
  State<FertilizerCard> createState() => _FertilizerCardState();
}

class _FertilizerCardState extends State<FertilizerCard> {
  @override
  Widget build(BuildContext context) {
    bool isChecked = Provider.of<FertilizerProvider>(context)
        .isFertilizerChecked(widget.data.name);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.card
            : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              child: widget.data.image.isNotEmpty &&
                      (widget.data.image.startsWith('assets/') ||
                          File(widget.data.image).existsSync())
                  ? (widget.data.image.startsWith('assets/')
                      ? Image.asset(widget.data.image,
                          height: 135, width: 135, fit: BoxFit.cover)
                      : Image.file(File(widget.data.image),
                          height: 135, width: 135, fit: BoxFit.cover))
                  : Container(
                      height: 135,
                      width: 135,
                      decoration: BoxDecoration(
                          color: Colors.grey[300], shape: BoxShape.circle),
                      child: const Icon(Icons.image_not_supported,
                          size: 75, color: Colors.red),
                    ),
            ),
          ),
          const Spacer(),
          Text(
            widget.data.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SpaceHeight(8.0),
          Text(
            widget.data.category,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SpaceHeight(8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(9.0)),
                    color: AppColors.darkblue,
                  ),
                  child: InkWell(
                    onTap: () {
                      widget.detailFertilizer();
                    },
                    child: const Center(
                      child: Text(
                        'Detail',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.light,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isChecked = !isChecked;
                  });
                  if (isChecked) {
                    Provider.of<FertilizerProvider>(context, listen: false)
                        .addFertilizerCheck(widget.data);
                  } else {
                    Provider.of<FertilizerProvider>(context, listen: false)
                        .removeFertilizerCheck(widget.data);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(9.0)),
                    color: isChecked
                        ? AppColors.darkgreen
                        : Colors.grey, // Change color based on state
                  ),
                  child: Icon(
                    isChecked
                        ? Icons.check
                        : null, // Show check icon if checked
                    color: Colors.white,
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
