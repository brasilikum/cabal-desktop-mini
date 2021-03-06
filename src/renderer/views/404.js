var html = require('choo/html')

var TITLE = 'Cabal Mini'

module.exports = view

function view (state, emit) {
  if (state.title !== TITLE) emit(state.events.DOMTITLECHANGE, TITLE)
  return html`
    <body class="sans-serif">
      <h1 class="f-headline pa3 pa4-ns">
        404 - route not found
      </h1>
      <a href="./cabals" class="link black underline">
        Back to main
      </a>
    </body>
  `
}