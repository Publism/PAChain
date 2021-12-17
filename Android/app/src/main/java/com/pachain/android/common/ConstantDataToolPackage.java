package com.pachain.android.common;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import com.pachain.android.entity.CountyEntity;
import com.pachain.android.entity.PartyEntity;
import com.pachain.android.entity.PrecinctEntity;
import com.pachain.android.entity.StateEntity;
import com.pachain.android.tool.ConstantDBManager;
import java.util.ArrayList;
import java.util.HashMap;

public class ConstantDataToolPackage {
    private ConstantDBManager dbManager;
    private SQLiteDatabase database;
    private Context context;

    public ConstantDataToolPackage(Context context) {
        this.context = context;
        this.dbManager = ConstantDBManager.getInstance(context.getApplicationContext());;
    }

    public ArrayList<StateEntity> getStates() {
        ArrayList<StateEntity> states = new ArrayList<>();
        database = dbManager.openDb();
        Cursor cursor_states = database.rawQuery("SELECT * FROM States;", null);
        StateEntity state;
        while (cursor_states.moveToNext()) {
            state = new StateEntity();
            state.setId(cursor_states.getInt(cursor_states.getColumnIndex("ID")));
            state.setCode(cursor_states.getString(cursor_states.getColumnIndex("Code")));
            state.setName(cursor_states.getString(cursor_states.getColumnIndex("Name")));
            states.add(state);
        }
        cursor_states.close();
        dbManager.closeDb(database);
        return states;
    }

    public ArrayList<CountyEntity> getCounties() {
        ArrayList<CountyEntity> counties = new ArrayList<>();
        database = dbManager.openDb();
        Cursor cursor_counties = database.rawQuery("SELECT * FROM Counties ORDER BY ListOrder;", null);
        CountyEntity county;
        while (cursor_counties.moveToNext()) {
            county = new CountyEntity();
            county.setId(cursor_counties.getInt(cursor_counties.getColumnIndex("ID")));
            county.setCode(cursor_counties.getString(cursor_counties.getColumnIndex("Code")));
            county.setName(cursor_counties.getString(cursor_counties.getColumnIndex("Name")));
            county.setState(cursor_counties.getString(cursor_counties.getColumnIndex("State")));
            county.setNumber(cursor_counties.getString(cursor_counties.getColumnIndex("Number")));
            counties.add(county);
        }
        cursor_counties.close();
        dbManager.closeDb(database);
        return counties;
    }

    public HashMap<String, CountyEntity> getCountiesMap() {
        HashMap<String, CountyEntity> counties = new HashMap<>();
        database = dbManager.openDb();
        Cursor cursor_counties = database.rawQuery("SELECT * FROM Counties ORDER BY ListOrder;", null);
        CountyEntity county;
        while (cursor_counties.moveToNext()) {
            county = new CountyEntity();
            county.setId(cursor_counties.getInt(cursor_counties.getColumnIndex("ID")));
            county.setCode(cursor_counties.getString(cursor_counties.getColumnIndex("Code")));
            county.setName(cursor_counties.getString(cursor_counties.getColumnIndex("Name")));
            county.setState(cursor_counties.getString(cursor_counties.getColumnIndex("State")));
            county.setNumber(cursor_counties.getString(cursor_counties.getColumnIndex("Number")));
            counties.put(county.getNumber(), county);
        }
        cursor_counties.close();
        dbManager.closeDb(database);
        return counties;
    }

    public ArrayList<PrecinctEntity> getPrecincts(String state, String county) {
        ArrayList<PrecinctEntity> precincts = new ArrayList<>();
        database = dbManager.openDb();
        Cursor cursor = database.rawQuery("SELECT * FROM Precincts WHERE State='" + state + "' AND County='" + county.replace("'", "''") + "' ORDER BY ListOrder;", null);
        PrecinctEntity precinct;
        while (cursor.moveToNext()) {
            precinct = new PrecinctEntity();
            precinct.setState(cursor.getString(cursor.getColumnIndex("State")));
            precinct.setCounty(cursor.getString(cursor.getColumnIndex("County")));
            precinct.setNumber(cursor.getString(cursor.getColumnIndex("Number")));
            precinct.setName(cursor.getString(cursor.getColumnIndex("Name")));
            precincts.add(precinct);
        }
        cursor.close();
        dbManager.closeDb(database);
        return precincts;
    }

    public HashMap<String, PartyEntity> getParties() {
        HashMap<String, PartyEntity> parties = new HashMap<>();
        database = dbManager.openDb();
        Cursor cursor_parties = database.rawQuery("SELECT * FROM Parties", null);
        PartyEntity entity;
        while (cursor_parties.moveToNext()) {
            entity = new PartyEntity();
            entity.setId(cursor_parties.getInt(cursor_parties.getColumnIndex("ID")));
            entity.setCode(cursor_parties.getString(cursor_parties.getColumnIndex("Code")));
            entity.setName(cursor_parties.getString(cursor_parties.getColumnIndex("Name")));
            parties.put(entity.getName().toLowerCase(), entity);
        }
        cursor_parties.close();
        dbManager.closeDb(database);
        return parties;
    }

    public String getRegisterLink(String state, String county) {
        String link = "";
        database = dbManager.openDb();
        Cursor cursor = database.rawQuery("SELECT * FROM Links WHERE State='" + state + "' AND CountyNumber='" + county + "'", null);
        while (cursor.moveToNext()) {
            link = cursor.getString(cursor.getColumnIndex("RegisterLink"));
        }
        cursor.close();
        dbManager.closeDb(database);
        return link;
    }

    public String getOfficialsLink(String state, String county) {
        String link = "";
        database = dbManager.openDb();
        Cursor cursor = database.rawQuery("SELECT * FROM Links WHERE State='" + state + "' AND CountyNumber='" + county + "'", null);
        while (cursor.moveToNext()) {
            link = cursor.getString(cursor.getColumnIndex("Officials"));
        }
        cursor.close();
        dbManager.closeDb(database);
        return link;
    }

    public String getSOELink(String state, String county) {
        String link = "";
        database = dbManager.openDb();
        Cursor cursor = database.rawQuery("SELECT * FROM Links WHERE State='" + state + "' AND CountyNumber='" + county + "'", null);
        while (cursor.moveToNext()) {
            link = cursor.getString(cursor.getColumnIndex("SOELink"));
        }
        cursor.close();
        dbManager.closeDb(database);
        return link;
    }
}
