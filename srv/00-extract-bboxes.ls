require! {
  fs
  d3
}


data = JSON.parse fs.readFileSync "#__dirname/../data/okresni-mesta.geojson"
out = data.features.map (feature) ->
  [[w,s],[e,n]] = d3.geo.bounds feature
  [feature.properties.NAZOB, w,s,e,n].join "\t"
out.unshift "obec\tw\ts\te\tn"
fs.writeFileSync "#__dirname/../data/okresni-mesta.tsv", out.join "\n"

