# Todo

FolderごとのFile設定

    Folder新規追加時
    中身(空)をsaveData.set(fileNameArray, forKey: "\(folderName)")として保存

    表示時
    saveData.object(forKey: "\(folderName)")を表示

    File追加時
    saveData.set(fileNameArray, forKey: "\(folderName)")で上書き保存

画面遷移時の画面上部が黒い問題修正
