container = d3.select ig.containers.base
mesta = d3.tsv.parse ig.data.['okresni-mesta'], (row) ->
  for i in <[w s e n]>
    row[i] = parseFloat row[i]
  row
podily = d3.tsv.parse ig.data['mesta-podily'], (row) ->
  out = nazev: row.mesto
  out.podily = for firma, value of row
    continue if firma == 'mesto'
    podil = parseFloat row[firma]
    {firma, podil}
  out

voronois = topojson.feature ig.data.voronoi, ig.data.voronoi.objects.data
map = new ig.Map container, podily, voronois

new ig.Selector container, mesta
  ..on \selected (mesto)-> map.draw mesto

map.draw do
  mesta.filter (.nazev == "Praha") .0
