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
        [x, y] = projection feature.geometry.coordinates.0.0
        -10 < x < width + 10 and -10 < y < height + 10
      for feature in toDisplay
        feature.inCity = nazev
        feature.d = path feature
      city.features = toDisplay

    svg = @element.append \svg
      ..attr \width width
      ..attr \height height
      ..append \g
        ..attr \class \mesh
        ..selectAll \path .data toDisplay .enter!append \path
          ..attr \d (.d)
