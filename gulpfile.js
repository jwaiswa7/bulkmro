var gulp = require('gulp'),
    connect = require('gulp-connect');

var autoprefixer = require('gulp-autoprefixer');
gulp.task('prefix', function() {
    gulp.src('app/assets/stylesheets/shared/*.css')
        .pipe(autoprefixer({
            browsers: ['last 5 versions'],
            cascade: false
        }))
        .pipe(gulp.dest('app/assets/stylesheets/shared'))
    }
);

gulp.task('webserver', function() {
    connect.server();
});

gulp.task('default', ['webserver']);

