_ = require 'lodash'
fs = require 'fs'
path = require 'path'
gulp = require 'gulp'
gutil = require 'gulp-util'
jade = require 'gulp-jade'
stylus = require 'gulp-stylus'
CSSmin = require 'gulp-minify-css'
browserify = require 'browserify'
watchify = require 'watchify'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
rimraf = require 'rimraf'
lr = require 'tiny-lr'
livereload = require 'gulp-livereload'
cmq = require 'gulp-combine-media-queries'
concat = require 'gulp-concat'
prefix = require 'gulp-autoprefixer'
imagemin = require 'gulp-imagemin'
marked = require 'marked'
cson = require 'gulp-cson'
less = require 'gulp-less'
replace = require 'gulp-replace'
rev = require 'gulp-rev'
express = require 'express'
source = require 'vinyl-source-stream'
streamify = require 'gulp-streamify'
es = require 'event-stream'

reloadServer = lr()
contentful = require './contentful'

production = process.env.NODE_ENV is 'production'


rimraf.sync './public'

toPromise = (stream) ->
  new Promise (resolve, reject) ->
    stream.on 'end', resolve
    stream.on 'error', reject

gulp.task 'coffee', ->

  entries = [
    path: './src/coffee/main.coffee'
    file: 'bundle.js'
  ]
  opts =
    extensions: ['.coffee']
    debug: !production
    cache: {}
    paths: ['src/coffee', 'node_modules']
    packageCache: {}

  contentful.getContent().then (content) ->

    bundler = if production then browserify else _.compose(watchify, browserify)

    toPromise es.concat.apply es, entries.map (entry) ->

      bundle = bundler _.extend opts,
        entries: [entry.path]
        insertGlobalVars:
          __CONTENT__: ->
            JSON.stringify content

      rebundle = ->

        build = bundle.bundle()
        .on 'error', gutil.log
        .pipe(source(entry.file))

        build.pipe(streamify(uglify())) if production

        build
          .pipe(gulp.dest('./public/js/'))
          .pipe(livereload(reloadServer))

      bundle.on 'update', rebundle unless production

      rebundle()


toGrid = (data) ->
  _.chain(data)
    .map (activity, id) -> {id, activity}
    .groupBy (item, i) ->
      Math.floor i / 3
    .toArray()
    .value()

gulp.task 'jade', ->
  contentful.getContent().then (content) ->
    stream = gulp
      .src('src/jade/*.jade')
      .pipe(jade(
        pretty: not production
        paths: [path.join(__dirname, 'src')]
        locals: _.extend content,
          markdown: marked
          toGrid: toGrid
      ))
      .pipe(gulp.dest('public/'))
      .pipe livereload(reloadServer)

    toPromise stream

gulp.task 'stylus', ->
  err = (err) ->
    gutil.beep()
    gutil.log err
    this.emit 'end'

  styl = gulp
    .src('src/stylus/style.styl')
    .pipe(stylus({
      'include css': true
      paths: [
        'node_modules',
        path.join(__dirname, 'src/stylus'),
        path.join(__dirname, 'src/coffee')
      ]
    }))
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
    .src [
      'src/assets/**/*',
      'src/assets/**/.*',
      'bower_components/font-awesome/fonts*/*.*',
      'node_modules/leaflet/dist/images*/*.*']
    .pipe gulp.dest 'public/'

gulp.task 'compress', ['assets'], ->
  gulp
    .src 'public/images/**/*.*'
    .pipe imagemin()
    .pipe gulp.dest 'public/images/'

gulp.task 'revision-files', ['coffee', 'stylus', 'compress'],  ->
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

gulp.task 'server', ->
  app = express()

  app.configure ->
    app.use express.static path.join __dirname, 'public'

  app.get '/*', (req, res) ->
    res.sendfile path.join __dirname, 'public/index.html'

  app.listen 9001

gulp.task 'watch', ->
  reloadServer.listen 35729, (err) ->
    console.error err if err?

    gulp.watch 'src/jade/**/*.jade', ['jade']
    gulp.watch 'src/**/*.styl', ['stylus']
    gulp.watch 'src/less/**/*.less', ['stylus']
    gulp.watch 'src/assets/**/*.*', ['assets']

gulp.task 'revision', ['revision-files', 'replace-references']

buildTasks = ['coffee', 'jade', 'stylus', 'assets']
buildTasks = buildTasks.concat ['compress', 'revision'] if production

gulp.task 'build', buildTasks

gulp.task 'default', ['build', 'watch', 'server']
