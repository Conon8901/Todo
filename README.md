# Todo

画面遷移時の画面上部が黒い問題修正

    Yattyから受け取り

Folder名称を変更するとFileが消える問題修正
    
    新名称でキーを作り元名称の要素を追加
    元キーは削除
    ↓
    showDict[新名称] = 旧名称の要素
    showDict[旧名称] = nil
    ↓
    showDict[String(folderNameArray[indexPath.row])] = showDict[before]
    showDict[before] = nil
