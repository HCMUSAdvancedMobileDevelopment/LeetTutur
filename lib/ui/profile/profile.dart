import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:leet_tutur/generated/l10n.dart';
import 'package:leet_tutur/models/user.dart';
import 'package:leet_tutur/stores/user_store.dart';
import 'package:leet_tutur/ui/profile/widgets/profile_avatar.dart';
import 'package:leet_tutur/ui/profile/widgets/profile_info.dart';
import 'package:leet_tutur/widgets/error_page.dart';
import 'package:mobx/mobx.dart';
import 'package:recase/recase.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _userStore = GetIt.instance.get<UserStore>();

  @override
  void initState() {
    _userStore.getUserInfoAsync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.profile.titleCase),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            right: 8,
            left: 8,
            top: 8,
            bottom: 50,
          ),
          child: Observer(builder: (context) {
            switch (_userStore.userFuture?.status) {
              case FutureStatus.rejected:
                return const Center(
                  child: ErrorPage(),
                );
              case FutureStatus.fulfilled:
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      ProfileAvatar(
                        user: _userStore.userFuture?.value ?? User(),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Divider(
                          thickness: 2,
                        ),
                      ),
                      ProfileInfo(
                        user: _userStore.userFuture?.value ?? User(),
                      )
                    ],
                  ),
                );
              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          }),
        ),
      ),
    );
  }
}
