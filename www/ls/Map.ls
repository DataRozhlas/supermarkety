color = (firma) ->
  switch firma
  | "AHOLD Czech Republic, a. s."            => \#88ac32
  | "Lidl Česká republika, v.o.s."           => \#2b67d7
  | "Billa, s.r.o."                          => \#ffef00
  | "Kaufland Česká republika, v.o.s."       => \#888
  | "Tesco Stores ČR, a.s."                  => \#062594
  | "Spar Česká obchodní společnost, s.r.o." => \#007a4f
  | "Penny Market, s.r.o."                   => \#d62918
  | "Globus ČR, k.s."                        => \#F58220


class ig.Map
  (@parentElement, @podily, @voronois) ->
    @fullWidth = 610
    @element = @parentElement.append \div
      ..attr \class \map

  draw: ({nazev, w, s, e, n}:city) ->
    @element.html ''
    padding = 20
    projectedWidth = @fullWidth - 2 * padding
    projection = ig.utils.geo.getProjection [[w, s], [e, n]], {width: projectedWidth, height: projectedWidth}
    {width, height} = ig.utils.geo.getDimensions [[w, s], [e, n]], projection

    projection.translate [(@fullWidth - width) / 2, (@fullWidth - height) / 2]
    fullWidth = @fullWidth
    fullHeight = @fullWidth
    path = d3.geo.path!
      ..projection projection
    toDisplay = city.features
    if toDisplay is void
      toDisplay = @voronois.features.filter (feature) ->
        firstCoordinate = feature.geometry.coordinates.0
        while \Array is typeof! firstCoordinate.0
          firstCoordinate = firstCoordinate.0
        [x, y] = projection firstCoordinate
        -10 < x < fullWidth + 10 and -10 < y < fullHeight + 10

      for feature in toDisplay
        feature.inCity = nazev
        feature.d = path feature
        feature.center = projection [feature.properties.x, feature.properties.y]
      city.features = toDisplay

    tile = d3.geo.tile!
      ..size [fullWidth, fullHeight]
      ..scale projection.scale! * 2 * Math.PI
      ..translate projection [0 0]
      ..zoomDelta ((window.devicePixelRatio || 1) - 0.5)
    tiles = tile!

    grouped = @getGroupedFeatures toDisplay
    tileSrc = "des1"
    try
      if navigator.vendor == "Google Inc." and -1 != navigator.userAgent.indexOf "Chrome"
        tileSrc = "ton_b1"
    @svg = @element.append \svg
      ..attr \width fullWidth
      ..attr \height fullHeight
      ..append \g
        ..attr \class \tiles
        ..attr \transform "scale(#{tiles.scale}) translate(#{tiles.translate})"
        ..selectAll \image .data tiles .enter!append \image
          ..attr \xlink:href -> "https://samizdat.cz/tiles/#{tileSrc}/#{it.2}/#{it.0}/#{it.1}.png"
          ..attr \width 1
          ..attr \height 1
          ..attr \x -> it.0
          ..attr \y -> it.1
    @firmyG = @svg.append \g .attr \class \firmy
    @firmaG = @firmyG.selectAll \g.firma .data grouped .enter!append \g
      ..attr \class \firma
    @markety = @firmaG.selectAll \g .data (.features) .enter!append \g
      ..attr \class \market
      ..append \path
        ..attr \d (.d)
        ..attr \fill -> color it.properties.FIRMA
      ..append \circle
        ..attr \cx (.center.0)
        ..attr \cy (.center.1)
        ..attr \r 2
    graphTipHolder = @element.append \div .attr \class \graphTip-holder
    @graphTip = new ig.GraphTip graphTipHolder
    @element.append \svg .attr \class \overlay
      ..attr \width fullWidth
      ..attr \height fullHeight
      ..selectAll \path.overlay .data toDisplay .enter!append \path
        ..attr \d (.d)
        ..on \mouseover @~highlightMarket
        ..on \touchstart @~highlightMarket
        ..on \mouseout @~downlightMarket

    {podily} = @podily.filter (.nazev == city.nazev) .0
    podily .= filter (.podil > 0)
    @element.append \div
      ..attr \class \barchart
      ..selectAll \div.bar .data podily .enter!append \div
        ..attr \class \bar
        ..style \width -> "#{Math.floor it.podil}%"
        ..append \div
          ..attr \class \fill
          ..style \background-color -> color it.firma
        ..append \span
          ..attr \class \nazev
          ..html -> "#{toHumanFirma it.firma}<br><span class='podil'>#{ig.utils.formatNumber it.podil}&nbsp;%</span>"
        ..on \mouseover @~highlightPodil
        ..on \touchstart @~highlightPodil
        ..on \mouseout @~downlightPodil

  highlightPodil: ({firma}) ->
    @firmyG.classed \highlight yes
    @firmaG
      .classed \highlight no
      .filter (.firma == firma)
      .classed \highlight yes

  downlightPodil: ->
    @firmyG.classed \highlight no

  highlightMarket: (feature) ->
    @graphTip.display do
      feature.center.0
      feature.center.1
      "<b>#{feature.properties.FIRMA}</b><br>#{feature.properties.ADRESA}<br>Ve spádové oblasti má #{ig.utils.formatNumber feature.properties.COUNT} lidí"
    @firmyG.classed \highlight-market yes
    @markety.classed \highlight-market -> it is feature

  downlightMarket: ->
    @firmyG.classed \highlight-market no
    @markety.classed \highlight-market no
    @graphTip.hide!

  getGroupedFeatures: (features) ->
    byFirma = {}
    for feature in features
      firma = feature.properties.FIRMA
      byFirma[firma] ?= []
      byFirma[firma].push feature

    for firma, features of byFirma => {firma, features}


toHumanFirma = ->
  out = it.split /[ ,]/ .0
  if out == "AHOLD"
    "Albert"
  else
    out
