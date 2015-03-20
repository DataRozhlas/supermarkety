class ig.Selector
  (@parentElement, @contents) ->
    ig.Events @
    self = @
    assoc = {}
    @contents.sort (a, b) -> if a.nazev > b.nazev then 1 else -1
    for mesto in contents => assoc[mesto.nazev] = mesto

    @element = @parentElement.append \div
      ..attr \class \selector
    @element.append \select
      ..selectAll \option .data @contents .enter!append \option
        ..html (.nazev)
        ..attr \selected -> if it.nazev == "Praha" then yes else void
      ..on \change -> self.emit \selected assoc[@value]
