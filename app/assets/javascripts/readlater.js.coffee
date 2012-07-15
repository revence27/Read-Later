$ ->
  wrapComments()

wrapComments = () ->
  for com in $('.comments')
    comments  = $(com)
    comments.hide()
    shower  = $('<a href="#comments">Show Comments</a>')
    shower.css('display', 'block')
    shower.css('font-size', '50%')
    shower.click((evt) ->
      for c1 in $('.comments')
        $(c1).slideDown('fast', () ->
          shower.slideUp('fast')
        )
    )
    shower.insertBefore comments
