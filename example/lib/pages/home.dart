import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';
import 'package:xayn_swipe_it_example/pages/liked_dogs.dart';
import 'package:xayn_swipe_it_example/repository/dog_repository.dart';
import 'package:xayn_swipe_it_example/utils.dart';
import 'package:xayn_swipe_it_example/widgets/background.dart';
import 'package:xayn_swipe_it_example/widgets/option_widget.dart';

import '../models/dog.dart';
import '../models/option.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.dogRepository}) : super(key: key);
  final DogRepository dogRepository;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DogRepository get repo => widget.dogRepository;

  SwipeController<Option>? _swipeController;
  Future<Dog>? dogFuture;
  Dog? dog;

  @override
  void initState() {
    super.initState();
    dogFuture = repo.fetchDog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Swipe my doggo!'),
        centerTitle: true,
      ),
      body: Background(
        child: dogFuture == null
            ? const SizedBox.shrink()
            : buildDogFutureBuilder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: buildFloatingActionButtons(context),
    );
  }

  FutureBuilder<Dog> buildDogFutureBuilder() {
    return FutureBuilder<Dog>(
        future: dogFuture!,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            dog = snapshot.data!;
            return buildSwipeWidget(
              child: Image.network(
                dog!.url,
                fit: BoxFit.cover,
              ),
            );
          }
          return const SizedBox.shrink();
        });
  }

  Column buildFloatingActionButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        FloatingActionButton(
          heroTag: 'skip',
          onPressed: () => setState(() {
            dogFuture = repo.fetchDog();
          }),
          child: const Icon(Icons.refresh),
          backgroundColor: Colors.teal,
        ),
        const SizedBox(height: 5),
        FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LikedDogs(
                dogRepository: repo,
              ),
            ),
          ),
          child: const Icon(Icons.bookmark),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  buildSwipeWidget({
    required Widget child,
  }) async {
    return Swipe<Option>(
      key: Key(dog.toString()),
      opensToPosition: 0.6,
      onController: (controller) => _swipeController = controller,
      onOptionTap: onOptionTap,
      onFling: (options) => options.first,
      child: child,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      optionsLeft: (_swipeController?.isSelected(Option.dislike) ?? false)
          ? [Option.neutral, Option.share]
          : [Option.like, Option.share],
      optionsRight: (_swipeController?.isSelected(Option.like) ?? false)
          ? [Option.neutral, Option.skip]
          : [Option.dislike, Option.skip],
      optionBuilder: (_, option, __, isSelected) =>
          optionWidget(option, isSelected),
    );
  }

  void onOptionTap(Option option) async {
    switch (option) {
      case Option.neutral:
        _swipeController?.updateSelection(
            option: Option.dislike, isSelected: false);
        _swipeController?.updateSelection(
            option: Option.like, isSelected: false);
        await repo.removeDog(dog!);
        break;
      case Option.like:
        _swipeController?.updateSelection(option: option, isSelected: true);
        await repo.addDog(dog!);
        break;
      case Option.dislike:
        _swipeController?.updateSelection(option: option, isSelected: true);
        break;
      case Option.share:
        shareUrl(dog!.url);
        break;
      case Option.skip:
        setState(() {
          dogFuture = repo.fetchDog();
        });
        break;
    }

    setState(() {});
  }
}