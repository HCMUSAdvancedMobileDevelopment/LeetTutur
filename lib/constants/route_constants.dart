import 'package:flutter/material.dart';
import 'package:leet_tutur/generated/l10n.dart';
import 'package:leet_tutur/ui/chat_page/chat_page.dart';

import '../ui/auth/forgot_password.dart';
import '../ui/auth/login.dart';
import '../ui/auth/register.dart';
import '../ui/course_detail/course_detail.dart';
import '../ui/courses_page/courses_page.dart';
import '../ui/home_tabs/home_tabs.dart';
import '../ui/learn_history/learn_history.dart';
import '../ui/profile/profile.dart';
import '../ui/schedule_page/schedule_page.dart';
import '../ui/settings_page/settings_page.dart';
import '../ui/tutor_detail/tutor_detail.dart';
import '../ui/tutor_page/tuitor_page.dart';

class RouteConstants {
  static const login = "login";
  static const register = "register";
  static const forgotPassword = "forgot password";
  static const homeTabs = "home tabs";
  static const tutorDetail = "tutor detail";
  static const learnHistory = "learn history";
  static const courseDetail = "Course detail";
  static const profile = "Profile";

  static final routesMap = <String, WidgetBuilder>{
    login: (BuildContext context) => const Login(),
    register: (BuildContext context) => const Register(),
    forgotPassword: (BuildContext context) => const ForgotPassword(),
    homeTabs: (BuildContext context) => const HomeTabs(),
    tutorDetail: (BuildContext context) => const TutorDetail(),
    learnHistory: (BuildContext context) => const LearnHistory(),
    courseDetail: (BuildContext context) => const CourseDetail(),
    profile: (BuildContext context) => const Profile(),
  };

  static final bottomBarItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
        icon: const Icon(Icons.school), label: S.current.tutor),
    BottomNavigationBarItem(
        icon: const Icon(Icons.chat), label: S.current.chat),
    BottomNavigationBarItem(
        icon: const Icon(Icons.event_note), label: S.current.schedule),
    BottomNavigationBarItem(
        icon: const Icon(Icons.book), label: S.current.courses),
    BottomNavigationBarItem(
        icon: const Icon(Icons.settings), label: S.current.settings)
  ];

  static final tabScreens = <Widget>[
    const TutorPage(),
    const ChatPage(),
    const SchedulePage(),
    const CoursesPage(),
    const SettingsPage(),
  ];
}