package com.pachain.android.util;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;

public class ImportDBFileUtil {
    private Context context;
    private static String DATABASE_PATH;
    private static String DATABASE_NAME = "Constant.db";
    private static String dbFileName;
    private SDCardFileUtils sdCardFileUtils;

    public ImportDBFileUtil(Context context) {
        this.context = context.getApplicationContext();
        this.DATABASE_PATH = "/data/data/" + context.getPackageName() + "/databases";
        this.dbFileName = DATABASE_PATH + "/" + DATABASE_NAME;
        this.sdCardFileUtils = new SDCardFileUtils(context);
    }

    public void copyToSDCard() {
        String filePath = "databases/";
        if (sdCardFileUtils.isFileExist(filePath + DATABASE_NAME)) {
            sdCardFileUtils.deleteFile(filePath + DATABASE_NAME);
        }
        InputStream inputStream = null;
        try {
            inputStream = new FileInputStream(dbFileName);
            sdCardFileUtils.write2SDFromInput(filePath, DATABASE_NAME, inputStream);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }

    public void restoreDB() {
        File sdFile = sdCardFileUtils.readFileFromSD("databases/", DATABASE_NAME);
        SQLiteDatabase sqLiteDatabase = SQLiteDatabase.openOrCreateDatabase(sdFile, null);
    }
}
