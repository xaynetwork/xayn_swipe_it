import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';
import 'package:xayn_swipe_it_example/models/dog.dart';
import 'package:xayn_swipe_it_example/models/option.dart';
import 'package:xayn_swipe_it_example/repository/dog_repository.dart';
import 'package:xayn_swipe_it_example/utils.dart';
import 'package:xayn_swipe_it_example/widgets/background.dart';
import 'package:xayn_swipe_it_example/widgets/option_widget.dart';

class LikedDogs extends StatefulWidget {
  const LikedDogs({Key? key, required this.dogRepository}) : super(key: key);
  final DogRepository dogRepository;

  @override
  _LikedDogsState createState() => _LikedDogsState();
}

class _LikedDogsState extends State<LikedDogs> {
  DogRepository get repo => widget.dogRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Your fav doggos'),
        centerTitle: true,
      ),
      body: Background(
        isWideScreen: true,
        child: buildDogGridFutureBuilder(),
      ),
    );
  }

  FutureBuilder<List<Dog>> buildDogGridFutureBuilder() {
    return FutureBuilder<List<Dog>>(
        future: repo.getSavedDogs(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final dogs = snapshot.data!;
            if (dogs.isEmpty) {
              return Center(
                child: Text(
                  'You didn\'t like any doggo!',
                  style: Theme.of(context).textTheme.headline4,
                ),
              );
            }
            return buildDogGrid(dogs);
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  GridView buildDogGrid(List<Dog> dogs) {
    return GridView.builder(
      itemBuilder: (context, index) => buildSwipeWidget(
        key: Key(dogs[index].url),
        dog: dogs[index],
        child: Image.network(
          dogs[index].url,
          fit: BoxFit.cover,
        ),
      ),
      itemCount: dogs.length,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: 15,
      ),
    );
  }

  buildSwipeWidget({
    required Key? key,
    required Widget child,
    required Dog dog,
  }) {
    return Swipe<Option>(
      key: key,
      opensToPosition: 0.6,
      onOptionTap: (option) => onOptionTap(option, dog),
      onFling: (options) => options.first,
      child: child,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      optionsLeft: const [Option.share],
      optionsRight: const [Option.dislike],
      optionBuilder: (_, option, __, isSelected) =>
          optionWidget(option, isSelected, false),
    );
  }

  void onOptionTap(Option option, Dog dog) {
    switch (option) {
      case Option.dislike:
        repo.removeDog(dog);
        break;
      case Option.share:
        shareUrl(dog.url);
        break;
      default:
        break;
    }

    setState(() {});
  }
}
