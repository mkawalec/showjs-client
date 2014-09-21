var gulp       = require('gulp'),
    cjsx       = require('gulp-cjsx'),
    concat     = require('gulp-concat'),
    sourcemaps = require('gulp-sourcemaps'),
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
    .pipe(sourcemaps.init())
    .pipe(cjsx({bare: true}))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('build/'));
});

gulp.task('main', ['translate'], function () {
  return gulp.src('build/main.js')
    .pipe(browserify())
    .pipe(rename('show.js'))
    .pipe(gulp.dest('static/'));
});

gulp.task('main-bundle', ['main', 'bower'], function () {
  return gulp.src(['components/lodash/dist/lodash.min.js', 
                  'components/q/q.js', 
                  'components/q-xhr/q-xhr.js',
                  'components/react/react.js',
                  'components/socket.io-client/socket.io.js',
                  'static/show.js'])
             .pipe(concat('show.bundle.js'))
             .pipe(gulp.dest('static'));
});

gulp.task('compress', ['main'], function () {
  return gulp.src('static/show.js')
    .pipe(uglify())
    .pipe(rename('show.min.js'))
    .pipe(gulp.dest('static/'));
});

gulp.task('compress-bundle', ['main-bundle', 'bower'], function () {
  return gulp.src('static/show.bundle.js')
    .pipe(uglify())
    .pipe(rename('show.bundle.min.js'))
    .pipe(gulp.dest('static/'));
});

gulp.task('styles', function () {
  return gulp.src(paths.styles)
    .pipe(less())
    .pipe(concat('style.css'))
    .pipe(gulp.dest('static/'));
});

gulp.task('watch', function () {
  gulp.watch(paths.frontend, ['main']);
  gulp.watch(paths.styles, ['styles']);
});

gulp.task('default', ['watch', 'main-bundle', 'styles']);
gulp.task('build', ['compress-bundle', 'styles']);
