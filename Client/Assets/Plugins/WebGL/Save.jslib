mergeInto(LibraryManager.library, {
    //ˢ�����ݵ�IndexedDB
    SyncDB: function () {
        FS.syncfs(false, function (err) {
           if (err) console.log("syncfs error: " + err);
        });
    }
});