### 概要
Flickrの写真の位置情報を使って、地図上へのプロットを行う。
また、その場所への経路探索を提供する。

### 予定する機能
* 写真の数の多い順に場所をリストアップ
* 地点と範囲を指定して検索
* 期間を指定した検索
* その地点で撮影された画像の表示
* ピンまでの経路探索

### 実装リスト
* APIを叩けるようにする(done)
* 検索ボタンの実装(done)
* 取得した画像のピン打ち(done)
* ピンの画像をサムネイルに置き換え(done)
* 現在地に地図をスクロールできるようにする(done)
* 詳細ビューでの大きい画像の表示(done)
* ピンをまとめる機能の追加
* リストビューの実装
* 撮影場所の取得

### インターフェース
![Map View](https://github.com/sf-arte/Spica/blob/master/doc_files/mapview.png)
![Image View](https://github.com/sf-arte/Spica/blob/master/doc_files/imageview.png)

### 使用方法
初回起動時にflickrのページがブラウザで開かれるので、ログインしてアプリの連携を許可する。  
右下の検索ボタンを押すと、地図で表示されているエリアで画像が検索され、表示される。  
検索バーに文字列を入力すると、そのエリアでタイトルやタグに文字列を含む画像を検索する。  
iボタンを押すと、現在地からの経路が表示される。

### ビルド方法
CarthageでSwiftJSONとOAuthSwiftをビルド。
```
carthage update --platform iOS
```
プロジェクトファイルを開き、設定の"General > Linked Frameworks and Libraries"に"Carthage/Build/iOS"内の"SwiftyJSON.framework"と"OAuthSwift.framework"を追加する。  
"Build Phases"タブの＋ボタンから”New Run Script Phase"を選択。  
"Run Script"の"Shell"の下に以下のように記述する。  
```
/usr/local/bin/carthage copy-frameworks
```
"Input Files"に以下の行を追加。
```
$(SRCROOT)/Carthage/Build/iOS/SwiftyJSON.framework
$(SRCROOT)/Carthage/Build/iOS/OAuthSwift.framework
```

(参考: <https://github.com/Carthage/Carthage/blob/master/README.md>)

Flickrにログインし<https://www.flickr.com/services/apps/create/apply/>にアクセス。
”APPLY FOR A NON-COMMERCIAL KEY"をクリックし、アプリケーションの情報を入力する。  
得られたKeyとSecretを"key.txt"に1行ずつ記述して、プロジェクトの"Build Phases > Copy Bundle Resources"に追加する。
