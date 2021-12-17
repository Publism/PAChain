package com.pachain.android.entity;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class ElectionEntity implements Serializable {
    @SerializedName("electionid")
    private int id;
    @SerializedName("electionname")
    private String name;
    @SerializedName("electiondate")
    private String date;
    @SerializedName("electionstate")
    private String state;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }
}
