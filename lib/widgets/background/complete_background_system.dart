import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as html;
import '../../cubits/background_cubit/background_cubit.dart';
import '../../cubits/content_cubit/content_cubit.dart';

class CompleteBackgroundSystem extends StatefulWidget {
  const CompleteBackgroundSystem({super.key});

  @override
  State<CompleteBackgroundSystem> createState() =>
      _CompleteBackgroundSystemState();
}

class _CompleteBackgroundSystemState extends State<CompleteBackgroundSystem> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundCubit, BackgroundCubitState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: _buildBackground(state),
        );
      },
    );
  }

  Widget _buildBackground(BackgroundCubitState state) {
    switch (state.runtimeType) {
      case PictureBackgroundAssetState:
        final picState = state as PictureBackgroundAssetState;
        return _AssetPictureBackground(
          key: ValueKey('asset-pic-${picState.assetPath}'),
          assetPath: picState.assetPath,
        );

      case PictureBackgroundNetworkState:
        final picState = state as PictureBackgroundNetworkState;
        return _NetworkPictureBackground(
          key: ValueKey('network-pic-${picState.networkUrl}'),
          networkUrl: picState.networkUrl,
        );

      case VideoBackgroundAssetState:
        final vidState = state as VideoBackgroundAssetState;
        return _VideoBackground(
          key: ValueKey('asset-vid-${vidState.assetPath}'),
          videoUrl: vidState.assetPath,
          isAsset: true,
        );

      case VideoBackgroundNetworkState:
        final vidState = state as VideoBackgroundNetworkState;
        return _VideoBackground(
          key: ValueKey('network-vid-${vidState.networkUrl}'),
          videoUrl: vidState.networkUrl,
          isAsset: false,
        );

      case BackgroundErrorState:
        final errorState = state as BackgroundErrorState;
        return _ErrorBackground(
          key: const ValueKey('error'),
          message: errorState.message,
        );

      default:
        return const _LoadingBackground(key: ValueKey('loading'));
    }
  }
}

// Asset Picture Background
class _AssetPictureBackground extends StatelessWidget {
  final String assetPath;

  const _AssetPictureBackground({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: BoxFit.cover,
          onError: (error, stackTrace) {
            debugPrint('Error loading asset image: $error');
          },
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.1),
              Colors.transparent,
              Colors.black.withOpacity(0.2),
            ],
          ),
        ),
      ),
    );
  }
}

// Network Picture Background with Content Integration
class _NetworkPictureBackground extends StatelessWidget {
  final String networkUrl;

  const _NetworkPictureBackground({super.key, required this.networkUrl});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContentCubit, ContentState>(
      builder: (context, contentState) {
        String imageUrl = networkUrl;

        // Get current picture from content if available
        if (contentState is ContentLoaded) {
          final currentPicture = context
              .read<ContentCubit>()
              .getCurrentPicture();
          imageUrl = currentPicture.url;
        }

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              onError: (error, stackTrace) {
                debugPrint('Error loading network image: $error');
              },
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Video Background with Content Integration
class _VideoBackground extends StatefulWidget {
  final String videoUrl;
  final bool isAsset;

  const _VideoBackground({
    super.key,
    required this.videoUrl,
    this.isAsset = true,
  });

  @override
  State<_VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<_VideoBackground> {
  late String _viewType;
  html.HTMLVideoElement? _videoElement;
  bool _isVideoInitialized = false;
  bool _hasError = false;
  String _currentVideoUrl = '';

  @override
  void initState() {
    super.initState();
    _viewType = 'video-bg-${DateTime.now().millisecondsSinceEpoch}';
    _currentVideoUrl = widget.videoUrl;
    _initializeVideo();
  }

  @override
  void didUpdateWidget(_VideoBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _updateVideoSource(widget.videoUrl);
    }
  }

  void _initializeVideo() {
    if (!kIsWeb) return;

    try {
      _videoElement = html.HTMLVideoElement();
      _setupVideoElement();
      _registerPlatformView();
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      debugPrint('Video initialization error: $e');
    }
  }

  void _setupVideoElement() {
    if (_videoElement == null) return;

    _videoElement!
      ..src = _currentVideoUrl
      ..autoplay = true
      ..loop = true
      ..muted = true
      ..preload = 'auto'
      ..setAttribute('playsinline', 'true')
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.left = '0';

    _videoElement!.onCanPlay.listen((_) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _hasError = false;
        });
      }
      try {
        _videoElement!.play();
      } on Exception catch (e) {
        debugPrint('Video play error: $e');
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      }
      // _videoElement!.play().catchError((error) {
      //   debugPrint('Video play error: $error');
      //   if (mounted) {
      //     setState(() {
      //       _hasError = true;
      //     });
      //   }
      // });
    });

    _videoElement!.onError.listen((_) {
      debugPrint('Video error: ${_videoElement!.error?.message}');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    });
  }

  void _registerPlatformView() {
    ui.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _videoElement!,
    );
  }

  void _updateVideoSource(String newVideoUrl) {
    if (_videoElement == null) return;

    _currentVideoUrl = newVideoUrl;
    _videoElement!.src = newVideoUrl;
    _videoElement!.load();

    setState(() {
      _isVideoInitialized = false;
      _hasError = false;
    });
  }

  @override
  void dispose() {
    _videoElement?.pause();
    _videoElement?.removeAttribute('src');
    _videoElement = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get current video from content if available
    return BlocBuilder<ContentCubit, ContentState>(
      builder: (context, contentState) {
        // Update video source if content changes
        if (contentState is ContentLoaded && !widget.isAsset) {
          final currentVideo = context.read<ContentCubit>().getCurrentVideo();
          if (currentVideo.url != _currentVideoUrl) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateVideoSource(currentVideo.url);
            });
          }
        }

        if (!kIsWeb) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: Text(
                'Video backgrounds are only supported on web',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (_hasError) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load video',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            // Video element
            Positioned.fill(child: HtmlElementView(viewType: _viewType)),

            // Subtle overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),

            // Loading indicator
            if (!_isVideoInitialized)
              Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading video...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// Loading Background
class _LoadingBackground extends StatelessWidget {
  const _LoadingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.black,
            Colors.pink.withOpacity(0.1),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Loading background...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// Error Background
class _ErrorBackground extends StatelessWidget {
  final String message;

  const _ErrorBackground({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.withOpacity(0.1),
            Colors.black,
            Colors.red.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Background Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Background Switch Button with Content Integration
class EnhancedBackgroundSwitchButton extends StatefulWidget {
  const EnhancedBackgroundSwitchButton({super.key});

  @override
  State<EnhancedBackgroundSwitchButton> createState() =>
      _EnhancedBackgroundSwitchButtonState();
}

class _EnhancedBackgroundSwitchButtonState
    extends State<EnhancedBackgroundSwitchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePress() async {
    await _animationController.forward();

    // Get current content and switch backgrounds
    final contentCubit = context.read<ContentCubit>();
    final backgroundCubit = context.read<BackgroundCubit>();

    if (contentCubit.currentContent != null) {
      if (backgroundCubit.isPicture) {
        // Switch to video
        final currentVideo = contentCubit.getCurrentVideo();
        backgroundCubit.setNetworkResource(currentVideo.url, true);
      } else {
        // Switch to picture
        final currentPicture = contentCubit.getCurrentPicture();
        backgroundCubit.setNetworkResource(currentPicture.url, false);
      }
    } else {
      // Fallback to toggle between defaults
      backgroundCubit.toggleMediaType();
    }

    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonSize = screenSize.shortestSide * 0.08;
    final clampedSize = buttonSize.clamp(35.0, 50.0);

    return BlocBuilder<BackgroundCubit, BackgroundCubitState>(
      builder: (context, state) {
        final backgroundCubit = context.read<BackgroundCubit>();
        final isVideo = !backgroundCubit.isPicture;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: clampedSize,
                  height: clampedSize,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isVideo
                          ? Colors.red.withOpacity(0.5)
                          : Colors.blue.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isVideo ? Colors.red : Colors.blue).withOpacity(
                          0.3,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: _handlePress,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isVideo ? Icons.videocam : Icons.photo_camera,
                            key: ValueKey(isVideo),
                            color: Colors.white,
                            size: clampedSize * 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
