# Riverpod, freezed and Navigator 2.0 example

... how to use [riverpod](https://riverpod.dev/) and [freezed](https://github.com/rrousselGit/freezed) 
to simplify the use of Flutter [Navigator 2.0](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade).

Classic three-screen example [Home] => [Books] => [Book\*].

The example implements a simple login logic: ```Book screen, id=1``` and ```Book screen, id=3``` screens are not available without login.

## Running example on the web...

... is available [here](https://pavelpz.github.io/).


## To run the example on your computer

- clone the repository
- in ```examples\riverpod_navigator_example\``` subdirectory, execute following commands:
- ```flutter create .```
- ```flutter pub get```
- ```flutter pub run build_runner build --delete-conflicting-outputs```
- ```flutter run``` 

## Publish to the web

- run ```flutter build web --web-renderer html```
- copy the contents of the ```build/web/``` directory to the root directory of your web server
