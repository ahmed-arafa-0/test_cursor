// // ignore_for_file: unused_field, avoid_print, dead_code

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:web/web.dart' as html;
// import 'dart:ui_web' as ui_web;
// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:csv/csv.dart';
// import 'package:intl/intl.dart';
// import 'package:google_fonts/google_fonts.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         textTheme: TextTheme(
//           displayLarge: GoogleFonts.dancingScript(),
//           displayMedium: GoogleFonts.rakkas(),
//           displaySmall: GoogleFonts.ebGaramond(),
//           bodyLarge: GoogleFonts.atma(),
//           bodyMedium: GoogleFonts.playpenSans(),
//           bodySmall: GoogleFonts.mynerve(),
//           headlineMedium: GoogleFonts.pacifico(),
//           headlineSmall: GoogleFonts.reemKufi(),
//           titleLarge: GoogleFonts.playpenSans(),
//           labelLarge: GoogleFonts.shadowsIntoLight(),
//         ),
//       ),
//       home: const VideoImageSwitcher(),
//     );
//   }
// }

// // Default content fallbacks
// class Defaults {
//   static final List<Map<String, String>> defaultQuotes = [
//     {
//       'Date': '2025-01-01',
//       'English Quote': 'You are amazing every single day. 🌟',
//       'Arabic Quote': 'أنتِ رائعة في كل يوم. 🌟',
//       'Greek Quote': 'Είσαι υπέροχη κάθε μέρα. 🌟',
//       'Italian Quote': 'Sei fantastica ogni giorno. 🌟',
//     },
//   ];

//   static final List<Map<String, String>> defaultMusic = [
//     {'Date': '2025-01-01', 'Name': 'default_song.mp3'},
//   ];

//   static final List<Map<String, String>> defaultPictures = [
//     {'Date': '2025-01-01', 'Name': 'default_bg.jpg'},
//   ];

//   static final List<Map<String, String>> defaultVideos = [
//     {'Date': '2025-01-01', 'Name': 'default_bg.mp4'},
//   ];

//   static final List<Map<String, String>> defaultSettings = [
//     {
//       'Date': '2025-01-01',
//       'Quotes': 'Yes',
//       'Music': 'Yes',
//       'Pic BG': 'Yes',
//       'Video BG': 'Yes',
//     },
//   ];
// }

// class VideoImageSwitcher extends StatefulWidget {
//   const VideoImageSwitcher({super.key});

//   @override
//   State<VideoImageSwitcher> createState() => _VideoImageSwitcherState();
// }

// class _VideoImageSwitcherState extends State<VideoImageSwitcher>
//     with TickerProviderStateMixin {
//   html.HTMLVideoElement? _videoElement;
//   bool _showVideo = true;
//   bool _pressed = false;
//   double _currentVideoTime = 0.0;
//   bool _videoInitialized = false;

//   // Language flags mapping
//   final Map<String, String> _languageFlags = {
//     'English': '🇺🇸',
//     'Arabic': '🇸🇦',
//     'Italian': '🇮🇹',
//     'Greek': '🇬🇷',
//   };

//   // Font mappings for each language
//   final Map<String, Map<String, TextStyle>> _languageFonts = {
//     'English': {
//       'title': GoogleFonts.dancingScript(
//         color: Colors.white,
//         fontSize: 22,
//         fontWeight: FontWeight.w300,
//       ),
//       'quote': GoogleFonts.atma(
//         color: Colors.white70,
//         fontSize: 18,
//         fontStyle: FontStyle.italic,
//       ),
//       'timer': GoogleFonts.pacifico(
//         color: Colors.white,
//         fontSize: 28,
//         fontWeight: FontWeight.bold,
//       ),
//       'units': GoogleFonts.pacifico(
//         color: Colors.white70,
//         fontSize: 12,
//         fontWeight: FontWeight.w300,
//       ),
//       'signature': GoogleFonts.shadowsIntoLight(
//         color: Colors.white60,
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//       ),
//     },
//     'Arabic': {
//       'title': GoogleFonts.rakkas(
//         color: Colors.white,
//         fontSize: 22,
//         fontWeight: FontWeight.w300,
//       ),
//       'quote': GoogleFonts.playpenSans(
//         color: Colors.white70,
//         fontSize: 18,
//         fontStyle: FontStyle.italic,
//       ),
//       'timer': GoogleFonts.reemKufi(
//         color: Colors.white,
//         fontSize: 28,
//         fontWeight: FontWeight.bold,
//       ),
//       'units': GoogleFonts.reemKufi(
//         color: Colors.white70,
//         fontSize: 12,
//         fontWeight: FontWeight.w300,
//       ),
//       'signature': GoogleFonts.shadowsIntoLight(
//         color: Colors.white60,
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//       ),
//     },
//     'Italian': {
//       'title': GoogleFonts.dancingScript(
//         color: Colors.white,
//         fontSize: 22,
//         fontWeight: FontWeight.w300,
//       ),
//       'quote': GoogleFonts.caveat(
//         color: Colors.white70,
//         fontSize: 18,
//         fontStyle: FontStyle.italic,
//       ),
//       'timer': GoogleFonts.pacifico(
//         color: Colors.white,
//         fontSize: 28,
//         fontWeight: FontWeight.bold,
//       ),
//       'units': GoogleFonts.pacifico(
//         color: Colors.white70,
//         fontSize: 12,
//         fontWeight: FontWeight.w300,
//       ),
//       'signature': GoogleFonts.shadowsIntoLight(
//         color: Colors.white60,
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//       ),
//     },
//     'Greek': {
//       'title': GoogleFonts.ebGaramond(
//         color: Colors.white,
//         fontSize: 22,
//         fontWeight: FontWeight.w300,
//       ),
//       'quote': GoogleFonts.mynerve(
//         color: Colors.white70,
//         fontSize: 18,
//         fontStyle: FontStyle.italic,
//       ),
//       'timer': GoogleFonts.playpenSans(
//         color: Colors.white,
//         fontSize: 28,
//         fontWeight: FontWeight.bold,
//       ),
//       'units': GoogleFonts.playpenSans(
//         color: Colors.white70,
//         fontSize: 12,
//         fontWeight: FontWeight.w300,
//       ),
//       'signature': GoogleFonts.shadowsIntoLight(
//         color: Colors.white60,
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//       ),
//     },
//   };

//   // Localized titles with emojis
//   final Map<String, String> _localizedTitles = {
//     'English': 'Counting down to Veuolla\'s Birthday 🎂',
//     'Arabic': 'العد التنازلي لعيد ميلاد فيولا 🎂',
//     'Italian': 'Conto alla rovescia per il compleanno di Veuolla 🎂',
//     'Greek': 'Αντίστροφη μέτρηση για τα γενέθλια της Veuolla 🎂',
//   };

//   // Localized time units with emojis
//   final Map<String, Map<String, String>> _localizedTimeUnits = {
//     'English': {
//       'days': 'Days 📅',
//       'hours': 'Hours ⏰',
//       'minutes': 'Minutes ⏱️',
//       'seconds': 'Seconds ⏲️',
//     },
//     'Arabic': {
//       'days': 'أيام 📅',
//       'hours': 'ساعات ⏰',
//       'minutes': 'دقائق ⏱️',
//       'seconds': 'ثواني ⏲️',
//     },
//     'Italian': {
//       'days': 'Giorni 📅',
//       'hours': 'Ore ⏰',
//       'minutes': 'Minuti ⏱️',
//       'seconds': 'Secondi ⏲️',
//     },
//     'Greek': {
//       'days': 'Μέρες 📅',
//       'hours': 'Ώρες ⏰',
//       'minutes': 'Λεπτά ⏱️',
//       'seconds': 'Δευτερόλεπτα ⏲️',
//     },
//   };

//   String _currentLanguage = 'English';

//   // Countdown variables
//   Duration _timeUntilBirthday = Duration.zero;
//   late Timer _countdownTimer;
//   final DateTime _birthdayDate = DateTime(2025, 9, 26);

//   // Music player variables
//   bool _isPlaying = false;
//   bool _showMusicPlayer = false;
//   bool _isMuted = false;
//   double _musicPosition = 0.3;
//   double _musicVolume = 0.8;
//   int _currentTrackIndex = 0;

//   // Animation controllers
//   late AnimationController _musicPlayerController;
//   late Animation<double> _musicPlayerAnimation;
//   late AnimationController _backgroundSwitchController;
//   late Animation<double> _backgroundSwitchAnimation;

//   // Google Sheets integration
//   final String _spreadsheetId = '1mxAn5hS4bk_bX3_dwFERS_vpgnMj3dgN0bec3TRXDtA';
//   final String _gidQuotes = '0';
//   final String _gidMusic = '191122548';
//   final String _gidPictures = '27390536';
//   final String _gidVideos = '1813209632';
//   final String _gidSettings = '1277996291';

//   List<Map<String, String>> _quotes = [];
//   List<Map<String, String>> _music = [];
//   List<Map<String, String>> _pictures = [];
//   List<Map<String, String>> _videos = [];
//   List<Map<String, String>> _settings = [];

//   bool _loading = true;
//   String _currentQuote = 'You are amazing every single day. 🌟';
//   String _currentBackgroundImage = 'assets/images/default_bg.jpg';
//   String _currentBackgroundVideo = 'videos/default_bg.mp4';
//   List<Map<String, String>> _playlist = [
//     {
//       'title': 'Birthday Melody 🎵',
//       'artist': 'Happy Orchestra 🎻',
//       'duration': '3:45',
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();

//     // Initialize animation controllers
//     _musicPlayerController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );

//     _musicPlayerAnimation = CurvedAnimation(
//       parent: _musicPlayerController,
//       curve: Curves.easeInOut,
//     );

//     // Background switch animation
//     _backgroundSwitchController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );

//     _backgroundSwitchAnimation = CurvedAnimation(
//       parent: _backgroundSwitchController,
//       curve: Curves.easeInOut,
//     );

//     // Initialize video first
//     _initializeVideo();

//     // Load data from Google Sheets
//     _loadAllData();

//     // Initialize and start the countdown timer
//     _updateCountdown();
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       _updateCountdown();
//     });
//   }

//   // ADDED: Update countdown method
//   void _updateCountdown() {
//     final now = DateTime.now();
//     final nextBirthday = DateTime(
//       _birthdayDate.year,
//       _birthdayDate.month,
//       _birthdayDate.day,
//     );
//     final difference = nextBirthday.difference(now);

//     if (mounted) {
//       setState(() {
//         _timeUntilBirthday = difference;
//       });
//     }
//   }

//   void _initializeVideo() {
//     if (kIsWeb && !_videoInitialized) {
//       _videoElement = html.HTMLVideoElement()
//         ..src = _currentBackgroundVideo
//         ..autoplay = true
//         ..loop = true
//         ..muted = true
//         ..setAttribute('playsinline', '')
//         ..style.objectFit = 'cover'
//         ..style.width = '100%'
//         ..style.height = '100%';

//       // Set current time if we have a saved position
//       if (_currentVideoTime > 0) {
//         _videoElement!.currentTime = _currentVideoTime;
//       }

//       // Register video element only once
//       try {
//         ui_web.platformViewRegistry.registerViewFactory(
//           'videoElement',
//           (int viewId) => _videoElement!,
//         );
//         _videoInitialized = true;
//       } catch (e) {
//         print('Video element registration error: $e');
//       }
//     }
//   }

//   void _updateVideoSource(String newVideoPath) {
//     if (kIsWeb && _videoElement != null) {
//       // Save current time before changing source
//       // _currentVideoTime = _videoElement!.currentTime ?? 0;
//       _currentVideoTime = _videoElement!.currentTime;
//       _videoElement!.src = newVideoPath;
//       _videoElement!.load();
//       if (_showVideo) {
//         _playVideo();
//       }
//     }
//   }

//   void _playVideo() {
//     if (kIsWeb && _videoElement != null) {
//       try {
//         // Set the current time before playing
//         if (_currentVideoTime > 0) {
//           _videoElement!.currentTime = _currentVideoTime;
//         }
//         // Use a small delay to ensure video is ready
//         Future.delayed(const Duration(milliseconds: 100), () {
//           if (_videoElement != null) {
//             _videoElement!.play();
//           }
//         });
//       } catch (error) {
//         print('Error playing video: $error');
//       }
//     }
//   }

//   // ADDED: Pause video method
//   void _pauseVideo() {
//     if (kIsWeb && _videoElement != null) {
//       try {
//         // Save current time before pausing
//         // _currentVideoTime = _videoElement!.currentTime ?? 0;
//         _currentVideoTime = _videoElement!.currentTime;

//         _videoElement!.pause();
//       } catch (e) {
//         print('Error pausing video: $e');
//       }
//     }
//   }

//   // Google Sheets integration methods
  // Future<List<Map<String, String>>> _fetchSheetByGid(String gid) async {
  //   try {
  //     final url =
  //         'https://docs.google.com/spreadsheets/d/$_spreadsheetId/export?format=csv&gid=$gid';
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode != 200) {
  //       return [];
  //     }

  //     final csvText = utf8.decode(response.bodyBytes);
  //     final rows = const CsvToListConverter(eol: '\n').convert(csvText);
  //     if (rows.isEmpty) return [];

  //     final headers = rows.first.map((h) => h.toString()).toList();
  //     final dataRows = rows.skip(1);

  //     return dataRows.map((row) {
  //       final map = <String, String>{};
  //       for (var i = 0; i < headers.length; i++) {
  //         map[headers[i]] = i < row.length ? row[i].toString() : '';
  //       }
  //       return map;
  //     }).toList();
  //   } catch (e) {
  //     return [];
  //   }
  // }

//   Future<void> _loadAllData() async {
//     try {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//       final q = await _fetchSheetByGid(_gidQuotes);
//       final m = await _fetchSheetByGid(_gidMusic);
//       final p = await _fetchSheetByGid(_gidPictures);
//       final v = await _fetchSheetByGid(_gidVideos);
//       final s = await _fetchSheetByGid(_gidSettings);

//       // Get today's rows if any
//       final qToday = q.where((row) => row['Date'] == today).toList();
//       final mToday = m.where((row) => row['Date'] == today).toList();
//       final pToday = p.where((row) => row['Date'] == today).toList();
//       final vToday = v.where((row) => row['Date'] == today).toList();
//       final sToday = s.where((row) => row['Date'] == today).toList();

//       // Use defaults when missing
//       if (sToday.isEmpty) {
//         // No settings row → all defaults
//         _quotes = Defaults.defaultQuotes;
//         _music = Defaults.defaultMusic;
//         _pictures = Defaults.defaultPictures;
//         _videos = Defaults.defaultVideos;
//         _settings = Defaults.defaultSettings;
//       } else {
//         // If settings row exists, apply logic per flag
//         final row = sToday.first;

//         // Quotes
//         if (qToday.isEmpty) {
//           _quotes = Defaults.defaultQuotes;
//         } else if (row['Quotes'] == 'Yes') {
//           _quotes = [...Defaults.defaultQuotes, ...qToday];
//         } else {
//           _quotes = qToday;
//         }

//         // Music
//         if (mToday.isEmpty) {
//           _music = Defaults.defaultMusic;
//         } else if (row['Music'] == 'Yes') {
//           _music = [...Defaults.defaultMusic, ...mToday];
//         } else {
//           _music = mToday;
//         }

//         // Pictures
//         if (pToday.isEmpty) {
//           _pictures = Defaults.defaultPictures;
//         } else if (row['Pic BG'] == 'Yes') {
//           _pictures = [...Defaults.defaultPictures, ...pToday];
//         } else {
//           _pictures = pToday;
//         }

//         // Videos
//         if (vToday.isEmpty) {
//           _videos = Defaults.defaultVideos;
//         } else if (row['Video BG'] == 'Yes') {
//           _videos = [...Defaults.defaultVideos, ...vToday];
//         } else {
//           _videos = vToday;
//         }

//         _settings = sToday;
//       }

//       // Set current content
//       if (_quotes.isNotEmpty) {
//         final randomQuote =
//             _quotes[DateTime.now().millisecondsSinceEpoch % _quotes.length];
//         _currentQuote = _getLocalizedQuote(randomQuote, _currentLanguage);
//       }

//       if (_pictures.isNotEmpty) {
//         final randomPic =
//             _pictures[DateTime.now().millisecondsSinceEpoch % _pictures.length];
//         _currentBackgroundImage = 'assets/images/${randomPic['Name']}';
//       }

//       if (_videos.isNotEmpty) {
//         final randomVideo =
//             _videos[DateTime.now().millisecondsSinceEpoch % _videos.length];
//         _currentBackgroundVideo = 'videos/${randomVideo['Name']}';
//         _updateVideoSource(_currentBackgroundVideo);
//       }

//       // Setup playlist from music
//       _playlist = _music
//           .map(
//             (track) => {
//               'title': track['Name']?.replaceAll('.mp3', '') ?? 'Unknown Track',
//               'artist': 'VAR Playlist',
//               'duration': '3:45',
//             },
//           )
//           .toList();

//       setState(() {
//         _loading = false;
//       });
//     } catch (e) {
//       // Fallback to defaults on error
//       _quotes = Defaults.defaultQuotes;
//       _music = Defaults.defaultMusic;
//       _pictures = Defaults.defaultPictures;
//       _videos = Defaults.defaultVideos;
//       _settings = Defaults.defaultSettings;

//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   // FIXED: Correct quote key mapping for Italian
//   String _getLocalizedQuote(Map<String, String> quote, String language) {
//     switch (language) {
//       case 'English':
//         return quote['English Quote'] ?? 'You are amazing every single day. 🌟';
//       case 'Arabic':
//         return quote['Arabic Quote'] ?? 'أنتِ رائعة في كل يوم. 🌟';
//       case 'Italian':
//         return quote['Italian Quote'] ?? 'Sei fantastica ogni giorno. 🌟';
//       case 'Greek':
//         return quote['Greek Quote'] ?? 'Είσαι υπέροχη κάθε μέρα. 🌟';
//       default:
//         return quote['English Quote'] ?? 'You are amazing every single day. 🌟';
//     }
//   }

//   String _getQuoteForCurrentLanguage() {
//     if (_quotes.isEmpty) return 'You are amazing every single day. 🌟';

//     final randomQuote =
//         _quotes[DateTime.now().millisecondsSinceEpoch % _quotes.length];
//     return _getLocalizedQuote(randomQuote, _currentLanguage);
//   }

//   @override
//   void dispose() {
//     _countdownTimer.cancel();
//     _musicPlayerController.dispose();
//     _backgroundSwitchController.dispose();

//     if (kIsWeb && _videoElement != null) {
//       _videoElement!.pause();
//       _videoElement!.src = '';
//       _videoElement!.removeAttribute('src');
//       _videoElement = null;
//     }
//     super.dispose();
//   }

//   // ADDED: Change language method
//   void _changeLanguage(String lang) {
//     if (!mounted) return;
//     setState(() {
//       _currentLanguage = lang;
//       // Update quote when language changes using correct key mapping
//       _currentQuote = _getQuoteForCurrentLanguage();
//     });
//   }

//   // ADDED: Music player methods
//   void _togglePlayPause() {
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   // ADDED: Next track method
//   void _nextTrack() {
//     setState(() {
//       _currentTrackIndex = (_currentTrackIndex + 1) % _playlist.length;
//     });
//   }

//   // ADDED: Previous track method
//   void _previousTrack() {
//     setState(() {
//       _currentTrackIndex = (_currentTrackIndex - 1) % _playlist.length;
//       if (_currentTrackIndex < 0) _currentTrackIndex = _playlist.length - 1;
//     });
//   }

//   void _toggleMusicPlayer() {
//     setState(() {
//       _showMusicPlayer = !_showMusicPlayer;
//       if (_showMusicPlayer) {
//         _musicPlayerController.forward();
//       } else {
//         _musicPlayerController.reverse();
//       }
//     });
//   }

//   void _toggleMute() {
//     setState(() {
//       _isMuted = !_isMuted;
//       if (_isMuted) {
//         _musicVolume = 0;
//       } else {
//         _musicVolume = 0.8;
//       }
//     });
//   }

//   // FIXED: Better video toggle with animation
//   void _toggleBackground() {
//     if (!mounted || !kIsWeb) return;

//     setState(() => _pressed = true);
//     Future.delayed(const Duration(milliseconds: 150), () {
//       if (mounted) setState(() => _pressed = false);
//     });

//     // Start background switch animation
//     _backgroundSwitchController.reset();
//     _backgroundSwitchController.forward();

//     if (_showVideo) {
//       // When switching from video to image, pause and save position
//       _pauseVideo();
//     } else {
//       // When switching from image to video, play from saved position
//       Future.delayed(const Duration(milliseconds: 200), () {
//         _playVideo();
//       });
//     }

//     setState(() {
//       _showVideo = !_showVideo;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     double buttonSize = MediaQuery.of(context).size.shortestSide * 0.1;
//     buttonSize = buttonSize.clamp(40.0, 60.0);

//     final currentTrack = _playlist[_currentTrackIndex];
//     final currentFonts = _languageFonts[_currentLanguage]!;

//     return Scaffold(
//       body: Stack(
//         children: [
//           // Video Layer with smooth animation
//           if (kIsWeb && _videoInitialized)
//             Positioned.fill(
//               child: FadeTransition(
//                 opacity: _backgroundSwitchAnimation,
//                 child: AnimatedOpacity(
//                   opacity: _showVideo ? 1.0 : 0.0,
//                   duration: const Duration(milliseconds: 800),
//                   curve: Curves.easeInOut,
//                   child: const HtmlElementView(viewType: 'videoElement'),
//                 ),
//               ),
//             ),

//           // Image Layer with smooth animation
//           Positioned.fill(
//             child: FadeTransition(
//               opacity: _backgroundSwitchAnimation,
//               child: AnimatedOpacity(
//                 opacity: _showVideo ? 0.0 : 1.0,
//                 duration: const Duration(milliseconds: 800),
//                 curve: Curves.easeInOut,
//                 child: Image.asset(
//                   _currentBackgroundImage,
//                   fit: BoxFit.cover,
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.height,
//                   errorBuilder: (context, error, stackTrace) => Image.asset(
//                     'assets/images/default_bg.jpg',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Enhanced Countdown Timer
//           Positioned.fill(
//             child: Center(
//               child: SingleChildScrollView(
//                 child: Container(
//                   constraints: BoxConstraints(
//                     maxWidth: MediaQuery.of(context).size.width * 0.9,
//                     maxHeight: MediaQuery.of(context).size.height * 0.8,
//                   ),
//                   margin: EdgeInsets.symmetric(
//                     horizontal: MediaQuery.of(context).size.width * 0.05,
//                     vertical: MediaQuery.of(context).size.height * 0.05,
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 25,
//                     horizontal: 30,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.7),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.5),
//                         blurRadius: 15,
//                         spreadRadius: 3,
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Title with custom font
//                       Text(
//                         _localizedTitles[_currentLanguage] ??
//                             'Counting down to Veuolla\'s Birthday 🎂',
//                         style: currentFonts['title']!.copyWith(
//                           fontSize: MediaQuery.of(context).size.width < 600
//                               ? 18
//                               : 22,
//                           height: 1.3,
//                           letterSpacing: 1.1,
//                         ),
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 25),

//                       // Timer units with responsive layout
//                       LayoutBuilder(
//                         builder: (context, constraints) {
//                           final isSmallScreen = constraints.maxWidth < 600;
//                           return Wrap(
//                             spacing: isSmallScreen ? 15 : 25,
//                             runSpacing: 20,
//                             alignment: WrapAlignment.spaceEvenly,
//                             children: [
//                               _TimeUnit(
//                                 value: _timeUntilBirthday.inDays,
//                                 label:
//                                     _localizedTimeUnits[_currentLanguage]!['days']!,
//                                 numberStyle: currentFonts['timer']!.copyWith(
//                                   fontSize: isSmallScreen ? 24 : 28,
//                                   shadows: const [
//                                     Shadow(
//                                       blurRadius: 8,
//                                       color: Colors.black,
//                                       offset: Offset(2, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 labelStyle: currentFonts['units']!.copyWith(
//                                   fontSize: isSmallScreen ? 10 : 12,
//                                 ),
//                               ),
//                               _TimeUnit(
//                                 value: _timeUntilBirthday.inHours.remainder(24),
//                                 label:
//                                     _localizedTimeUnits[_currentLanguage]!['hours']!,
//                                 numberStyle: currentFonts['timer']!.copyWith(
//                                   fontSize: isSmallScreen ? 24 : 28,
//                                   shadows: const [
//                                     Shadow(
//                                       blurRadius: 8,
//                                       color: Colors.black,
//                                       offset: Offset(2, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 labelStyle: currentFonts['units']!.copyWith(
//                                   fontSize: isSmallScreen ? 10 : 12,
//                                 ),
//                               ),
//                               _TimeUnit(
//                                 value: _timeUntilBirthday.inMinutes.remainder(
//                                   60,
//                                 ),
//                                 label:
//                                     _localizedTimeUnits[_currentLanguage]!['minutes']!,
//                                 numberStyle: currentFonts['timer']!.copyWith(
//                                   fontSize: isSmallScreen ? 24 : 28,
//                                   shadows: const [
//                                     Shadow(
//                                       blurRadius: 8,
//                                       color: Colors.black,
//                                       offset: Offset(2, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 labelStyle: currentFonts['units']!.copyWith(
//                                   fontSize: isSmallScreen ? 10 : 12,
//                                 ),
//                               ),
//                               _TimeUnit(
//                                 value: _timeUntilBirthday.inSeconds.remainder(
//                                   60,
//                                 ),
//                                 label:
//                                     _localizedTimeUnits[_currentLanguage]!['seconds']!,
//                                 numberStyle: currentFonts['timer']!.copyWith(
//                                   fontSize: isSmallScreen ? 24 : 28,
//                                   shadows: const [
//                                     Shadow(
//                                       blurRadius: 8,
//                                       color: Colors.black,
//                                       offset: Offset(2, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 labelStyle: currentFonts['units']!.copyWith(
//                                   fontSize: isSmallScreen ? 10 : 12,
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 30),

//                       // Quote with custom font and emoji support
//                       Text(
//                         _currentQuote,
//                         style: currentFonts['quote']!.copyWith(
//                           fontSize: MediaQuery.of(context).size.width < 600
//                               ? 16
//                               : 18,
//                           height: 1.4,
//                         ),
//                         textAlign: TextAlign.center,
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 20),

//                       // Signature with custom font
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: Text(
//                           '♈ AR',
//                           style: currentFonts['signature']!.copyWith(
//                             fontSize: MediaQuery.of(context).size.width < 600
//                                 ? 14
//                                 : 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Top-right buttons with responsive sizing
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 20,
//             right: 20,
//             child: Wrap(
//               spacing: 12,
//               children: [
//                 // Language dropdown
//                 Container(
//                   width: buttonSize,
//                   height: buttonSize,
//                   decoration: const BoxDecoration(
//                     color: Colors.black54,
//                     shape: BoxShape.circle,
//                   ),
//                   child: PopupMenuButton<String>(
//                     color: Colors.black87,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     onSelected: _changeLanguage,
//                     itemBuilder: (BuildContext context) {
//                       return _languageFlags.entries.map((entry) {
//                         return PopupMenuItem<String>(
//                           value: entry.key,
//                           child: SizedBox(
//                             width: 140,
//                             child: Row(
//                               children: [
//                                 Text(
//                                   entry.value,
//                                   style: const TextStyle(fontSize: 20),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Text(
//                                   entry.key,
//                                   style: const TextStyle(color: Colors.white),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }).toList();
//                     },
//                     child: Center(
//                       child: Text(
//                         _languageFlags[_currentLanguage]!,
//                         style: const TextStyle(fontSize: 20),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Toggle video/image button
//                 Material(
//                   color: Colors.transparent,
//                   child: AnimatedScale(
//                     scale: _pressed ? 0.85 : 1.0,
//                     duration: const Duration(milliseconds: 150),
//                     child: Container(
//                       width: buttonSize,
//                       height: buttonSize,
//                       decoration: const BoxDecoration(
//                         color: Colors.black54,
//                         shape: BoxShape.circle,
//                       ),
//                       child: IconButton(
//                         iconSize: buttonSize * 0.5,
//                         color: Colors.white,
//                         icon: Icon(_showVideo ? Icons.image : Icons.videocam),
//                         onPressed: _toggleBackground,
//                         tooltip: _showVideo
//                             ? 'Switch to Image'
//                             : 'Switch to Video',
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Music player toggle button
//                 Material(
//                   color: Colors.transparent,
//                   child: Container(
//                     width: buttonSize,
//                     height: buttonSize,
//                     decoration: BoxDecoration(
//                       color: Colors.black54,
//                       shape: BoxShape.circle,
//                       border: _showMusicPlayer
//                           ? Border.all(color: Colors.white, width: 2)
//                           : null,
//                     ),
//                     child: IconButton(
//                       iconSize: buttonSize * 0.5,
//                       color: Colors.white,
//                       icon: const Icon(Icons.music_note),
//                       onPressed: _toggleMusicPlayer,
//                       tooltip: 'Music Player',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Music Player
//           if (_showMusicPlayer)
//             Positioned(
//               bottom: 20,
//               left: 20,
//               right: 20,
//               child: Center(
//                 child: Container(
//                   constraints: BoxConstraints(
//                     maxWidth: MediaQuery.of(context).size.width * 0.9,
//                   ),
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.85),
//                     borderRadius: BorderRadius.circular(25),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.7),
//                         blurRadius: 15,
//                         spreadRadius: 3,
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Slider(
//                         value: _musicPosition,
//                         onChanged: (value) {
//                           setState(() {
//                             _musicPosition = value;
//                           });
//                         },
//                         activeColor: Colors.white,
//                         inactiveColor: Colors.white30,
//                       ),
//                       const SizedBox(height: 8),

//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   currentTrack['title']!,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 Text(
//                                   currentTrack['artist']!,
//                                   style: const TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 12,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           ),

//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.skip_previous,
//                                   color: Colors.white,
//                                   size: 22,
//                                 ),
//                                 onPressed: _previousTrack,
//                               ),
//                               const SizedBox(width: 4),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   shape: BoxShape.circle,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.3),
//                                       blurRadius: 6,
//                                       spreadRadius: 1,
//                                     ),
//                                   ],
//                                 ),
//                                 child: IconButton(
//                                   icon: Icon(
//                                     _isPlaying ? Icons.pause : Icons.play_arrow,
//                                     color: Colors.black,
//                                     size: 20,
//                                   ),
//                                   onPressed: _togglePlayPause,
//                                 ),
//                               ),
//                               const SizedBox(width: 4),
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.skip_next,
//                                   color: Colors.white,
//                                   size: 22,
//                                 ),
//                                 onPressed: _nextTrack,
//                               ),
//                             ],
//                           ),

//                           Expanded(
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 IconButton(
//                                   icon: Icon(
//                                     _isMuted
//                                         ? Icons.volume_off
//                                         : Icons.volume_up,
//                                     color: Colors.white70,
//                                     size: 18,
//                                   ),
//                                   onPressed: _toggleMute,
//                                   padding: EdgeInsets.zero,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Expanded(
//                                   child: Slider(
//                                     value: _musicVolume,
//                                     onChanged: (value) {
//                                       setState(() {
//                                         _musicVolume = value;
//                                         _isMuted = value == 0;
//                                       });
//                                     },
//                                     activeColor: Colors.white,
//                                     inactiveColor: Colors.white30,
//                                     min: 0.0,
//                                     max: 1.0,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _TimeUnit extends StatelessWidget {
//   final int value;
//   final String label;
//   final TextStyle numberStyle;
//   final TextStyle labelStyle;

//   const _TimeUnit({
//     required this.value,
//     required this.label,
//     required this.numberStyle,
//     required this.labelStyle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Number with custom font
//         Text(value.toString().padLeft(2, '0'), style: numberStyle),
//         const SizedBox(height: 6),
//         // Label with custom font and emoji
//         Text(label, style: labelStyle, textAlign: TextAlign.center),
//       ],
//     );
//   }
// }
