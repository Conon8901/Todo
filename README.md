# Todo

- 追加
    - データ保存をクラス作ってまとめる↓以下
        - タスクデータを保存する変数を都度作成
        - データ突っ込んで[String:[TaskData]]の辞書に保管
    - realm

```
class TaskData {
    var title: String
    var note: String {
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
        self.title = ""
        self.note = ""
        self.isChecked = false
    }
}
```
