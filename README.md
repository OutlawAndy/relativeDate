relativeDate
============

```relativeDate``` is an Angular.js module containing one service, injectable by the same name.

Replaces iso-formated, date-time stamps with auto-updating, relative time labels

eg. *"just now"*, *"about 1 minute ago"*, or *"yesterday"*

checkout the [Demo](http://outlawandy.github.io/relativeDate/) to see it in action.


available through ```bower```

    bower install angular-relative


## Usage

first declare ```relativeDate``` as a dependency of your module

    angular.module("myApp",["relativeDate"])

Now you may inject the included service, ```relativeDate``` into your controllers and directives.

```relativeDate``` has one method, ```set``` which takes the following parameters.

1. *(required)* the datetime stamp to be used. *must be in iso-format*
2. *(required)* a callback function that will be called with one argument: the relative-date string calculated by the service
3. *(optional)* a format string to override the default. (more on this later)
example


    relativeDate.set( isoTime, function(relativeDate) {
      $scope.modelObject.relTime = relativeDate;
    });

Your callback will be called once immediately, and again every 60 seconds.
Angular's 2-way databinding will take care of updating the DOM everytime the value changes, assuming that you are binding your variable to a DOM element.

About that **format string** thing,

At some point, a timestamp becomes so long ago that a relative date is no longer helpful.
```relativeDate``` handles this situation by checking the time diff against a ```cutoffDay``` variable.
This variable is set to 22 days (3 weeks and a day) by default, however you can easily set it to whatever you like using the ```relativeDateProvider``` in your ```config``` function.

If a timestamp is passed the ```cutoffDay``` than ```relativeDate``` will immediately cancel its timer and return an absolute date formated by angulars built-in ```dateFilter```.
The default format string given to ```dateFilter``` is "MMM d, yyyy" (April 18, 2014).  This can be overridden globally using the ```provider``` or on a case by case basis by providing the desired format string as the optional third argument to ```set```.

examples

    angular.module("myApp",["relativeDate"]).config(function(relativeDateProvider) {
      relativeDateProvider.cutoffDayCount(15);

      relativeDateProvider.defaultFallbackFormat("MMM d, h:mma");
    });



Pull requests welcome. Feel free to fork and hack at will!