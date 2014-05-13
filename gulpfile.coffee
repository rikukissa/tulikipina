fs         = require 'fs'
path       = require 'path'
gulp       = require 'gulp'
gutil      = require 'gulp-util'
jade       = require 'gulp-jade'
stylus     = require 'gulp-stylus'
CSSmin     = require 'gulp-minify-css'
browserify = require 'browserify'
watchify   = require 'watchify'
rename     = require 'gulp-rename'
uglify     = require 'gulp-uglify'
rimraf     = require 'rimraf'
lr         = require 'tiny-lr'
livereload = require 'gulp-livereload'
cmq        = require 'gulp-combine-media-queries'
concat     = require 'gulp-concat'
prefix     = require 'gulp-autoprefixer'
imagemin   = require 'gulp-imagemin'
cson       = require 'gulp-cson'
less       = require 'gulp-less'
replace    = require 'gulp-replace'
rev        = require 'gulp-rev'
express    = require 'express'
source     = require 'vinyl-source-stream'
streamify  = require 'gulp-streamify'
es         = require 'event-stream'
reloadServer = lr()

production = process.env.NODE_ENV is 'production'


rimraf.sync './public'

gulp.task 'coffee', ->

  entries = [
    path: './src/coffee/main.coffee'
    file: 'bundle.js'
  ,
    path: './src/coffee/ie.coffee'
    file: 'ie.js'
  ]

  es.concat.apply es, entries.map (entry) ->

    opts =
      entries: [entry.path]
      extensions: ['.coffee']

    bundle = unless production
      watchify opts
    else
      browserify opts

    rebundle = ->

      build = bundle.bundle
          debug: not production
        .on 'error', gutil.log
        .pipe(source(entry.file))

      build.pipe(streamify(uglify())) if production

      build
        .pipe(gulp.dest('./public/js/'))
        .pipe(livereload(reloadServer))

    bundle.on 'update', rebundle unless production

    rebundle()

gulp.task "jade", ->
  gulp
    .src('src/jade/*.jade')
    .pipe(jade(pretty: not production))
    .pipe(gulp.dest('public/'))
    .pipe livereload(reloadServer)

gulp.task 'stylus', ->
  err = (err) ->
    gutil.beep()
    gutil.log err
    this.emit 'end'

  styl = gulp
    .src('src/stylus/style.styl')
    .pipe(stylus({set: ['include css']}))
    .on 'error', err

  les = gulp.src('src/less/*.less')
    .pipe less()
    .on 'error', err

  styles = es.merge styl, les
    .pipe concat 'style.css'
    #.pipe cmq()
    .on 'error', err

  styles = styles.pipe(CSSmin()) if production

  styles
    .pipe(prefix('last 2 versions', 'Chrome 33', 'Firefox 28', 'Explorer >= 8', 'iOS 7', 'Safari 7'))
    .pipe(gulp.dest('public/css/'))
    .pipe livereload reloadServer

gulp.task 'assets', ->
  gulp
    .src ['src/assets/**/*', 'src/assets/**/.*', 'vendor/font-awesome/fonts*/*.*']
    .pipe gulp.dest 'public/'

gulp.task 'compress', ['assets'], ->
  gulp
    .src 'public/images/**/*.*'
    .pipe imagemin()
    .pipe gulp.dest 'public/images/'

gulp.task 'content', ->
  gulp
    .src('src/coffee/**/*.cson')
    .pipe cson()
    .pipe gulp.dest 'public/'
    .pipe livereload(reloadServer)

gulp.task 'revision-files', ["coffee", "stylus", "compress"],  ->
  gulp
    .src ['public/**/*.js', 'public/**/*.css', 'public/videos*/**/*', 'public/images*/**/*']
    .pipe rev()
    .pipe gulp.dest './public/'
    .pipe rev.manifest()
    .pipe gulp.dest './'

gulp.task 'replace-references', ['revision-files'], ->
  revisions = JSON.parse fs.readFileSync './rev-manifest.json'

  build = gulp.src ['public/*.html', 'public/css*/*.css']

  for location, revision of revisions
    build = build.pipe replace location, revision

  build.pipe gulp.dest 'public/'

gulp.task "server", ->
  app = express()

  app.configure ->
    app.use express.static path.join __dirname, 'public'

  app.get '/*', (req, res) ->
    res.sendfile path.join __dirname, 'public/index.html'

  app.listen 9001

gulp.task "watch", ->
  reloadServer.listen 35729, (err) ->
    console.error err if err?

    gulp.watch "src/coffee/**/*.cson", ["content"]
    gulp.watch "src/coffee/**/*.coffee", ["coffee"]
    gulp.watch "src/jade/**/*.jade", ["jade"]
    gulp.watch "src/stylus/**/*.styl", ["stylus"]
    gulp.watch "src/less/**/*.less", ["stylus"]
    gulp.watch "src/assets/**/*.*", ["assets"]

gulp.task "revision", ["revision-files", "replace-references"]

buildTasks = ["coffee", "jade", "stylus", "assets", "content"]
buildTasks = buildTasks.concat ["compress", "revision"] if production

gulp.task "build", buildTasks

gulp.task "default", ["build", "watch", "server"]
