//必要なモジュールを読み込む
var gulp     = require('gulp');
var htmlhint = require('gulp-htmlhint');
var browser  = require('browser-sync');

//ローカルサーバーを立ち上げるタスク
gulp.task('server', function() {
    browser({
        server: {baseDir: "./src"}
    });
});

//htmlの文法チェックを行うタスク
gulp.task('html', function() {
    gulp.src('./src/**/*.html')
        .pipe(htmlhint()) //実際に処理を行う
        .pipe(htmlhint.reporter());
});

//htmlファイル変更時に実行するタスク(デフォルトに追加)
gulp.task('html-watch', ['html'], function() {
    var htmlhint = gulp.watch('./src/**/*.html', ['html']);
    htmlhint.on('change', function(event) {
        console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
    });
});

//デフォルトで実行されるタスク
gulp.task('default', ['server','html-watch']);
