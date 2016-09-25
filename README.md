# Rails5でAPIモードでプロジェクトを作成した際のサンプル

Ruby / Rails ビギナーズ勉強会 第16回 #coedorbでの登壇資料になります。
Rails5で新たに追加されたAPIモードに関する説明とマイクロサービスアーキテクチャの簡単な解説、およびデフォルトのRailsとどういうところが具体的に異なるのかを説明しています。
※こちらに関しては後ほどQiitaに詳細な説明を追加する予定です。

[登壇の際に使用した資料はこちら](http://www.slideshare.net/fumiyasakai37/rails5api)

Rails5のAPIモードで作成したAPIサーバーにおいて、静的なHTMLページからファイルのアップロードを行うサンプルになります。
現状では画像アップロードと新規追加部分だけではありますが、今後もWebアプリケーションやネイティブアプリのAPIサーバーを作成する際に活用して頂ければ幸いに思います。

+ フロントエンド側：gulp(node.js)
+ バックエンドAPI側：Rails5(APIモード)

## 1. このサンプルの概要

各々のローカルサーバーを立ち上げてフロンドエンドのindex.htmlに書かれたJavaScript(jQuery)のコードを経由してAPI側のエンドポイント(Rails5側のcreateメソッド)にアクセスしてファイルの投稿を行うサンプルになります。

まずは本サンプルを下記コマンドでcloneする or Zipファイルをダウンロードしてください。

```
$ git clone git@github.com:fumiyasac/rails-api-mode-sample.git
```

展開したディレクトリ内で下記の2つの作業を実行して下さい。

##### 1-1. このサンプルを動かすための準備(node.js)

frontendフォルダ内に`package.json`ファイルがあるので、node.jsがすでにインストールされている場合には下記のコマンドを実行してインストールをして下さい。

```
$ cd frontend/
$ npm install
```

インストールが完了したらgulpを実行してサーバーを起動して下さい。

```
$ gulp
```

コンソール内の[BS] Access URLs:のExternalのURLにアクセスしてエラー等が起こらなければOKです。

※ デフォルトではlocalhost:3000でのアクセスになりますが、今回はコンソールに表示される`[BS] Access URLs:のExternalのURL`にアクセスして下さい。
※ 今回はHTMLの文法チェックが入っているのでご活用下さい。

__環境がない場合の参考：__

node.js及びgulpが導入されていない場合は下記等を参考にして環境構築を行って下さい。
[Gulpまとめ(導入手順とgulpfile)](http://qiita.com/hththt/items/bcded1839655dbd78873)

##### 1-2. このサンプルを動かすための準備(Rails5)

API部分は本サンプルではすでに出来上がっている状態ですので、Gemの導入とDB(developmentではsqlite3を使用)のマイグレーションを行います。

```
$ cd api/file_upload_api/
$ bundle install
$ rails db:migrate
```

上記が完了して特にエラー等が発生しなければサーバー起動を実行すればOKです。

```
$ rails s -b 127.0.0.1
```

127.0.0.1:3000にアクセスしてエラー等が起こらなければOKです。

__環境がない場合の参考：__

Rails5を動かす環境がない場合は下記等を参考にして環境構築を行って下さい。
[rails5.0.0を導入する。](http://qiita.com/gaku3601/items/5a484043f9c803ce9941)

JFYI: API側はScaffoldを使用しています。下記が構築の下準備までの手順になります。

```
$ rails _5.0.0_ new file_upload_api --api
---(paperclipとaws-sdkを追加 ＆ jbuilderとrack-corsのコメントアウトを外す)---
$ bundle install
$ rails g scaffold Item title:string description:string
$ rails g paperclip item picture
$ rails db:migrate
```

参考：[RailsによるAPI専用アプリ](http://railsguides.jp/api_app.html)

## 2. 仕様について

現状の仕様に関しては下記のような感じになっています。こちらの機能に関しては、今後追加していく予定です。

##### 1-1. このサンプルで使用しているプラグイン(node.js)

今回はローカルサーバーを立ち上げる機能とHTMLの文法チェックを使用しています。

+ [gulp-htmlhint](https://www.npmjs.com/package/gulp-htmlhint) → HTMLの文法チェックを行う
+ [browser-sync](https://www.npmjs.com/package/browser-sync) → ローカルでページ検証用のブラウザを立ち上げる

※ 実際の実装に関しては、`gulpfile.js`を参考にして下さい。

##### 1-2. このサンプルで使用しているGem(Rails5)

__ポイント1. コメントアウトを行っている部分を有効化する__

+ (有効化)JSON出力用のテンプレートを作成するGem：`gem 'jbuilder', '~> 2.5'`
+ (有効化)クロスドメインでのアクセスを有効にするGem：`gem 'rack-cors'`

またrack-corsを有効にした際は、`config/application.rb`へ下記を追記しています。

```:ruby
module FileUploadApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.

    # Corsに関する設定を追記する
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end
    config.api_only = true
  end
end
```

__ポイント2. 新たに追加したファイルのアップロードに関するGem__

+ (新規追加)画像等のファイルアップロードをしやすくするGem：`gem 'paperclip', '~> 5.0.0.beta1'`
+ (新規追加)AWSへのアクセスや処理をするためのGem：`gem 'aws-sdk', '~> 2.0'`

※ローカル内でのみ本ファイルを動かす際は`aws-sdk`は特に不要です。（heroku等のサーバーを使用する場合に必要）

実装例はAPI側の`item.rb(Model側)`や`items_controller.rb`

またAmazonS3を外部ストレージとして使用する場合には下記の記事等を参考に設定を行って頂ければと思います。
参考：[PaperclipとAWS S3を用いた画像アップロード機能作成手順まとめ](http://qiita.com/fumiyasac@github/items/320f80dcab492b3e31ab)

##### 1-3. 実際にファイルのアップロード処理を行っている部分(Rails5)

フォーム部分にて画像ファイルをAjaxを用いてアップロードする部分に関しては下記のようになります。（jQuery2系を使用）

参考：(https://blog.hello-world.jp.net/javascript/2640/)

```:javascript
(function(win, doc) {
  $('form').submit(function(e) {
    $(this).find(':submit').prop('disabled', true);
    $(this).find(':submit').val('送信中...');
    e.preventDefault();
    var fd = new FormData($(this)[0]);
    $.ajax('http://127.0.0.1:3000/items', {
      method: 'POST',
      processData: false,
      contentType: false,
      data: fd,
      dataType: 'json',
      success: function(json) {
        $('form').find(':submit').val('画像の投稿が完了しました');
        alert('ファイルが投稿されました');
      },
      error: function(json) {
        $('form').find(':submit').prop('disabled', false);
        $('form').find(':submit').val('新規投稿を再度チャレンジする');
        alert('エラーが発生しました');
      }
    });
  });
})(this, document);
```

また、こちらのHTMLのデザインに関してはTwitterBootstrapを使用しています。

## 3. その他

+ 1) こちらのサンプルは今後も機能を加えたり、Railsのバージョンアップにも引き続き対応していく所存です。
+ 2) ご質問やPullRequest・要望等がありましたらお気軽にどうぞ＾＾
