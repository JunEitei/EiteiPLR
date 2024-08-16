# Eitei音楽プレーヤー

| **機能**               | **紹介**                                   |
|:-----------------------|:-------------------------------------------|
| ⭐️曲の再生               | GitHub倉庫にある曲を再生できます             |
| ⭐️ループ機能             | 単曲ループとリストループの選択が可能です       |
| ⭐️アルバム切り替え       | 再生するアルバムを切り替えることができます    |
| ⭐️音楽のアップロード     | 自定義アルバムに音楽をアップロードできます  |
| ⭐️自定義アルバム管理     | 自定義アルバムの音楽を削除することができます  |

## Preview：

<img width="559" alt="截圖 2024-08-08 16 34 15" src="https://github.com/user-attachments/assets/21728150-021f-45b9-942e-a8286944da3a">
<img width="559" alt="截圖 2024-08-08 11 53 11" src="https://github.com/user-attachments/assets/c68688fe-9e3d-48d5-9fc6-22d1b09f6d7b">
<img width="559" alt="截圖 2024-08-05 11 34 43" src="https://github.com/user-attachments/assets/b1584908-86f4-41b4-a27e-821db4ab5eab">

## Cocoapods を使ってインストールする方法

1. **新しい Swift プロジェクトを作成し、Storyboard を選択して、次の操作を行います：**
<table>
    <tr>
        <td>「１」</td>
        <td>
            <pre><code>Main.storyboard と ViewController.swift を削除する</code></pre>
        </td>
    </tr>
    <tr>
        <td>「２」</td>
        <td>
            <pre><code>Info.plist の末尾で、Storyboard Name = Main の行を削除する</code></pre>
        </td>
    </tr>
    <tr>
        <td>「３」</td>
        <td>
            <pre><code>Build Settings で Main Storyboard File Base Name を削除する</code></pre>
        </td>
    </tr>
    <tr>
        <td>「４」</td>
        <td>
            <pre><code>Build Settings で User Script Sandboxing を No に設定する</code></pre>
        </td>
    </tr>
</table>

2. **Info.plist を右クリックして「ソースコードとして開く」を選択し、最後の Dict タグの終了タグの前に以下のコードを追加します（バックグラウンドオーディオ再生をサポートするため）：**
   ```xml
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
    </array>
   ```
3. **プロジェクトのルートディレクトリに Podfile を新しく作成し、以下の内容を追加します（「Example-Cocoapods」をあなたのプロジェクト名に置き換えてください）：**
```ruby

platform :ios, '12.0'

use_frameworks!

target 'Example-Cocoapods' do
  
  pod 'EiteiPLR',  :git => 'https://github.com/JunEitei/EiteiPLR'

end
```
4. **ルートディレクトリで pod install を実行し、完了後に xcworkspace ファイルを開きます。次に、SceneDelegate.swift を以下のコードで置き換えます（自分の音楽リポジトリの URL に置き換えてください。音楽リポジトリは GitHub 上のフォルダで、パブリックにする必要があります）：**
```swift
import UIKit
import EiteiPLR

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)

        // 自分の音楽リポジトリの URL に置き換えてください
        window?.rootViewController = UINavigationController(rootViewController: ViewController(baseURL: "https://api.github.com/repos/JunEitei/Music/contents/わたしも")!)

        window?.makeKeyAndVisible()
    }

}
```

5. **AppDelegate.swift の didFinishLaunchingWithOptions 関数に以下の行を追加します（事前に EiteiPLR をインポートしておく必要があります）：**
```swift

        EiteiAudioSessionManager.shared.configureAudioSession()

```

6. （オプション）必要に応じて以下のコマンドを実行して Pod キャッシュをクリアします：**：
```ruby
pod cache clean --all
pod deintegrate
pod clean
rm -rf ~/Library/Developer/Xcode/DerivedData/*
pod install --repo-update
```    
7.  **プロジェクトを実行します**


## SPM を使ってインストールする方法

1. **新しい Swift プロジェクトを作成し、Storyboard を選択します。次に、ルートディレクトリに Package.swift を新しく作成し、以下の内容を追加します：**
```swift
// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package()
```
2. **次の操作を行います：**
<table>
    <tr>
        <td>「１」</td>
        <td>
            <pre><code>Main.storyboard と ViewController.swift を削除する</code></pre>
        </td>
    </tr>
    <tr>
        <td>「２」</td>
        <td>
            <pre><code>Info.plist の末尾で、Storyboard Name = Main の行を削除する</code></pre>
        </td>
    </tr>
    <tr>
        <td>「３」</td>
        <td>
            <pre><code>Build Settings で UIKit Main Storyboard File Base Name を削除する</code></pre>
        </td>
    </tr>
    <tr>
        <td>「４」</td>
        <td>
            <pre><code>Build Settings で User Script Sandboxing を No に設定する</code></pre>
        </td>
    </tr>
</table>

3. **Info.plist を右クリックして「ソースコードとして開く」を選択し、最後の Dict タグの終了タグの前に以下のコードを追加します（バックグラウンドオーディオ再生をサポートするため）：**
   ```xml
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
    </array>
   ```

4. **SceneDelegate.swift を以下のコードで置き換えます（自分の音楽リポジトリの URL に置き換えてください。音楽リポジトリは GitHub 上のフォルダで、パブリックにする必要があります）：**
```swift
import UIKit
import EiteiPLR

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)

        // 自分の音楽リポジトリの URL に置き換えてください
        window?.rootViewController = UINavigationController(rootViewController: ViewController(baseURL: "https://api.github.com/repos/JunEitei/Music/contents/わたしも")!)

        window?.makeKeyAndVisible()
    }

}
```

5. **AppDelegate.swift の didFinishLaunchingWithOptions 関数に以下の行を追加します（事前に EiteiPLR をインポートしておく必要があります）：**
```swift

        EiteiAudioSessionManager.shared.configureAudioSession()

```

6. **以下の手順を順番に実行します：**
<table>
    <tr>
        <td>「１」</td>
        <td>
            <pre><code>プロジェクトの Build Target をクリックし、Build Phases で「Link Binary With Libraries」を見つけて、プラスアイコンをクリックする</code></pre>
        </td>
    </tr>
    <tr>
        <td>「２」</td>
        <td>
            <pre><code>表示されるダイアログで「Add Other」をクリックし、「Add Package Dependency」を選択する</code></pre>
        </td>
    </tr>
    <tr>
        <td>「３」</td>
        <td>
            <pre><code>表示されるダイアログで「Add Local」をクリックする（リモートの EiteiPLR を検索して取得することも可能）</code></pre>
        </td>
    </tr>
</table>


7. **プロジェクトを実行します**
