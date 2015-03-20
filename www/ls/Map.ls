class ig.Map
  (@parentElement, @podily, @voronois) ->
    @fullWidth = 610
    @element = @parentElement.append \div
      ..attr \class \map

  draw: ({nazev, w, s, e, n}:city) ->
    @element.html ''
    padding = 20
    projection = ig.utils.geo.getProjection [[w, s], [e, n]], @fullWidth - 2 * padding
    {width, height} = ig.utils.geo.getDimensions [[w, s], [e, n]], projection
    projection.translate [padding, padding]
    fullWidth = width + 2 * padding
    fullHeight = height + 3.5 * padding
    path = d3.geo.path!
      ..projection projection
    toDisplay = city.features
    if toDisplay is void
      toDisplay = @voronois.features.filter (feature) ->
        firstCoordinate = feature.geometry.coordinates.0
        while \Array is typeof! firstCoordinate.0
          firstCoordinate = firstCoordinate.0
        [x, y] = projection firstCoordinate
        -10 < x < width + 10 and -10 < y < height + 10

      for feature in toDisplay
        feature.inCity = nazev
        feature.d = path feature
      city.features = toDisplay

    tile = d3.geo.tile!
      ..size [fullWidth, fullHeight]
      ..scale projection.scale! * 2 * Math.PI
      ..translate projection [0 0]
      ..zoomDelta ((window.devicePixelRatio || 1) - 0.5)
    tiles = tile!

    grouped = @getGroupedFeatures toDisplay
    color = d3.scale.category10!
    @svg = @element.append \svg
      ..attr \width fullWidth
      ..attr \height fullHeight
      ..append \g
        ..attr \class \tiles
        ..attr \transform "scale(#{tiles.scale}) translate(#{tiles.translate})"
        ..selectAll \image .data tiles .enter!append \image
          ..attr \xlink:href -> "https://samizdat.cz/tiles/ton_b1/#{it.2}/#{it.0}/#{it.1}.png"
          ..attr \width 1
          ..attr \height 1
          ..attr \x -> it.0
          ..attr \y -> it.1
    @firmyG = @svg.append \g .attr \class \firmy
    @firmaG = @firmyG.selectAll \g.firma .data grouped .enter!append \g
      ..attr \class \firma
      ..selectAll \path .data (.features) .enter!append \path
        ..attr \d (.d)
        ..attr \fill -> color it.properties.FIRMA
        ..attr \data-tooltip ->
          "<b>#{it.properties.FIRMA}</b><br>
          #{it.properties.ADRESA}"

    {podily} = @podily.filter (.nazev == city.nazev) .0
    @element.append \div
      ..attr \class \barchart
      ..selectAll \div.bar .data podily .enter!append \div
        ..attr \class \bar
        ..style \width -> "#{it.podil}%"
        ..append \div
          ..attr \class \fill
          ..style \background-color -> color it.firma
        ..append \span
          ..attr \class \nazev
          ..html -> toHumanFirma it.firma
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
