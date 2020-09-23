import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
// Add these three variables to store the info
// retrieved from the FirebaseUser
String name;
String email;
String imageUrl;

Future<String> signInWithGoogle() async {
  await Firebase.initializeApp();

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult =
      await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  if (user != null) {
    assert(user.email != null);
    assert(user.displayName != null);
    assert(user.photoURL != null);

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', user.uid);
    await prefs.setString('name', user.displayName);
    await prefs.setString('email', user.email);
    await prefs.setString('imageUrl', user.photoURL);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);
    name = prefs.getString('name');
    email = prefs.getString('email');
    imageUrl = prefs.getString('imageUrl');
    if (name.contains(" ")) {
      name = name.substring(0, name.indexOf(" "));
    }

    print('signInWithGoogle succeeded: $user');

    return '$user';
  }

  return null;
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();
  var prefs = await SharedPreferences.getInstance();
  await prefs.remove('uid');
  await prefs.remove('name');
  await prefs.remove('email');
  await prefs.remove('imageUrl');
  print("User Signed Out");
}

autoLogin() async {
  var prefs = await SharedPreferences.getInstance();

  String _uid = prefs.getString('uid');
  //print("Autologin: "+_uid);
  return _uid.toString();
}

getDetails() async {
  var prefs = await SharedPreferences.getInstance();
  String fname = prefs.getString('name');
  String femail = prefs.getString('email');
  String fimageUrl = prefs.getString('imageUrl');
  String myName = fname.toString();
  String myEmail = femail.toString();
  String myImage = fimageUrl.toString();
  return [myName, myEmail, myImage];
}
