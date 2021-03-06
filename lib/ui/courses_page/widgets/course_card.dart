import 'package:flutter/material.dart';
import 'package:leet_tutur/generated/l10n.dart';
import 'package:leet_tutur/models/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;

  final void Function(Course? course)? onTap;

  const CourseCard({Key? key, this.onTap, required this.course})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!(course);
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16/9,
                child: Image.network(
                  course.imageUrl ?? "",
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                course.name ?? "",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                course.description ?? "",
                style: Theme.of(context).textTheme.caption,
              ),
              Row(
                children: [
                  Text(course.getLevelName()),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    child: Text("·", style: TextStyle(fontSize: 30)),
                  ),
                  Text("${course.topics?.length ?? 0} ${S.current.lessons}")
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
