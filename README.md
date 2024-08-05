# 永程Github音樂播放器

## 永程官網：https://yongcheng.jp/
## 

<table>
    <tr>
        <td>功能簡介</td>
        <td>
            <pre><code>把音樂文件放進Github倉庫，可以用這個播放器來播放（支持.mp3和.m4a)</code></pre>
        </td>
    </tr>
    <tr>
        <td>Feature Overview</td>
        <td>
            <pre><code>Upload music files to a GitHub repository and use this player to play them (supports .mp3 and .m4a)</code></pre>
        </td>
    </tr>
    <tr>
        <td>機能概要</td>
        <td>
            <pre><code>音楽ファイルをGitHubリポジトリにアップロードし、このプレーヤーを使用して再生できます（.mp3および.m4aに対応）</code></pre>
        </td>
    </tr>
</table>

## Cocoapods

1. **新建一個Swift項目，類型選擇Storyboard，然後：**
<table>
    <tr>
        <td>「１」</td>
        <td>
            <pre><code>把Main.storyboard和ViewController.swift刪掉</code></pre>
        </td>
    </tr>
    <tr>
        <td>「２」</td>
        <td>
            <pre><code>同時在Info.plist中（最末尾）把Storyboard Name = Main這一行刪除</code></pre>
        </td>
    </tr>
    <tr>
        <td>「３」</td>
        <td>
            <pre><code>在Build Settings中把Main Storyboard File Base Name刪掉</code></pre>
        </td>
    </tr>
    <tr>
        <td>「４」</td>
        <td>
            <pre><code>在Build Settings裡將User Script Sandboxing設置為No</code></pre>
        </td>
    </tr>
</table>

2. **右鍵單擊Info.plist，選擇Open as source code，並在最後一個Dict結束標籤之前添加如下代碼（以支持後台音頻播放）：**
   ```xml
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
    </array>
   ```
3. **在項目根目錄新建Podfile並添加如下內容（“Example-Cocoapods”替換為你的項目名稱）：**
```ruby

platform :ios, '12.0'

use_frameworks!

target 'Example-Cocoapods' do
  
  pod 'EiteiPLR',  :git => 'https://github.com/JunEitei/EiteiPLR'

end
```
4. **在根目錄運行pod install，完成後打開xcworkspace檔案，並將SceneDelegate.swift替換為如下代碼（把我的地址換成你自己的音樂倉庫地址，音樂倉庫必須是一個Github檔案夾且權限為public）：**
```swift
import UIKit
import EiteiPLR

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)

        // 把我的地址換成你自己的音樂倉庫地址
        window?.rootViewController = ViewController(baseURL: "https://api.github.com/repos/JunEitei/EiteiPLR/contents/Music")

        window?.makeKeyAndVisible()
    }

}
```

5. **將AppDelegate.swift中的didFinishLaunchingWithOptions函數中增加一行（需提前import EiteiPLR）：**
```swift

        EiteiAudioSessionManager.shared.configureAudioSession()

```

6. （Optional）**必要時執行下面的命令以清理Pod緩存：**：
```ruby
pod cache clean --all
pod deintegrate
pod clean
rm -rf ~/Library/Developer/Xcode/DerivedData/*
pod install --repo-update
```    
7.  **運行項目即可**


## SPM

1. **新建一個Swift項目，類型選擇Storyboard。接著在根目錄新建Package.swift，內容如下：**
```swift
// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package()
```
2. **執行下列操作：**
<table>
    <tr>
        <td>「１」</td>
        <td>
            <pre><code>把Main.storyboard和ViewController.swift刪掉</code></pre>
        </td>
    </tr>
    <tr>
        <td>「２」</td>
        <td>
            <pre><code>同時在Info.plist中（最末尾）把Storyboard Name = Main這一行刪除</code></pre>
        </td>
    </tr>
    <tr>
        <td>「３」</td>
        <td>
            <pre><code>在Build Settings中把UIKit Main Storyboard File Base Name刪掉</code></pre>
        </td>
    </tr>
    <tr>
        <td>「４」</td>
        <td>
            <pre><code>在Build Settings裡將User Script Sandboxing設置為No</code></pre>
        </td>
    </tr>
</table>

3. **右鍵單擊Info.plist，選擇Open as source code，並在最後一個Dict結束標籤之前添加如下代碼（以支持後台音頻播放）：**
   ```xml
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
    </array>
   ```

4. **將SceneDelegate.swift替換為如下代碼（把我的地址換成你自己的音樂倉庫地址，音樂倉庫必須是一個Github檔案夾且權限為public）：**
```swift
import UIKit
import EiteiPLR

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)

        // 把我的地址換成你自己的音樂倉庫地址
        window?.rootViewController = ViewController(baseURL: "https://api.github.com/repos/JunEitei/EiteiPLR/contents/Music")

        window?.makeKeyAndVisible()
    }

}
```

5. **將AppDelegate.swift中的didFinishLaunchingWithOptions函數中增加一行（需提前import EiteiPLR）：**
```swift

        EiteiAudioSessionManager.shared.configureAudioSession()

```

6. **順序執行以下操作：**
<table>
    <tr>
        <td>「１」</td>
        <td>
            <pre><code>點擊項目的Build Target，在Build Phases找到“Link Binary With Libraryies”,點擊加號</code></pre>
        </td>
    </tr>
    <tr>
        <td>「２」</td>
        <td>
            <pre><code>彈出的對話框中點擊Add Other，然後Add Package Dependency</code></pre>
        </td>
    </tr>
    <tr>
        <td>「３」</td>
        <td>
            <pre><code>在彈出的對話框中，點擊Add Local（亦可搜索eiteiplr拉取遠程的）</code></pre>
        </td>
    </tr>
</table>

7. **運行項目即可**
