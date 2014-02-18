relativeDate
============

```relativeDate``` is an Angular.js module containing one service, injectable by the same name.

Replaces iso-formated, date-time stamps with auto-updating, relative time labels

eg. *"just now"*, *"about 1 minute ago"*, or *"yesterday"*

first declare ```relativeDate``` as a dependency of your module

    angular.module("myApp",["relativeDate"])

Now you may inject the included service, ```relativeDate``` into your controllers and directives.

```relativeDate``` has one method, ```set``` which requires 3 parameters.

1. the datetime stamp to be used. *must be in iso-format*
2. a format string that conforms to the angular dateFilter format. eg. "MMM d, yyyy" (more on this later)
3. a callback function that will be called with one argument: the relative-date string calculated by the service

example


    relativeDate.set( isoTime, fallbackFormat, function(relativeDate) {
      $scope.modelObject.relTime = relativeDate;
    });

Your callback will be called once immediately, and again every 60 seconds.
Angular's 2-way databinding will take care of updating the DOM everytime the value changes, assuming that you are binding your variable to a DOM element.

**this readme is not complete. for now, checkout the source code to learn more.**