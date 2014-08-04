# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $ ->
    $.extend $.tablesorter.defaults,
      widgets: [
        "zebra"
        "columns"
      ]

    $("table").tablesorter()

    return
