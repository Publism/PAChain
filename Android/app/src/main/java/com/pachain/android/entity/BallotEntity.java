package com.pachain.android.entity;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.ArrayList;

public class BallotEntity implements Serializable {
    @SerializedName("ballotno")
    private String number;
    @SerializedName("ballotdate")
    private String date;
    @SerializedName("ballotname")
    private String name;
    @SerializedName("isvoted")
    private boolean isVoted;
    @SerializedName("votingdate")
    private String votingDate;
    @SerializedName("isopenvoting")
    private boolean isStartCounting;
    @SerializedName("isconfirm")
    private boolean isVerified;
    @SerializedName("confirmdate")
    private String verifyDate;
    private boolean isExceededVoting;
    private boolean isSample;
    private boolean isVoting;
    private String election;
    private String electionKey;
    private ArrayList<CandidateEntity> candidates;

    public String getNumber() {
        return number;
    }

    public void setNumber(String number) {
        this.number = number;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public boolean isVoted() {
        return isVoted;
    }

    public void setVoted(boolean voted) {
        isVoted = voted;
    }

    public String getVotingDate() {
        return votingDate;
    }

    public void setVotingDate(String votingDate) {
        this.votingDate = votingDate;
    }

    public boolean isExceededVoting() {
        return isExceededVoting;
    }

    public void setExceededVoting(boolean exceededVoting) {
        isExceededVoting = exceededVoting;
    }

    public boolean isStartCounting() {
        return isStartCounting;
    }

    public void setStartCounting(boolean startCounting) {
        this.isStartCounting = startCounting;
    }

    public boolean isVerified() {
        return isVerified;
    }

    public void setVerified(boolean verified) {
        this.isVerified = verified;
    }

    public String getVerifyDate() {
        return verifyDate;
    }

    public void setVerifyDate(String verifyDate) {
        this.verifyDate = verifyDate;
    }

    public boolean isSample() {
        return isSample;
    }

    public void setSample(boolean sample) {
        isSample = sample;
    }

    public boolean isVoting() {
        return isVoting;
    }

    public void setVoting(boolean voting) {
        isVoting = voting;
    }

    public String getElection() {
        return election;
    }

    public void setElection(String election) {
        this.election = election;
    }

    public String getElectionKey() {
        return electionKey;
    }

    public void setElectionKey(String electionKey) {
        this.electionKey = electionKey;
    }

    public ArrayList<CandidateEntity> getCandidates() {
        return candidates;
    }

    public void setCandidates(ArrayList<CandidateEntity> candidates) {
        this.candidates = candidates;
    }
}
