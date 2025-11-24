enum Screens {
  /* 
╔═══════════════════════╗
║     INITIAL ROUTES    ║
╚═══════════════════════╝
  */
  splash('/splash', 'Splash'),
  onboard('/onboard', 'Onboard'),

  /*
╔═════════════════╗
║   AUTH ROUTES   ║
╚═════════════════╝
 */

  signIn('/signIn', 'Sign In'),
  signUp('/signUp', 'Sign Up'),
  enhancedLogin('/enhanced-login', 'Enhanced Login'),

  /* 
╔═══════════════════════╗
║      HOME ROUTES      ║
╚═══════════════════════╝
  */

  home('/home', 'Home'),

  /* 
╔═══════════════════════╗
║    PROFILE ROUTES     ║
╚═══════════════════════╝
  */

  profile('/profile', 'Profile'),

  /* 
╔═══════════════════════════╗
║        OTHER ROUTES       ║
╚═══════════════════════════╝
  */

  story('/story', 'Story'),
  purchase('/purchase', 'Purchase');

  const Screens(this.path, this.name);
  final String path;
  final String name;
}
