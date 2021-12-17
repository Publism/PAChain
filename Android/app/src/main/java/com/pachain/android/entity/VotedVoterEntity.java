package com.pachain.android.entity;

import com.google.gson.annotations.SerializedName;

public class VotedVoterEntity {
    private String state;
    private String county;
    private String precinctNumber;
    @SerializedName("count")
    private String votedCount;
    private String votingDate;

    public VotedVoterEntity(String state, String county, String precinctNumber, String votedCount, String votingDate) {
        super();
        this.state = state;
        this.county = county;
        this.precinctNumber = precinctNumber;
        this.votedCount = votedCount;
        this.votingDate = votingDate;
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

    public String getVotedCount() {
        return votedCount;
    }

    public void setVotedCount(String votedCount) {
        this.votedCount = votedCount;
    }

    public String getVotingDate() {
        return votingDate;
    }

    public void setVotingDate(String votingDate) {
        this.votingDate = votingDate;
    }
}
