# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

Query(document).ready ->
  jQuery("#hideshow").live "click", (event) ->
    jQuery("#distribution").toggle "show"
    return
  return