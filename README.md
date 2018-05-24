# Todo

- 追加
    - レ"期限指定をカレンダー表示
    - データ保存をクラス作ってまとめる
    - レ"通知
    - realm

```
class TaskData {
//from here
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
//to here
var isShown: Bool {
didSet {
UserDefaults.standard.set(TaskData.self, forKey: fileName)
}
}
var dueDate: Date? {
didSet {
UserDefaults.standard.set(TaskData.self, forKey: fileName)
}
}

func resave(oldKey: String, newKey: String) {
UserDefaults.standard.removeObject(forKey: oldKey)
UserDefaults.standard.set(TaskData.self, forKey: newKey)
}

init() {
self.fileName = ""
self.noteText = ""
self.isShown = false
self.isChecked = false
}
}
```
