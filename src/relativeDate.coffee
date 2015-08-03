angular.module('relativeDate',[])
  .provider 'relativeDate', ->
    _defaultFallbackFormat_ = "MMM d, yyyy" # Apr 18, 2014
    _cutoffDay_ = 22 # 3 weeks
    _lang_ = "en-US"
    _translationTable_ =
      "en-US":
        now: "just now"
        minute: "about 1 minute ago"
        minutes: "minutes ago"
        hour: "about 1 hour ago"
        hours: "hours ago"
        day: "Yesterday"
        days: "days ago"
        week: "a week ago"
        weeks: "weeks ago"
        month: "over a month ago"

    this.defaultFallbackFormat = (format) ->
      _defaultFallbackFormat_ = format

    this.cutoffDayCount = (numDays) ->
      _cutoffDay_ = numDays

    this.defaultLang = (langCode) ->
      _lang_ = langCode

    this.addLanguage = (langCode, translationObject) ->
      _translationTable_[langCode] = translationObject

    translate = (key) ->
      _translationTable_[_lang_][key]

    fallbackFormat = (formatOverride) ->
      formatOverride || _defaultFallbackFormat_

    isOlderThanCutoff = (time) ->
      date = new Date(time || "")
      diff = (((new Date()).getTime() - date.getTime()) / 1000)
      day_diff = Math.floor(diff / 86400)
      !!( isNaN(day_diff) || day_diff < 0 || day_diff >= _cutoffDay_ )

    this.$get = [ 'dateFilter', '$interval', '$timeout', (dateFilter, $interval, $timeout) ->
      _cache_ = []

      lessThanOneDay = (diff) ->
        switch
          when diff < 60    then translate("now")
          when diff < 120   then translate("minute")
          when diff < 3600  then Math.floor( diff / 60 ) + " " + translate("minutes")
          when diff < 7200  then translate("hour")
          when diff < 86400 then Math.floor( diff / 3600 ) + " " + translate("hours")

      time_ago = (time, override) ->
        date = new Date(time || "")
        diff = (((new Date()).getTime() - date.getTime()) / 1000)
        day_diff = Math.floor(diff / 86400)

        if isOlderThanCutoff(time)                          # if older than "_cutoffDay_" days, don't calculate a relative-time label
          return dateFilter(date, fallbackFormat(override)) # instead, use angular's dateFilter to return an absolute timestamp formated using the string assigned to "_fallbackFormat_"

        switch
          when day_diff is 0 then lessThanOneDay(diff)
          when day_diff is 1 then translate("day")
          when day_diff <  7 then day_diff + " " + translate("days")
          when day_diff is 7 then translate("week")
          when day_diff < 30 then Math.ceil( day_diff / 7 ) + " " + translate("weeks")
          else translate("month")

      return {
        lang: (langCode) ->
          _lang_ = langCode
          _cache_.forEach (d) ->
            $timeout (->d.callback time_ago d.date, d.optionalFormat), 0

        set: (date, callback, optionalFormat) ->
          index = _cache_.length
          _cache_.push {date: date, callback: callback, optionalFormat: optionalFormat}

          iterator = $interval ->
            callback(time_ago date, optionalFormat)
          , 60000 # execute callback function every 60 seconds

          _success = ->              # success callback (not needed here) is called by the $interval promise when all iteration is complete - only possible if the optional 3rd arg (total iterations) was passed into $interval
            return
          _error = ->                # error callback is called by the $interval promise if iteration is canceled early
            _cache_.slice(index,1)          # was canceled by user, so remove from cache
          _notice = ->               # notice callback is called by the $interval promise after each iteration
            if isOlderThanCutoff(date)      # if passed cuttoffDay (not using relative-time labels) then...
              _cache_.slice(index,1)        # remove from cache and
              $interval.cancel(iterator)    # kill $interval updates

          iterator.then(_success, _error, _notice)

          callback(time_ago date, optionalFormat) # initial call to callback function happens immediately.
          return iterator                         # return the promise so you can manualing cancel iteration at later ( like when your directive gets destroyed!!! )
      }
    ]
    return this
