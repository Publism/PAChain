package com.pachain.android.entity;

import com.google.gson.annotations.SerializedName;

public class VotedResultEntity {
    private String key;
    private String verificationCode;
    @SerializedName(value = "votingResult", alternate = { "candidateID", "candidateName" })
    private String votingResult;
    private String votingDate;
    private boolean selected;

    public VotedResultEntity(String key, String verificationCode, String votingResult, String votingDate, boolean selected) {
        super();
        this.key = key;
        this.verificationCode = verificationCode;
        this.votingResult = votingResult;
        this.votingDate = votingDate;
        this.selected = selected;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getVerificationCode() {
        return verificationCode;
    }

    public void setVerificationCode(String verificationCode) {
        this.verificationCode = verificationCode;
    }

    public String getVotingResult() {
        return votingResult;
    }

    public void setVotingResult(String votingResult) {
        this.votingResult = votingResult;
    }

    public String getVotingDate() {
        return votingDate;
    }

    public void setVotingDate(String votingDate) {
        this.votingDate = votingDate;
    }

    public boolean isSelected() {
        return selected;
    }

    public void setSelected(boolean selected) {
        this.selected = selected;
    }
}
