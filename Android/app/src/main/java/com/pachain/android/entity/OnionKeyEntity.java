package com.pachain.android.entity;

public class OnionKeyEntity {
    private String encryptPublicKey;
    private String personalPublicKey;

    public String getEncryptPublicKey() {
        return encryptPublicKey;
    }

    public void setEncryptPublicKey(String encryptPublicKey) {
        this.encryptPublicKey = encryptPublicKey;
    }

    public String getPersonalPublicKey() {
        return personalPublicKey;
    }

    public void setPersonalPublicKey(String personalPublicKey) {
        this.personalPublicKey = personalPublicKey;
    }
}
