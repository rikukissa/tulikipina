fs         = require 'fs'
path       = require 'path'
gulp       = require 'gulp'
gutil      = require 'gulp-util'
jade       = require 'gulp-jade'
stylus     = require 'gulp-stylus'
CSSmin     = require 'gulp-minify-css'
browserify = require 'gulp-browserify'
rename     = require 'gulp-rename'
uglify     = require 'gulp-uglify'
coffeeify  = require 'coffeeify'
rimraf     = require 'rimraf'
lr         = require 'tiny-lr'
livereload = require 'gulp-livereload'
plumber    = require 'gulp-plumber'
prefix     = require 'gulp-autoprefixer'
imagemin   = require 'gulp-imagemin'
cson       = require 'gulp-cson'
replace    = require 'gulp-replace'
rev        = require 'gulp-rev'
express    = require 'express'
reloadServer = lr()

production = process.env.NODE_ENV is 'production'

rimraf.sync './public'

gulp.task 'coffee', ->
  bundle = gulp
    .src('./src/coffee/main.coffee', read: false)
    .pipe(plumber())
    .pipe(browserify(debug: not production))
    .pipe(rename('bundle.js'))

  bundle.pipe(uglify()) if production

  bundle
    .pipe(gulp.dest('./public/js/'))
    .pipe(livereload(reloadServer))

gulp.task "jade", ->
  gulp
    .src('src/jade/*.jade')
    .pipe(jade(pretty: not production))
    .pipe(gulp.dest('public/'))
    .pipe livereload(reloadServer)

gulp.task 'stylus', ->
  styles = gulp
    .src('src/stylus/style.styl')
    .pipe(stylus({set: ['include css']}))
    .on('error', gutil.log)
    .on('error', gutil.beep)

  styles.pipe(CSSmin()) if production

  styles
    .pipe(prefix('last 2 versions', 'Chrome 33', 'Firefox 28', 'Explorer 11', 'iOS 7', 'Safari 7'))
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
    gulp.watch "src/assets/**/*.*", ["assets"]

gulp.task "revision", ["revision-files", "replace-references"]

buildTasks = ["coffee", "jade", "stylus", "assets", "content"]
buildTasks = buildTasks.concat ["compress", "revision"] if production

gulp.task "build", buildTasks

gulp.task "default", ["build", "watch", "server"]
