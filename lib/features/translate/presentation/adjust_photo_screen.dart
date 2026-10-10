import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../../core/theme/app_theme.dart';

class AdjustPhotoScreen extends StatefulWidget {
  final String imagePath;

  const AdjustPhotoScreen({super.key, required this.imagePath});

  @override
  State<AdjustPhotoScreen> createState() => _AdjustPhotoScreenState();
}

enum _AspectPreset {
  free('Free', null),
  sq('1:1', 1.0),
  p34('3:4', 3.0 / 4.0),
  p43('4:3', 4.0 / 3.0),
  p169('16:9', 16.0 / 9.0);

  final String label;
  final double? ratio;
  const _AspectPreset(this.label, this.ratio);
}

enum _DragHandle { none, center, topLeft, topRight, bottomLeft, bottomRight }

class _AdjustPhotoScreenState extends State<AdjustPhotoScreen> {
  _AspectPreset _selectedPreset = _AspectPreset.free;
  int _rotationQuarterTurns = 0; // 0, 1, 2, 3

  // Image intrinsic size
  Size _rawImageSize = Size.zero;
  bool _imageLoaded = false;
  bool _isProcessing = false;

  // Viewport / Cropping Rect in container coordinates
  Rect? _cropRect;
  Rect _imageRenderRect = Rect.zero;

  // Drag tracking
  _DragHandle _activeHandle = _DragHandle.none;
  Offset _dragStartOffset = Offset.zero;
  Rect _initialCropRect = Rect.zero;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    try {
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      final decoded = await decodeImageFromList(bytes);
      if (mounted) {
        setState(() {
          _rawImageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
          _imageLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _imageLoaded = true);
      }
    }
  }

  void _reset() {
    setState(() {
      _rotationQuarterTurns = 0;
      _selectedPreset = _AspectPreset.free;
      if (_imageRenderRect != Rect.zero) {
        _cropRect = _imageRenderRect.deflate(12);
      }
    });
  }

  void _rotate(int deltaTurns) {
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + deltaTurns) % 4;
      if (_rotationQuarterTurns < 0) _rotationQuarterTurns += 4;
      // Invalidate crop rect so it re-computes on next build
      _cropRect = null;
    });
  }

  void _selectPreset(_AspectPreset preset) {
    setState(() {
      _selectedPreset = preset;
      if (_cropRect != null && _imageRenderRect != Rect.zero) {
        if (preset.ratio == null) return;
        _cropRect = _fitCropRectToRatio(_cropRect!, preset.ratio!, _imageRenderRect);
      }
    });
  }

  Rect _fitCropRectToRatio(Rect current, double targetRatio, Rect bounds) {
    final center = current.center;
    double newW = current.width;
    double newH = newW / targetRatio;

    if (newH > bounds.height) {
      newH = bounds.height;
      newW = newH * targetRatio;
    }
    if (newW > bounds.width) {
      newW = bounds.width;
      newH = newW / targetRatio;
    }

    Rect r = Rect.fromCenter(center: center, width: newW, height: newH);
    // Keep in bounds
    if (r.left < bounds.left) r = r.translate(bounds.left - r.left, 0);
    if (r.right > bounds.right) r = r.translate(bounds.right - r.right, 0);
    if (r.top < bounds.top) r = r.translate(0, bounds.top - r.top);
    if (r.bottom > bounds.bottom) r = r.translate(0, bounds.bottom - r.bottom);
    return r;
  }

  Future<void> _onScanPressed() async {
    if (_isProcessing || _cropRect == null || _imageRenderRect == Rect.zero) return;

    setState(() => _isProcessing = true);

    try {
      final crop = _cropRect!;
      final bounds = _imageRenderRect;

      // Normalized crop coordinate relative to the visible rotated image
      final normLeft = ((crop.left - bounds.left) / bounds.width).clamp(0.0, 1.0);
      final normTop = ((crop.top - bounds.top) / bounds.height).clamp(0.0, 1.0);
      final normWidth = (crop.width / bounds.width).clamp(0.01, 1.0 - normLeft);
      final normHeight = (crop.height / bounds.height).clamp(0.01, 1.0 - normTop);

      // Perform crop in background via image package
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      var imgObj = img.decodeImage(bytes);

      if (imgObj == null) {
        if (mounted) Navigator.pop(context, widget.imagePath);
        return;
      }

      // Apply rotation if needed
      if (_rotationQuarterTurns != 0) {
        final degrees = _rotationQuarterTurns * 90;
        imgObj = img.copyRotate(imgObj, angle: degrees);
      }

      // Compute pixel coordinates
      final cropX = (normLeft * imgObj.width).round().clamp(0, imgObj.width - 1);
      final cropY = (normTop * imgObj.height).round().clamp(0, imgObj.height - 1);
      final cropW = (normWidth * imgObj.width).round().clamp(1, imgObj.width - cropX);
      final cropH = (normHeight * imgObj.height).round().clamp(1, imgObj.height - cropY);

      final croppedImg = img.copyCrop(
        imgObj,
        x: cropX,
        y: cropY,
        width: cropW,
        height: cropH,
      );

      final tempDir = Directory.systemTemp;
      final outPath = '${tempDir.path}/scan_crop_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outBytes = img.encodeJpg(croppedImg, quality: 92);
      await File(outPath).writeAsBytes(outBytes);

      if (mounted) {
        Navigator.pop(context, outPath);
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context, widget.imagePath);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // Touch handling
  void _onPanStart(DragStartDetails details) {
    if (_cropRect == null) return;
    final pos = details.localPosition;
    const hitRadius = 38.0;

    final tl = _cropRect!.topLeft;
    final tr = _cropRect!.topRight;
    final bl = _cropRect!.bottomLeft;
    final br = _cropRect!.bottomRight;

    if ((pos - tl).distance <= hitRadius) {
      _activeHandle = _DragHandle.topLeft;
    } else if ((pos - tr).distance <= hitRadius) {
      _activeHandle = _DragHandle.topRight;
    } else if ((pos - bl).distance <= hitRadius) {
      _activeHandle = _DragHandle.bottomLeft;
    } else if ((pos - br).distance <= hitRadius) {
      _activeHandle = _DragHandle.bottomRight;
    } else if (_cropRect!.contains(pos)) {
      _activeHandle = _DragHandle.center;
    } else {
      _activeHandle = _DragHandle.none;
    }

    _dragStartOffset = pos;
    _initialCropRect = _cropRect!;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeHandle == _DragHandle.none || _cropRect == null) return;
    final delta = details.localPosition - _dragStartOffset;
    final bounds = _imageRenderRect;

    if (_activeHandle == _DragHandle.center) {
      // Pan the box
      var newRect = _initialCropRect.shift(delta);
      if (newRect.left < bounds.left) newRect = newRect.translate(bounds.left - newRect.left, 0);
      if (newRect.right > bounds.right) newRect = newRect.translate(bounds.right - newRect.right, 0);
      if (newRect.top < bounds.top) newRect = newRect.translate(0, bounds.top - newRect.top);
      if (newRect.bottom > bounds.bottom) newRect = newRect.translate(0, bounds.bottom - newRect.bottom);
      setState(() => _cropRect = newRect);
      return;
    }

    // Resize corners
    double left = _initialCropRect.left;
    double top = _initialCropRect.top;
    double right = _initialCropRect.right;
    double bottom = _initialCropRect.bottom;
    const minSize = 48.0;

    switch (_activeHandle) {
      case _DragHandle.topLeft:
        left = (_initialCropRect.left + delta.dx).clamp(bounds.left, right - minSize);
        top = (_initialCropRect.top + delta.dy).clamp(bounds.top, bottom - minSize);
        break;
      case _DragHandle.topRight:
        right = (_initialCropRect.right + delta.dx).clamp(left + minSize, bounds.right);
        top = (_initialCropRect.top + delta.dy).clamp(bounds.top, bottom - minSize);
        break;
      case _DragHandle.bottomLeft:
        left = (_initialCropRect.left + delta.dx).clamp(bounds.left, right - minSize);
        bottom = (_initialCropRect.bottom + delta.dy).clamp(top + minSize, bounds.bottom);
        break;
      case _DragHandle.bottomRight:
        right = (_initialCropRect.right + delta.dx).clamp(left + minSize, bounds.right);
        bottom = (_initialCropRect.bottom + delta.dy).clamp(top + minSize, bounds.bottom);
        break;
      default:
        break;
    }

    var candidate = Rect.fromLTRB(left, top, right, bottom);
    if (_selectedPreset.ratio != null) {
      candidate = _fitCropRectToRatio(candidate, _selectedPreset.ratio!, bounds);
    }
    setState(() => _cropRect = candidate);
  }

  void _onPanEnd(DragEndDetails details) {
    _activeHandle = _DragHandle.none;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F4),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top App Bar (Matching the screenshot)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Row(
                children: [
                  // Circular Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4E5E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF1E3A2F),
                        size: 20,
                      ),
                    ),
                  ),

                  // Center Title & Subtitle
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Adjust Photo',
                          style: AppTheme.serif(
                            20,
                            color: const Color(0xFF1E3A2F),
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Crop and adjust your photo',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF708578),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Reset Button Pill
                  GestureDetector(
                    onTap: _reset,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F4F0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E2DC)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF2E3D35)),
                          SizedBox(width: 4),
                          Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E3D35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // 2. Photo Viewport & Interactive Crop Frame
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2024),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (!_imageLoaded || _rawImageSize == Size.zero) {
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white70),
                          );
                        }

                        // Calculate effective image size given current rotation
                        final isRotated90 = _rotationQuarterTurns % 2 != 0;
                        final curW = isRotated90 ? _rawImageSize.height : _rawImageSize.width;
                        final curH = isRotated90 ? _rawImageSize.width : _rawImageSize.height;

                        // Fitted rect of image inside the container
                        final containerW = constraints.maxWidth;
                        final containerH = constraints.maxHeight;

                        final scaleW = containerW / curW;
                        final scaleH = containerH / curH;
                        final scale = math.min(scaleW, scaleH);

                        final renderW = curW * scale;
                        final renderH = curH * scale;
                        final renderLeft = (containerW - renderW) / 2;
                        final renderTop = (containerH - renderH) / 2;

                        _imageRenderRect = Rect.fromLTWH(renderLeft, renderTop, renderW, renderH);

                        // Initialize or clamp crop rect
                        if (_cropRect == null) {
                          _cropRect = _imageRenderRect.deflate(10);
                          if (_selectedPreset.ratio != null) {
                            _cropRect = _fitCropRectToRatio(
                              _cropRect!,
                              _selectedPreset.ratio!,
                              _imageRenderRect,
                            );
                          }
                        }

                        return GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Rotated Image Rendered
                              Center(
                                child: RotatedBox(
                                  quarterTurns: _rotationQuarterTurns,
                                  child: Image.file(
                                    File(widget.imagePath),
                                    width: isRotated90 ? renderH : renderW,
                                    height: isRotated90 ? renderW : renderH,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),

                              // Interactive Overlay with 3x3 Grid & Corner Brackets
                              if (_cropRect != null)
                                CustomPaint(
                                  painter: _CropOverlayPainter(
                                    cropRect: _cropRect!,
                                    imageRect: _imageRenderRect,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 3. Aspect Ratio Presets Toolbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _AspectPreset.values.map((preset) {
                  final isSelected = _selectedPreset == preset;
                  return _PresetItem(
                    preset: preset,
                    isSelected: isSelected,
                    onTap: () => _selectPreset(preset),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFEBE8E1)),
            ),

            const SizedBox(height: 10),

            // 4. Rotation Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _rotate(-1),
                      behavior: HitTestBehavior.opaque,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CircleButton(icon: Icons.rotate_left_rounded),
                          SizedBox(height: 4),
                          Text(
                            'Rotate Left',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3A4B41),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: const Color(0xFFE5E2DC),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _rotate(1),
                      behavior: HitTestBehavior.opaque,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CircleButton(icon: Icons.rotate_right_rounded),
                          SizedBox(height: 4),
                          Text(
                            'Rotate Right',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3A4B41),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 5. Bottom Action Button: "Save" (or Save / Scan as depicted in mockup)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD49598), // Soft rosy blush
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isProcessing ? null : _onScanPressed,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetItem extends StatelessWidget {
  final _AspectPreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetItem({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 54,
        height: 58,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3B6B8) : const Color(0xFFFAF9F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFE3B6B8) : const Color(0xFFEAE8E2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPresetIcon(preset, isSelected),
            const SizedBox(height: 4),
            Text(
              preset.label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? const Color(0xFF2C1C1D) : const Color(0xFF5C6B61),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetIcon(_AspectPreset p, bool selected) {
    final color = selected ? const Color(0xFF2C1C1D) : const Color(0xFF5C6B61);
    switch (p) {
      case _AspectPreset.free:
        return Icon(Icons.crop_free_rounded, size: 16, color: color);
      case _AspectPreset.sq:
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case _AspectPreset.p34:
        return Container(
          width: 11,
          height: 15,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case _AspectPreset.p43:
        return Container(
          width: 15,
          height: 11,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case _AspectPreset.p169:
        return Container(
          width: 17,
          height: 10,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(2),
          ),
        );
    }
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;

  const _CircleButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: Color(0xFFF1EFEB),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: const Color(0xFF2E3D35),
        size: 20,
      ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final Rect imageRect;

  _CropOverlayPainter({required this.cropRect, required this.imageRect});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dimmed background outside crop rect
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.52);

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, bgPaint);

    // 2. 3x3 Grid Lines inside crop rect
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final cellW = cropRect.width / 3.0;
    final cellH = cropRect.height / 3.0;

    // Vertical grid lines
    canvas.drawLine(
      Offset(cropRect.left + cellW, cropRect.top),
      Offset(cropRect.left + cellW, cropRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left + cellW * 2, cropRect.top),
      Offset(cropRect.left + cellW * 2, cropRect.bottom),
      gridPaint,
    );

    // Horizontal grid lines
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + cellH),
      Offset(cropRect.right, cropRect.top + cellH),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + cellH * 2),
      Offset(cropRect.right, cropRect.top + cellH * 2),
      gridPaint,
    );

    // 3. Thick White Corner Brackets: ⌜ ⌝ ⌞ ⌟
    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const armLen = 18.0;

    // Top-Left ⌜
    final tlPath = Path()
      ..moveTo(cropRect.left, cropRect.top + armLen)
      ..lineTo(cropRect.left, cropRect.top)
      ..lineTo(cropRect.left + armLen, cropRect.top);
    canvas.drawPath(tlPath, cornerPaint);

    // Top-Right ⌝
    final trPath = Path()
      ..moveTo(cropRect.right - armLen, cropRect.top)
      ..lineTo(cropRect.right, cropRect.top)
      ..lineTo(cropRect.right, cropRect.top + armLen);
    canvas.drawPath(trPath, cornerPaint);

    // Bottom-Left ⌞
    final blPath = Path()
      ..moveTo(cropRect.left, cropRect.bottom - armLen)
      ..lineTo(cropRect.left, cropRect.bottom)
      ..lineTo(cropRect.left + armLen, cropRect.bottom);
    canvas.drawPath(blPath, cornerPaint);

    // Bottom-Right ⌟
    final brPath = Path()
      ..moveTo(cropRect.right - armLen, cropRect.bottom)
      ..lineTo(cropRect.right, cropRect.bottom)
      ..lineTo(cropRect.right, cropRect.bottom - armLen);
    canvas.drawPath(brPath, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect || oldDelegate.imageRect != imageRect;
  }
}

