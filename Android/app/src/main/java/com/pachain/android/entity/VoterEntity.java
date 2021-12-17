package com.pachain.android.entity;

public class VoterEntity {
    private Long voterID;
    private String publicKey;
    private String state;
    private String county;
    private String precinctNumber;
    private String firstName;
    private String middleName;
    private String lastName;
    private String nameSuffix;
    private String cellPhone;
    private String email;
    private String address;
    private String signature;
    private String certificateType;
    private String certificateFront;
    private String certificateBack;
    private String facePhoto;
    private boolean isEnableFingerprint;
    private String registeredDate;
    private String verifiedDate;
    private String accessToken;

    public Long getVoterID() {
        return voterID;
    }

    public void setVoterID(Long voterID) {
        this.voterID = voterID;
    }

    public String getPublicKey() {
        return publicKey;
    }

    public void setPublicKey(String publicKey) {
        this.publicKey = publicKey;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getCounty() {
        return county;
    }

    public void setCounty(String county) {
        this.county = county;
    }

    public String getPrecinctNumber() {
        return precinctNumber;
    }

    public void setPrecinctNumber(String precinctNumber) {
        this.precinctNumber = precinctNumber;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getMiddleName() {
        return middleName;
    }

    public void setMiddleName(String middleName) {
        this.middleName = middleName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getNameSuffix() {
        return nameSuffix;
    }

    public void setNameSuffix(String nameSuffix) {
        this.nameSuffix = nameSuffix;
    }

    public String getCellPhone() {
        return cellPhone;
    }

    public void setCellPhone(String cellPhone) {
        this.cellPhone = cellPhone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getSignature() {
        return signature;
    }

    public void setSignature(String signature) {
        this.signature = signature;
    }

    public String getCertificateType() {
        return certificateType;
    }

    public void setCertificateType(String certificateType) {
        this.certificateType = certificateType;
    }

    public String getCertificateFront() {
        return certificateFront;
    }

    public void setCertificateFront(String certificateFront) {
        this.certificateFront = certificateFront;
    }

    public String getCertificateBack() {
        return certificateBack;
    }

    public void setCertificateBack(String certificateBack) {
        this.certificateBack = certificateBack;
    }

    public String getFacePhoto() {
        return facePhoto;
    }

    public void setFacePhoto(String facePhoto) {
        this.facePhoto = facePhoto;
    }

    public boolean isEnableFingerprint() {
        return isEnableFingerprint;
    }

    public void setEnableFingerprint(boolean enableFingerprint) {
        isEnableFingerprint = enableFingerprint;
    }

    public String getRegisteredDate() {
        return registeredDate;
    }

    public void setRegisteredDate(String registeredDate) {
        this.registeredDate = registeredDate;
    }

    public String getVerifiedDate() {
        return verifiedDate;
    }

    public void setVerifiedDate(String verifiedDate) {
        this.verifiedDate = verifiedDate;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }
}
