enum GitPlatform {
  github,
  gitee,
  unknown;

  static GitPlatform fromUrl(String url) {
    if (url.contains('github.com')) return GitPlatform.github;
    if (url.contains('gitee.com')) return GitPlatform.gitee;
    return GitPlatform.unknown;
  }
}