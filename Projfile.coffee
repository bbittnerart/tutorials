fs = require('fs')
async = require('async')

exports.server =
  dirname: 'docs/'


exports.project = (pm) ->
  {$, Utils} = pm
  f = pm.filters(require('pm-spritesheet'))
  $.registerExecutable 'git'

  changeToDocs = f.tap (asset) ->
    asset.filename = asset.filename.replace(/^src/, 'docs')

  changeExtname = (extname) ->
    return f.tap (asset) ->
      asset.filename = Utils.changeExtname(asset.filename, extname)

  all: ['clean', 'docs', 'stylesheets', 'staticFiles', 'spritesheet']

  _toc:
    files: 'src/toc.md'
    dev: [
      f.tutdown assetsDirname: 'docs/examples'
      f.writeFile _filename: 'docs/toc.html'
    ]

  docs:
    desc: 'Builds docs'
    deps: ['_toc']
    files: [
      'src/*.md'
    ]
    dev: [
      f.tutdown
        templates:
          example: fs.readFileSync('src/support/_example.mustache', 'utf8')
          uml: fs.readFileSync('src/support/_uml.mustache', 'utf8')
        assetsDirname: 'docs/examples'
      f.tap (asset) ->
        asset.nav = fs.readFileSync('docs/toc.html')
        asset.filename = asset.filename.replace(/^src/, 'docs')
      f.template
        delimiters: 'mustache'
        filename: 'src/support/_layout.mustache'
        navHeader: ''
      f.writeFile
    ]

  stylesheets:
    desc: 'Builds less files'
    files: ['src/css/*.less']
    dev: [
      f.less dumpLineNumbers: null
      changeToDocs
      f.writeFile
    ]

  staticFiles:
    desc: 'Copies static files'
    watch: 'src/examples'
    dev: ->
      $.xcopy 'src/examples/', 'docs/examples'
      $.xcopy 'src/img/', 'docs/img'
      # needed since we only copy docs/* to gh-pages
      #$.cp 'dist/backbone.giraffe*js', 'docs'

  clean: ->
    $.rm '-rf', 'docs'
    $.mkdir '-p', 'docs'


  dependencies:
    desc: 'Fetches Pixi edge scripts'
    dev: (done) ->
      files =
        'https://raw.github.com/GoodBoyDigital/pixi.js/dev/bin/pixi.dev.js': 'src/examples/js/vendor/pixi.dev.js'
        'https://raw.github.com/jeremyckahn/keydrown/master/dist/keydrown.js': 'src/examples/js/vendor/keydrown.js'
      $.wget(files).then done




  "gh-pages":
    desc: "Creates/updates gh-pages branch"
    dev: (cb) ->
      this.timeout = 30000

      GH_PAGES = '_gh-pages'
      ensureGhPagesBranch = (cb) ->
        if $.test('-d', GH_PAGES)
          cb()
        else
          $ .git "clone git@github.com:peepsquest/tutorials #{GH_PAGES}", (err) ->
            return cb(err) if err
            $.inside GH_PAGES, (popcb) ->
              $.git "checkout -t origin/gh-pages", popcb(cb)

      updateRepo = (cb) ->
        $.inside GH_PAGES, (popcb) ->
          $ .git("checkout gh-pages")
            .git("pull origin gh-pages")
            .start popcb(cb)

      updateFiles = (cb) ->
        $.cp '-rf', 'docs/*', GH_PAGES
        cb()

      async.series [ensureGhPagesBranch, updateRepo, updateFiles], (err) ->
        if err
          $.error 'ERROR', err
        else
          $.info '_gh-pages updated. cd into it and `git push origin gh-pages`'
        cb()

  spritesheet:
    files: 'src/examples/img/tp/*.png'
    dev: [
      f.spritesheet filename: 'docs/examples/img/tp/spritesheet.png', root: 'src/examples/img/tp'
    ]

  roadTiles:
    dev:'Create spritesheet for roadTiles_nova'
    files: 'src/examples/vendor/roadTiles/png/*.png'
    dev: [
      f.spritesheet filename: 'src/examples/img/roadTiles.png', root: 'src/examples/vendor/roadTiles/png/'
    ]

