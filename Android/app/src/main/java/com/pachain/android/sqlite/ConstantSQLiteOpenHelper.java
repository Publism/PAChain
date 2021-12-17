package com.pachain.android.sqlite;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import com.pachain.android.common.InitData;

public class ConstantSQLiteOpenHelper extends SQLiteOpenHelper {

    public ConstantSQLiteOpenHelper(Context context, int version) {
        super(context.getApplicationContext(), "Constant.db", null, version);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        String sql = "CREATE TABLE States (ID Integer, Code Text, Name Text, PRIMARY KEY(ID));";;
        db.execSQL(sql);

        sql = "CREATE TABLE Counties (ID Integer, State Text, Number Text, Code Text, Name Text, ListOrder Integer, PRIMARY KEY(ID))";
        db.execSQL(sql);

        sql = "CREATE TABLE Parties (ID Integer, Code Text, Name Text, ListOrder Integer, PRIMARY KEY(Name))";
        db.execSQL(sql);

        sql = "CREATE TABLE Precincts (State Text, County Text, Number Text, Name Text, ListOrder Integer PRIMARY KEY AUTOINCREMENT)";
        db.execSQL(sql);

        sql = "CREATE TABLE Links (State Text, County Text, CountyNumber Text, Officials Text, RegisterLink Text, SOELink Text, PRIMARY KEY(CountyNumber))";
        db.execSQL(sql);

        new InitData(db);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

    }
}
