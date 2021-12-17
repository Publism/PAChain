package com.pachain.android.entity;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class InvitationEntity implements Serializable {
    @SerializedName("ballotdate")
    private String electionDate;
    @SerializedName("ballotname")
    private String electionName;
    @SerializedName("ballotno")
    private String ballotNumber;
    private int status;
    @SerializedName("invitedate")
    private String inviteDate;
    @SerializedName("actiondate")
    private String responseDate;
    private String electionKey;

    public String getElectionDate() {
        return electionDate;
    }

    public void setElectionDate(String electionDate) {
        this.electionDate = electionDate;
    }

    public String getElectionName() {
        return electionName;
    }

    public void setElectionName(String electionName) {
        this.electionName = electionName;
    }

    public String getBallotNumber() {
        return ballotNumber;
    }

    public void setBallotNumber(String ballotNumber) {
        this.ballotNumber = ballotNumber;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public String getInviteDate() {
        return inviteDate;
    }

    public void setInviteDate(String inviteDate) {
        this.inviteDate = inviteDate;
    }

    public String getResponseDate() {
        return responseDate;
    }

    public void setResponseDate(String responseDate) {
        this.responseDate = responseDate;
    }

    public String getElectionKey() {
        return electionKey;
    }

    public void setElectionKey(String electionKey) {
        this.electionKey = electionKey;
    }
}
