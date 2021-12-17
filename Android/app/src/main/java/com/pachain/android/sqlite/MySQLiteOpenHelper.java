package com.pachain.android.sqlite;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class MySQLiteOpenHelper extends SQLiteOpenHelper {

    public MySQLiteOpenHelper(Context context, int version) {
        super(context.getApplicationContext(), "PAChain.db", null, version);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        String sql = "CREATE TABLE Users (VoterID Text, PublicKey Text, State Text, County Text, PrecinctNumber Text, FirstName Text, MiddleName Text, LastName Text, " +
            "NameSuffix Text, CellPhone Text, Email Text, Address Text, Signature Text, CertificateType Text, CertificateFront Text, CertificateBack Text, " +
            "FacePhoto Text, EnableFingerprint Integer, RegisteredDate Text, VerifiedDate Text, AccessToken Text, PRIMARY KEY(VoterID))";
        db.execSQL(sql);

        sql = "CREATE TABLE VotingBallot (BallotNumber Text, Votes Text, VerificationCode Text, VotingDate Text, PRIMARY KEY(BallotNumber))";
        db.execSQL(sql);

        sql = "CREATE TABLE VotingBallotOnions (BallotNumber Text, OnionKey Text, PublicKey Text, PackageLevel Integer)";
        db.execSQL(sql);

        sql = "CREATE TABLE VerifyBallot (BallotNumber Text, VerifyDate Text, PRIMARY KEY(BallotNumber))";
        db.execSQL(sql);

        sql = "CREATE TABLE EncryptData (DataType Text, Value Text, PRIMARY KEY(DataType))";
        db.execSQL(sql);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

    }
}
