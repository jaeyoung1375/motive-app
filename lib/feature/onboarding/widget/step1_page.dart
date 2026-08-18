import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_provider.dart';
import 'package:motive_app_toy/feature/onboarding/widget/dashed_circle_border.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_colors.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_field_input.dart';
import 'package:motive_app_toy/feature/onboarding/widget/onboarding_header.dart';

class Step1Page extends ConsumerStatefulWidget {
  const Step1Page({super.key, required this.onNext});

  final void Function(String name, Uint8List? imageBytes, String? imageName)
  onNext;

  @override
  ConsumerState<Step1Page> createState() => _Step1PageState();
}

class _Step1PageState extends ConsumerState<Step1Page> {
  late final _nameController = TextEditingController(
    text: ref.read(onboardingProvider).nickname,
  );
  late Uint8List? _imageBytes = ref.read(onboardingProvider).profileImageBytes;
  late String? _imageName = ref.read(onboardingProvider).profileImageName;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageName = picked.name;
    });
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text.trim();

    return Scaffold(
      backgroundColor: OnboardingColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 402),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const OnboardingHeader(step: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 8, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '사용할 이름을 입력해 주세요',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: OnboardingColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: _ProfileImagePicker(
                            imageBytes: _imageBytes,
                            onPick: _pickImage,
                            onRemove: _removeImage,
                          ),
                        ),
                        const SizedBox(height: 24),
                        OnboardingFieldInput(
                          label: '이름',
                          controller: _nameController,
                          placeholder: '이름을 입력해주세요',
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                  child: SizedBox(
                    height: 53,
                    child: Opacity(
                      opacity: name.isEmpty ? 0.4 : 1,
                      child: ElevatedButton(
                        onPressed: name.isEmpty
                            ? null
                            : () => widget.onNext(
                                name,
                                _imageBytes,
                                _imageName,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OnboardingColors.point,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: OnboardingColors.point,
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '다음',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
}

class _ProfileImagePicker extends StatelessWidget {
  const _ProfileImagePicker({
    required this.imageBytes,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? imageBytes;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onPick,
            child: DashedCircleBorder(
              size: 100,
              color: OnboardingColors.textPlaceholder,
              child: ClipOval(
                child: Container(
                  color: Colors.white,
                  child: imageBytes != null
                      ? Image.memory(imageBytes!, fit: BoxFit.cover)
                      : const Icon(
                          Icons.person_add_alt_1,
                          size: 32,
                          color: OnboardingColors.textPlaceholder,
                        ),
                ),
              ),
            ),
          ),
          if (imageBytes != null)
            Positioned(
              right: 0,
              top: 0,
              child: Material(
                color: Colors.white,
                shape: CircleBorder(
                  side: BorderSide(color: OnboardingColors.border),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onRemove,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: OnboardingColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
