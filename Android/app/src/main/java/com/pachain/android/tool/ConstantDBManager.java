package com.pachain.android.tool;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import com.pachain.android.config.Config;
import com.pachain.android.sqlite.ConstantSQLiteOpenHelper;

public class ConstantDBManager {
    private static ConstantSQLiteOpenHelper helper;
    private static SQLiteDatabase db;
    private static int mCount;
    private static ConstantDBManager mManagerInstance;

    private ConstantDBManager(Context context) {
        helper = new ConstantSQLiteOpenHelper(context, Config.CONSTANT_DB_VERSION);
    }

    public static synchronized ConstantDBManager getInstance(Context context){
        if(mManagerInstance == null){
            return new ConstantDBManager(context);
        }
        return mManagerInstance;
    }

    public synchronized SQLiteDatabase openDb(){
        if(mCount == 0){
            db = helper.getWritableDatabase();
        }
        mCount++;
        return db;
    }

    public synchronized void closeDb(SQLiteDatabase database){
        mCount--;
        if(mCount == 0){
            database.close();
        }
    }
}
