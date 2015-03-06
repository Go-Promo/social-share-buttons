window.App ||= {}

class App.SocialBase
  constructor: (@$container, @settings) ->
    if @settings.selectors[@type]
      @$selector = @$container.find(@settings.selectors[@type])

    if @$selector.length
      @url = @settings.url
      @title = encodeURIComponent @settings.title
      @description = encodeURIComponent @settings.description
      @image = encodeURIComponent @settings.image

      @getCount()
      @initClick()

  getCount: -> throw Error 'unimplemented method'

  initClick: -> throw Error 'unimplemented method'

class App.SocialOk extends App.SocialBase
  type: 'ok'

  constructor: ($container, settings) ->
    super $container, settings, @type

  getCount: ->
    deferred = $.Deferred()
    deferred.then (number) =>
      @$selector.parent().find('span').text number

    window.ODKL ||= {}
    window.ODKL.updateCount = (idx, number) ->
      deferred.resolve number

    $.ajax
      url: "http://ok.ru/dk?st.cmd=extLike&uid=odklcnt0&ref=#{@url}"
      dataType: 'jsonp'

  initClick: ->
    @$selector.on 'click', (e) =>
      e.preventDefault()
      open "http://ok.ru/dk?st.cmd=addShare&st._surl=#{@url}&title=#{@title}", "_blank", "scrollbars=0, resizable=1, menubar=0, left=100, top=100, width=550, height=440, toolbar=0, status=0"
    
class App.SocialGp extends App.SocialBase
  type: 'gp'

  constructor: ($container, settings) ->
    super $container, settings, @type

  getCount: ->
    window.services ||= {}
    window.services.gplus ||= {}
    window.services.gplus.cb = (number) ->
      window.gplusShares = number

    $.getScript "http://share.yandex.ru/gpp.xml?url=#{@url}", =>
      result = gplusShares or 0
      @$selector.parent().find('span').text result

  initClick: ->
    @$selector.on 'click', (e) =>
      e.preventDefault()
      open "https://plus.google.com/share?url=#{@url}", "_blank", "scrollbars=0, resizable=1, menubar=0, left=100, top=100, width=550, height=440, toolbar=0, status=0"

class App.SocialTw extends App.SocialBase
  type: 'tw'

  constructor: ($container, settings) ->
    super $container, settings, @type

  getCount: ->
    $.ajax
      url: "https://cdn.api.twitter.com/1/urls/count.json?url=#{@url}"
      dataType: 'jsonp'
      success: (data) =>
        result = data.count or 0
        @$selector.parent().find("span").text result

  initClick: ->
    @$selector.on 'click', (e) =>
      e.preventDefault()
      open "https://twitter.com/intent/tweet?text=#{@title}&url=#{@url}", "_blank", "scrollbars=0, resizable=1, menubar=0, left=100, top=100, width=550, height=440, toolbar=0, status=0"

class App.SocialFb extends App.SocialBase
  type: 'fb'

  constructor: ($container, settings) ->
    super $container, settings, @type

  getCount: ->
    $.ajax
      url: "https://api.facebook.com/method/links.getStats?urls=#{@url}&format=json"
      dataType: 'jsonp'
      success: (data) =>
        result = data[0]?.share_count or 0
        @$selector.parent().find("span").text result

  initClick: ->
    @$selector.on 'click', (e) =>
      e.preventDefault()
      params = "s=100&p[url]=#{@url}&p[title]=#{@title}&p[summary]=#{@description}&p[images][0]=#{@image}"
      open "http://www.facebook.com/sharer.php?m2w&#{params}", "_blank", "scrollbars=0, resizable=1, menubar=0, left=100, top=100, width=550, height=440, toolbar=0, status=0"

class App.SocialVk extends App.SocialBase
  type: 'vk'

  constructor: ($container, settings) ->
    super $container, settings, @type

  getCount: ->
    deferred = $.Deferred()
    deferred.then (number) =>
      @$selector.parent().find('span').text number

    unless requests
      requests = []

      window.VK ||= {}
      VK.Share ||= {}
      VK.Share.count = (index, number) ->
        requests[index].resolve number

    index = requests.length
    requests.push deferred

    $.ajax
      url: "http://vk.com/share.php?act=count&url=#{@url}&index=#{index}"
      dataType: 'jsonp'

  initClick: ->
    @$selector.on 'click', (e) =>
      e.preventDefault()
      title = encodeURIComponent @settings.title
      open "http://vk.com/share.php?url=#{@url}&title=#{@title}", "_blank", "scrollbars=0, resizable=1, menubar=0, left=100, top=100, width=550, height=440, toolbar=0, status=0"