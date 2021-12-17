package com.pachain.android.entity;

import java.util.ArrayList;

public class VotingOnionEntity {
    private String name;
    private ArrayList<OnionKeyEntity> keys;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public ArrayList<OnionKeyEntity> getKeys() {
        return keys;
    }

    public void setKeys(ArrayList<OnionKeyEntity> keys) {
        this.keys = keys;
    }
}
