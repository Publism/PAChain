package com.pachain.android.common;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import com.google.gson.Gson;
import com.pachain.android.entity.VoterEntity;
import com.pachain.android.tool.DBManager;
import com.pachain.android.util.Secp256k1Utils;
import org.json.JSONArray;
import org.json.JSONObject;
import java.security.PrivateKey;
import java.util.HashMap;
import java.util.Map;

public class DataToolPackage {
    private DBManager dbManager;
    private SQLiteDatabase database;
    private Context context;
    private Gson gson;
    private Secp256k1Utils ecKeyUtil;
    private Map<String, Object> ecKey;

    public DataToolPackage(Context context, DBManager dbManager, Secp256k1Utils ecKeyUtil, Map<String, Object> ecKey) {
        this.context = context;
        this.dbManager = dbManager;
        this.gson = new Gson();
        this.ecKeyUtil = ecKeyUtil;
        this.ecKey = ecKey;
    }

    public HashMap<String, JSONObject> getLocalVotes(String election) {
        HashMap<String, JSONObject> votes = new HashMap<>();
        JSONObject data;
        database = dbManager.openDb();
        Cursor cursor = database.rawQuery("SELECT * FROM EncryptData WHERE DataType='VotingBallot_" + election + "'", null);
        while (cursor.moveToNext()) {
            try {
                data = new JSONObject(ecKeyUtil.decryptByPrivateKey(cursor.getString(cursor.getColumnIndex("Value")), (PrivateKey) ecKey.get("privateKey")));
                votes.put(data.getString("ballotNumber").toLowerCase(), data);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        cursor.close();
        dbManager.closeDb(database);
        return votes;
    }

    public boolean checkVerify(String election) {
        boolean verified = false;
        JSONObject data;
        database = dbManager.openDb();
        Cursor cursor = database.rawQuery("SELECT * FROM EncryptData WHERE DataType='VerifyBallot_" + election + "'", null);
        while (cursor.moveToNext()) {
            try {
                data = new JSONObject(ecKeyUtil.decryptByPrivateKey(cursor.getString(cursor.getColumnIndex("Value")), (PrivateKey) ecKey.get("privateKey")));
                verified = true;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        cursor.close();
        dbManager.closeDb(database);
        return verified;
    }

    public VoterEntity getRegisteredVoter() {
        VoterEntity voter = null;
        String data = "";
        database = dbManager.openDb();
        Cursor cursor = database.rawQuery("SELECT * FROM EncryptData WHERE DataType='VoterInfo' LIMIT 1;", null);
        if (cursor.getCount() > 0) {
            while(cursor.moveToNext()) {
                try {
                    data = ecKeyUtil.decryptByPrivateKey(cursor.getString(cursor.getColumnIndex("Value")), (PrivateKey) ecKey.get("privateKey"));
                } catch (Exception e) {
                    e.printStackTrace();
                }
                voter = gson.fromJson(data, VoterEntity.class);
            }
        }
        cursor.close();
        dbManager.closeDb(database);
        return voter;
    }

    public HashMap<String, String> getVotedKeys(String election) {
        HashMap<String, String> keys = new HashMap<>();
        JSONArray array;
        JSONObject data;
        database = dbManager.openDb();
        Cursor cursor = database.rawQuery("SELECT * FROM EncryptData WHERE DataType='VotingBallotOnions_" + election + "'", null);
        while (cursor.moveToNext()) {
            try {
                array = new JSONArray(ecKeyUtil.decryptByPrivateKey(cursor.getString(cursor.getColumnIndex("Value")), (PrivateKey) ecKey.get("privateKey")));
                for (int i = 0; i < array.length(); i++) {
                    data = array.getJSONObject(i);
                    if (data.getInt("packageLevel") == 1) {
                        keys.put(data.getString("publicKey"), data.getString("onionKey"));
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        cursor.close();
        dbManager.closeDb(database);
        return keys;
    }
}
