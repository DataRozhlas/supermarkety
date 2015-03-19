class ig.Map
  (@parentElement, @podily, @voronois) ->
    @fullWidth = 610
    @element = @parentElement.append \div
      ..attr \class \map

  draw: ({nazev, w, s, e, n}:city) ->
    projection = ig.utils.geo.getProjection [[w, s], [e, n]], @fullWidth
    {width, height} = ig.utils.geo.getDimensions [[w, s], [e, n]], projection

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

    grouped = @getGroupedFeatures toDisplay
    color = d3.scale.category10!
    svg = @element.append \svg
      ..attr \width width
      ..attr \height height
      ..append \g .attr \class \firmy
        ..selectAll \g.firma .data grouped .enter!append \g
          ..attr \class \firma
          ..selectAll \path .data (.features) .enter!append \path
            ..attr \d (.d)
            ..attr \fill -> color it.properties.FIRMA

  getGroupedFeatures: (features) ->
    byFirma = {}
    for feature in features
      firma = feature.properties.FIRMA
      byFirma[firma] ?= []
      byFirma[firma].push feature

    for firma, features of byFirma => {firma, features}

