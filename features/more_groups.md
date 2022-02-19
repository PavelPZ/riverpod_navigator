# More TypedSegment roots

In a real application with many dozens of screens, it would not be practical to define typed-segments using one class (as *Segments* is).

Use the unique "unionKey" for the second and next segment group.

!!!! jsonNameSpace for ```@Freezed(unionKey: SecondGrp.jsonNameSpace)``` must start with an underscore. !!!!

!!!! There must be at least two factory constructors in one class !!!!

#### Full source code:

- [more_groups.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/more_groups.dart)