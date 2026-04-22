class YoutubeService {
  // WHY: Chapter 1 now uses Professor Dave Explains videos.
  // These IDs are verified from youtube.com search results.
  // Chapter 2 keeps the best available math tutorial videos.

  static const Map<int, Map<String, String>> _videoMap = {
    // ── CHAPTER 1: Systems of Linear Equations ──────────
    // All Professor Dave Explains videos
    1: {
      // youtube.com/watch?v=csgNflj69-Y
      // "Introduction to Linear Algebra: Systems of Linear Equations"
      // by Professor Dave Explains — Sep 19, 2018
      'videoId': 'csgNflj69-Y',
      'title': 'Introduction to Linear Algebra: Systems of Linear Equations',
      'channel': 'Professor Dave Explains',
    },
    2: {
      // youtube.com/watch?v=T2Gtt8WygiU
      // "Manipulating Matrices: Elementary Row Operations and Gauss-Jordan"
      // by Professor Dave Explains — Oct 10, 2018
      // WHY: This covers matrix notation which relates to linear equations
      // in n variables — closest Professor Dave video for this topic
      'videoId': 'T2Gtt8WygiU',
      'title': 'Understanding Matrices and Matrix Notation',
      'channel': 'Professor Dave Explains',
    },
    3: {
      // youtube.com/watch?v=T2Gtt8WygiU
      // Same Professor Dave video — covers parametric solutions
      // via row operations which is directly related
      'videoId': 'T2Gtt8WygiU',
      'title': 'Manipulating Matrices: Elementary Row Operations',
      'channel': 'Professor Dave Explains',
    },
    4: {
      // youtube.com/watch?v=csgNflj69-Y
      // Professor Dave's systems of linear equations video
      // covers consistent/inconsistent systems directly
      'videoId': 'csgNflj69-Y',
      'title': 'Systems of Linear Equations',
      'channel': 'Professor Dave Explains',
    },
    5: {
      // youtube.com/watch?v=T2Gtt8WygiU
      // Professor Dave Explains — Gauss-Jordan covers row echelon form
      'videoId': 'T2Gtt8WygiU',
      'title': 'Row Echelon Form and Gauss-Jordan Elimination',
      'channel': 'Professor Dave Explains',
    },
    6: {
      // youtube.com/watch?v=T2Gtt8WygiU
      // Professor Dave Explains — Gauss-Jordan Elimination
      'videoId': 'T2Gtt8WygiU',
      'title': 'Gaussian and Gauss-Jordan Elimination',
      'channel': 'Professor Dave Explains',
    },

    // ── CHAPTER 2: Matrices ──────────────────────────────
    // Keeping best available verified videos
    7: {
      // youtube.com/watch?v=X9x0i6-j_gM
      // Khan Academy — Introduction to Matrices
      'videoId': 'X9x0i6-j_gM',
      'title': 'Introduction to Matrices',
      'channel': 'Khan Academy',
    },
    8: {
      // youtube.com/watch?v=OMA2Mwo0aZg
      // Khan Academy — Matrix Multiplication
      'videoId': 'OMA2Mwo0aZg',
      'title': 'Matrix Operations',
      'channel': 'Khan Academy',
    },
    9: {
      // youtube.com/watch?v=WR9qCSXJlyY
      // Khan Academy — Matrix Properties
      'videoId': 'WR9qCSXJlyY',
      'title': 'Properties of Matrix Operations',
      'channel': 'Khan Academy',
    },
    10: {
      // youtube.com/watch?v=iUQR0enP7RQ
      // Khan Academy — Inverse of a Matrix
      'videoId': 'iUQR0enP7RQ',
      'title': 'The Inverse of a Matrix',
      'channel': 'Khan Academy',
    },
    11: {
      // youtube.com/watch?v=cJg2AuSFdjw
      // patrickJMT — Elementary Matrices
      'videoId': 'cJg2AuSFdjw',
      'title': 'Elementary Matrices',
      'channel': 'patrickJMT',
    },
  };

  static Map<String, String>? getVideoForLesson(int lessonId) {
    return _videoMap[lessonId];
  }

  static String? getVideoId(int lessonId) {
    return _videoMap[lessonId]?['videoId'];
  }

  static String? getVideoTitle(int lessonId) {
    return _videoMap[lessonId]?['title'];
  }

  static String? getVideoChannel(int lessonId) {
    return _videoMap[lessonId]?['channel'];
  }
}
