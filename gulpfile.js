var gulp       = require('gulp'),
    cjsx       = require('gulp-cjsx'),
    concat     = require('gulp-concat'),
    less       = require('gulp-less'),
    browserify = require('gulp-browserify'),
    rename     = require('gulp-rename'),
    uglify     = require('gulp-uglify'),
    bower      = require('gulp-bower'),
    del        = require('del');

var paths = {
  frontend: ['src/**/*.coffee'],
  styles: ['src/**/*.less']
};

gulp.task('clean', function (cb) {
  del(['build'], cb);
});

gulp.task('bower', function () {
  return bower().pipe(gulp.dest('components/'));
});

// Compiles coffee to js
gulp.task('translate', ['clean'], function () {
  return gulp.src(paths.frontend)
    .pipe(cjsx({bare: true}))
    .pipe(gulp.dest('build/'));
});

gulp.task('main', ['translate'], function () {
  return gulp.src('build/main.js')
    .pipe(browserify())
    .pipe(rename('show.standalone.js'))
    .pipe(gulp.dest('static/'));
});

gulp.task('concat-libs', ['bower'], function () {
  return gulp.src(['components/lodash/dist/lodash.min.js', 
                  'components/q/q.js', 
                  'components/q-xhr/q-xhr.js',
                  'components/react/react-with-addons.js',
                  'components/socket.io-client/socket.io.js'])
             .pipe(concat('libs.js'))
             .pipe(gulp.dest('static'));
});

gulp.task('compress-libs', ['concat-libs'], function () {
  return gulp.src(['static/libs.js'])
             .pipe(uglify())
             .pipe(rename('libs.min.js'))
             .pipe(gulp.dest('static'));
});

gulp.task('main-bundle', ['main', 'bower', 'concat-libs'], function () {
  return gulp.src(['static/libs.js', 
                   'static/show.standalone.js'])
             .pipe(concat('show.bundle.js'))
             .pipe(gulp.dest('static'));
});


gulp.task('compress-bundle', ['main', 'compress-libs'], function () {
  return gulp.src(['static/libs.min.js', 'static/show.standalone.js'])
    .pipe(concat('show.js'))
    .pipe(gulp.dest('static/'));
});

gulp.task('styles', function () {
  return gulp.src(paths.styles)
    .pipe(less())
    .pipe(concat('style.css'))
    .pipe(gulp.dest('static/'));
});

gulp.task('watch', function () {
  gulp.watch(paths.frontend, ['main-bundle']);
  gulp.watch(paths.styles, ['styles']);
});

gulp.task('default', ['watch', 'main-bundle', 'styles']);
gulp.task('build', ['compress-bundle', 'styles']);
