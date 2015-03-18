class ig.Selector
  (@parentElement, @contents) ->
    ig.Events @
    self = @
    assoc = {}
    for mesto in contents => assoc[mesto.nazev] = mesto

    @element = @parentElement.append \div
      ..attr \class \selector
    @element.append \select
      ..selectAll \option .data @contents .enter!append \option
        ..html (.nazev)
      ..on \change -> self.emit \selected assoc[@value]
