class LessonMock {
  final int courseId;
  final int moduleId;
  final int lessonId;
  final int siteId;
  final String title;
  final String mediaType;
  final String source;

  const LessonMock({
    required this.courseId,
    required this.siteId,
    required this.moduleId,
    required this.lessonId,
    required this.title,
    required this.mediaType,
    required this.source,
  });
}

final List<LessonMock> allLessonsMock = [
  LessonMock(
    siteId: 1556,
    courseId: 5275,
    moduleId: 22088,
    lessonId: 161285,
    title: "Guns N' Roses - Yesterdays",
    mediaType: 'panda',
    source:
        'https://player-vz-ade7c544-44f.tv.pandavideo.com.br/embed/?v=da2c8e41-273e-4f59-a2b7-f20a1653bbc7',
  ),

  LessonMock(
    siteId: 7,
    courseId: 64,
    moduleId: 97,
    lessonId: 621,
    title: 'Aula VoompTube',
    mediaType: 'voomptube',
    source:
        "481146415f1109115b47474340091c1c4a5c4647461d51561c404949006776007557667a0c555652474641560e405b52415657111f11475b565e56110911435f5247555c415e111f11505241414a7c5d110955525f40564e",
  ),

  LessonMock(
    siteId: 7,
    courseId: 21,
    moduleId: 37,
    lessonId: 87,
    title: 'Números e Operações',
    mediaType: 'iframe',
    source: "//mdstrm.com/embed/633c79691ccf9008354e2e17",
  ),
  LessonMock(
    siteId: 7,
    courseId: 21,
    moduleId: 38,
    lessonId: 91,
    title: 'Teoria dos Números',
    mediaType: 'youtube',
    source: "https://www.youtube.com/watch?v=0e1bgWE13-Y",
  ),
  LessonMock(
    siteId: 7,
    courseId: 21,
    moduleId: 38,
    lessonId: 91,
    title: 'Youtube Iframe',
    mediaType: 'iframe',
    source: "<iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/m98hOZK-Fkk?si=In9iWS5z2Qx5SZim\" title=\"YouTube video player\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" referrerpolicy=\"strict-origin-when-cross-origin\" allowfullscreen></iframe>",
  ),
  LessonMock(
    siteId: 7,
    courseId: 21,
    moduleId: 38,
    lessonId: 121,
    title: 'Aula vídeo Vimeo',
    mediaType: 'vimeo',
    source: "https://vimeo.com/988384403",
  ),
  LessonMock(
    siteId: 9,
    courseId: 9,
    moduleId: 9,
    lessonId: 9,
    title: 'Aula vídeo Mp3',
    mediaType: 'local',
    source: "https://img-9gag-fun.9cache.com/photo/avyDLx5_460svav1.mp4",
  ),
];
