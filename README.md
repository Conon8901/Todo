# Todo

- 追加
    - データ保存をクラス作ってまとめる↓以下
    - 脚注づけ: 消しかねないコード
    - 全削除後に編集状態終了
    - realm

```
class TaskData {
    var fileName: String
    var noteText: String {
        didSet {
            UserDefaults.standard.set(TaskData.self, forKey: fileName)
        }
    }
    var isChecked: Bool {
        didSet {
            UserDefaults.standard.set(TaskData.self, forKey: fileName)
        }
    }
    
    func resave(oldKey: String, newKey: String) {
        UserDefaults.standard.set(TaskData.self, forKey: newKey)
        UserDefaults.standard.removeObject(forKey: oldKey)
    }
    
    init() {
        self.fileName = ""
        self.noteText = ""
        self.isChecked = false
    }
}
```
