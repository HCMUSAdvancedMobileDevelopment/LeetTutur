import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:leet_tutur/constants/route_constants.dart';
import 'package:leet_tutur/generated/l10n.dart';
import 'package:leet_tutur/stores/auth_store.dart';
import 'package:leet_tutur/stores/ws_store.dart';
import 'package:leet_tutur/ui/auth/widgets/logo_intro.dart';
import 'package:leet_tutur/widgets/text_input.dart';
import 'package:leet_tutur/widgets/text_password_input.dart';
import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';
import 'package:recase/recase.dart';
import 'package:validators/validators.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _authStore = GetIt.instance.get<AuthStore>();
  final _wsStore = GetIt.instance.get<WsStore>();
  final _logger = GetIt.instance.get<Logger>();
  final _googleSignIn = GetIt.instance.get<GoogleSignIn>();
  final _facebookAuth = GetIt.instance.get<FacebookAuth>();

  final _formKey = GlobalKey<FormState>();

  late final ReactionDisposer reactionDisposer;

  @override
  void initState() {
    _googleSignIn.signOut();
    _facebookAuth.logOut();

    _authStore.retrieveLocalLoginResponseAsync().then((value) {
      if (_authStore.authResponseFuture?.value?.tokens != null) {
        _logger.i("Detect tokens in local shared preferences. Auto login.");
        Navigator.pushNamed(context, RouteConstants.homeTabs);

        var user = _authStore.authResponseFuture?.value?.user;
        if (user != null) {
          _wsStore.loginWebSocket(user);
        }
      }
    }).onError((error, stackTrace) {
      _logger.e(
          "Can't get token from local shared preferences", error, stackTrace);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/geometry-bg.png"),
                fit: BoxFit.cover),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO AND INTRO
                const LogoIntro(),
                // USER INPUT
                Observer(
                  builder: (context) => Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: Column(children: [
                        const SizedBox(
                          height: 32,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                          child: TextInput(
                            hintText: S.current.enterMail,
                            initialValue: _authStore.email,
                            onChanged: (value) => {_authStore.email = value},
                            validator: (value) {
                              if (isNull(value) || !isEmail(value!)) {
                                return S.current.pleaseEnterCorrectEmailFormat;
                              }

                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                          child: TextPasswordInput(
                            hintText: S.current.enterPassword,
                            initialValue: _authStore.password,
                            onChanged: (value) => {_authStore.password = value},
                            validator: (value) {
                              if (isNull(value)) {
                                return S.current.pleaseEnterSomeValue;
                              }

                              return null;
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RichText(
                              textAlign: TextAlign.end,
                              text: TextSpan(
                                  text: S.current.forgotPassword,
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Navigate to forgot password
                                      Navigator.pushNamed(context,
                                          RouteConstants.forgotPassword);
                                    }),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                  onPressed: _handleLogin,
                                  child: Text(S.current.login.toUpperCase())),
                            ),
                          ],
                        )
                      ]),
                    ),
                  ),
                ),
                // OAuth2 authentication,
                Column(children: [
                  const SizedBox(height: 15),
                  Text(S.current.orWith),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              onPressed: _handleLoginWithGoogle,
                              icon: Image.asset(
                                "assets/images/google.png",
                              ),
                              iconSize: 50),
                          IconButton(
                              onPressed: _handleLoginWithFacebook,
                              icon: Image.asset(
                                "assets/images/facebook.png",
                              ),
                              iconSize: 50),
                        ]),
                  )
                ]),
                // Register
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 50),
                  Text(S.current.dontHaveAccount),
                  const SizedBox(width: 5),
                  RichText(
                    text: TextSpan(
                        text: S.current.register,
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(
                                context, RouteConstants.register);
                          }),
                  ),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        var cancelableOperation = CancelableOperation.fromFuture(
          _authStore.loginAsync(_authStore.email, _authStore.password),
        );

        cancelableOperation.then(
          (result) {
            // Connect web socket
            var user = result.user!;
            _wsStore.loginWebSocket(user);

            // Dismiss dialog
            Navigator.of(context, rootNavigator: true).pop();
            // Go to home
            Navigator.pushNamed(context, RouteConstants.homeTabs);
          },
        );

        showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext dialogContext) {
            var isLoginFailed = false;
            var errMessage = "";

            return StatefulBuilder(builder: (context, setDialogState) {
              cancelableOperation.then(
                (_) {},
                onError: (err, trace) {
                  setDialogState(() {
                    isLoginFailed = true;

                    var dioErr = err as DioError;
                    errMessage = dioErr.response?.data["message"];
                  });
                },
              );

              return AlertDialog(
                title: Center(child: Text(S.current.processing.titleCase)),
                content: Align(
                  heightFactor: 1,
                  alignment: Alignment.center,
                  child: !isLoginFailed
                      ? const CircularProgressIndicator()
                      : Text(errMessage),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(S.current.cancel.toUpperCase()),
                    onPressed: () {
                      if (cancelableOperation.isCompleted) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                      cancelableOperation.cancel();
                    },
                  ),
                ],
              );
            });
          },
        );
      } on DioError {
        rethrow;
      }
    }
  }

  _handleLoginWithGoogle() async {
    try {
      var signedAccount = await _googleSignIn.signIn();
      signedAccount?.authentication.then((value) async {
        await _authStore.loginWithGoogleAsync(value.accessToken ?? "");

        Navigator.pushNamed(context, RouteConstants.homeTabs);
      });
    } catch (error) {
      _logger.e(error);
    }
  }

  _handleLoginWithFacebook() async {
    try {
      final result = await _facebookAuth.login();
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!;
        await _authStore.loginWithFacebookAsync(accessToken.token);

        Navigator.pushNamed(context, RouteConstants.homeTabs);
      } else {
        _logger.e(result.status);
        _logger.e(result.message);
      }
    } catch (e) {
      _logger.e(e);
    }
  }
}
