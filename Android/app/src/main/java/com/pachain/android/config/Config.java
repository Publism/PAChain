package com.pachain.android.config;

public class Config {
    public final static int DB_VERSION = 1;
    public final static int CONSTANT_DB_VERSION = 1;

    public final static String PROJECT_BASE_URL = "Server api url";
    public final static String CONTROLLER = "api/";
    public final static String GET_ENCRYPTKEY = PROJECT_BASE_URL + CONTROLLER + "getpublickey";
    public final static String UPLOAD_PHOTO = PROJECT_BASE_URL + CONTROLLER + "voter/updateimage";
    public final static String SEND_VERIFICATIONCODE = PROJECT_BASE_URL + CONTROLLER + "voter/sendsmsmessage";
    public final static String REGISTER = PROJECT_BASE_URL + CONTROLLER + "voter/register";
    public final static String VERIFY_VOTER = PROJECT_BASE_URL + CONTROLLER + "voter/verify";
    public final static String GET_INVITATION = PROJECT_BASE_URL + CONTROLLER + "ballots/getvoteinvitestatus";
    public final static String RESPONSE_INVITATION = PROJECT_BASE_URL + CONTROLLER + "ballots/setvoteinvite";
    public final static String GET_BALLOTS = PROJECT_BASE_URL + CONTROLLER + "ballots/getballots";
    public final static String GET_SAMPLEBALLOTS = PROJECT_BASE_URL + CONTROLLER + "ballots/getsampleballot";
    public final static String GET_ONIONKEYS = PROJECT_BASE_URL + CONTROLLER + "ballots/getonionkeys";
    public final static String VOTE = PROJECT_BASE_URL + CONTROLLER + "voted/vote";
    public final static String VERIFY_BALLOT = PROJECT_BASE_URL + CONTROLLER + "voted/confirmvoted";

    public final static String GET_SEATS = PROJECT_BASE_URL + CONTROLLER + "ballots/queryseatsbyelectionid";
    public final static String QUERY_VOTEDVOTERS = PROJECT_BASE_URL + CONTROLLER + "voted/queryvoted";
    public final static String QUERY_VOTERRESULTS = PROJECT_BASE_URL + CONTROLLER + "voted/queryvoteresult";
    public final static String GET_VOTERESULTS = PROJECT_BASE_URL + CONTROLLER + "voted/getvoteresult";
}
