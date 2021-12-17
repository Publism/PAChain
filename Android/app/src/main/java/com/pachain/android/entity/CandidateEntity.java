package com.pachain.android.entity;

import com.google.gson.annotations.SerializedName;
import java.io.Serializable;
import java.util.HashMap;

public class CandidateEntity implements Serializable {
    @SerializedName("candidateid")
    private int id;
    private String name;
    private String party;
    private String partyCode;
    private String photo;
    private int voteBallots;
    private double voteRate;

    private ElectionEntity election;
    private SeatEntity seat;

    private boolean isVoted;
    private boolean isVoting;
    private boolean isExceededVoting;
    private boolean isSampleBallot;
    private HashMap<String, String> params;

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

    public String getParty() {
        return party;
    }

    public void setParty(String party) {
        this.party = party;
    }

    public String getPartyCode() {
        return partyCode;
    }

    public void setPartyCode(String partyCode) {
        this.partyCode = partyCode;
    }

    public String getPhoto() {
        return photo;
    }

    public void setPhoto(String photo) {
        this.photo = photo;
    }

    public HashMap<String, String> getParams() {
        return params;
    }

    public void setParams(HashMap<String, String> params) {
        this.params = params;
    }

    public ElectionEntity getElection() {
        return election;
    }

    public void setElection(ElectionEntity election) {
        this.election = election;
    }

    public SeatEntity getSeat() {
        return seat;
    }

    public void setSeat(SeatEntity seat) {
        this.seat = seat;
    }

    public boolean isVoted() {
        return isVoted;
    }

    public void setVoted(boolean voted) {
        this.isVoted = voted;
    }

    public boolean isVoting() {
        return isVoting;
    }

    public void setVoting(boolean voting) {
        this.isVoting = voting;
    }

    public boolean isExceededVoting() {
        return isExceededVoting;
    }

    public void setExceededVoting(boolean exceededVoting) {
        this.isExceededVoting = exceededVoting;
    }

    public int getVoteBallots() {
        return voteBallots;
    }

    public void setVoteBallots(int voteBallots) {
        this.voteBallots = voteBallots;
    }

    public double getVoteRate() {
        return voteRate;
    }

    public void setVoteRate(double voteRate) {
        this.voteRate = voteRate;
    }

    public boolean isSampleBallot() {
        return isSampleBallot;
    }

    public void setSampleBallot(boolean sampleBallot) {
        this.isSampleBallot = sampleBallot;
    }
}
