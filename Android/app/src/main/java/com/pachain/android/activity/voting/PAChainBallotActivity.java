package com.pachain.android.activity.voting;

import android.app.Activity;
import android.content.ContentValues;
import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.pachain.android.activity.viewresults.PAChainViewVotingProgressActivity;
import com.pachain.android.adapter.voting.BallotHomeAdapter;
import com.pachain.android.common.DataToolPackage;
import com.pachain.android.common.ToolPackage;
import com.pachain.android.config.Constants;
import com.pachain.android.entity.BallotEntity;
import com.pachain.android.entity.CandidateEntity;
import com.pachain.android.tool.DBManager;
import com.pachain.android.util.Secp256k1Utils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.security.PublicKey;
import java.util.HashMap;
import java.util.Map;

public class PAChainBallotActivity extends Activity implements View.OnClickListener {
    private TextView tv_back;
    private TextView tv_title;
    private ListView lv_contents;
    private LinearLayout ll_toolBar;
    private TextView tv_save;
    private TextView tv_cancel;
    private TextView tv_submit;

    private BallotEntity ballot;
    private BallotHomeAdapter adapter;
    private JSONArray votes;

    private DBManager dbManager;
    private DataToolPackage dataToolPackage;
    private SQLiteDatabase database;
    private Secp256k1Utils ecKeyUtil;
    private Map<String, Object> ecKey;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(getResources().getIdentifier("pachain_activity_ballot", "layout", getPackageName()));

        tv_back = findViewById(getResources().getIdentifier("tv_back", "id", getPackageName()));
        tv_back.setOnClickListener(this);
        tv_title = findViewById(getResources().getIdentifier("tv_title", "id", getPackageName()));
        tv_title.setText(getResources().getString(getResources().getIdentifier("gotv_myBallots", "string", getPackageName())));
        lv_contents = findViewById(getResources().getIdentifier("lv_contents", "id", getPackageName()));
        ll_toolBar = findViewById(getResources().getIdentifier("ll_toolBar", "id", getPackageName()));
        tv_save = findViewById(getResources().getIdentifier("tv_save", "id", getPackageName()));
        tv_save.setOnClickListener(this);
        tv_cancel = findViewById(getResources().getIdentifier("tv_cancel", "id", getPackageName()));
        tv_cancel.setOnClickListener(this);
        tv_submit = findViewById(getResources().getIdentifier("tv_submit", "id", getPackageName()));
        tv_submit.setOnClickListener(this);

        ballot = (BallotEntity) getIntent().getExtras().getSerializable("ballot");

        ecKeyUtil = new Secp256k1Utils(this);
        ecKey = ecKeyUtil.getKeyPair();

        dbManager = DBManager.getInstance(getApplicationContext());
        dataToolPackage = new DataToolPackage(getApplicationContext(), dbManager, ecKeyUtil, ecKey);
        HashMap<String, JSONObject> localVotes = dataToolPackage.getLocalVotes(ballot.getElection());
        if (localVotes.containsKey(ballot.getNumber().toLowerCase())) {
            try {
                JSONObject localVote = localVotes.get(ballot.getNumber().toLowerCase());
                JSONArray votes = new JSONArray(localVote.getString("votes"));
                if (ballot.isVoted() && localVote.getString("status").equals("Draft")) {
                } else {
                    if (localVote.getString("status").equals("Draft")) {
                        ballot.setVoted(false);
                        ballot.setVoting(true);
                    } else {
                        ballot.setVoted(true);
                        ballot.setVoting(false);
                    }

                    JSONObject vote, candidate;
                    JSONArray candidates;
                    for (CandidateEntity candidateEntity : ballot.getCandidates()) {
                        if (candidateEntity.getId() < 1 && (candidateEntity.getSeat() == null || candidateEntity.getSeat().getId() < 1) &&
                                candidateEntity.getElection() != null && candidateEntity.getElection().getId() > 0) {
                            candidateEntity.setVoting(ballot.isVoting());
                            candidateEntity.setVoted(ballot.isVoted());
                        } else if (candidateEntity.getId() > 0) {
                            candidateEntity.setVoting(ballot.isVoting());
                            for (int m = 0; m < votes.length(); m++) {
                                vote = votes.getJSONObject(m);
                                candidates = new JSONArray(vote.getString("candidates"));
                                for (int d = 0; d < candidates.length(); d++) {
                                    candidate = candidates.getJSONObject(d);
                                    if (candidate.getInt("id") == candidateEntity.getId()
                                            && candidateEntity.getElection().getId() == vote.getInt("electionID")
                                            && candidateEntity.getSeat().getId() == vote.getInt("seatID")) {
                                        candidateEntity.setVoted(true);
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        if (ballot.isVoting()) {
            ll_toolBar.setVisibility(View.VISIBLE);
            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            layoutParams.setMargins(0, 0, 0, 165);
            lv_contents.setLayoutParams(layoutParams);
        }

        adapter = new BallotHomeAdapter(this, ballot.getCandidates());
        lv_contents.setAdapter(adapter);
        adapter.setOnItemClickListener(new BallotHomeAdapter.OnItemClickListener() {
            @Override
            public void onVoteClick(View view, int i) {
                ll_toolBar.setVisibility(View.VISIBLE);
                RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                layoutParams.setMargins(0, 0, 0, 165);
                lv_contents.setLayoutParams(layoutParams);
            }

            @Override
            public void onViewProgressClick(View view, int i) {
                Intent intent = new Intent(PAChainBallotActivity.this, PAChainViewVotingProgressActivity.class);
                intent.putExtra("ballot", ballot);
                startActivity(intent);
            }
        });
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == getResources().getIdentifier("tv_back", "id", getPackageName())) {
            finish();
        } else if (v.getId() == getResources().getIdentifier("tv_save", "id", getPackageName())) {
            int unCheckCount = checkVotes();
            if (votes != null && votes.length() > 0) {
                try {
                    database = dbManager.openDb();
                    database.delete(Constants.TABLE_ENCRYPTDATA, "DataType=?", new String[] { "VotingBallot_" + ballot.getElection() });

                    JSONObject encryptObject = new JSONObject();
                    encryptObject.put("ballotNumber", ballot.getNumber());
                    encryptObject.put("votes", votes);
                    encryptObject.put("votingDate", ToolPackage.getDateNow());
                    encryptObject.put("status", "Draft");

                    ContentValues values = new ContentValues();
                    values.put("DataType", "VotingBallot_" + ballot.getElection());
                    values.put("Value", ecKeyUtil.encryptByPublicKey(encryptObject.toString(), (PublicKey) ecKey.get("publicKey")));
                    database.insert(Constants.TABLE_ENCRYPTDATA, null, values);
                    dbManager.closeDb(database);

                    Toast.makeText(PAChainBallotActivity.this, getResources().getString(getResources().getIdentifier("ballot_saveSuccess", "string", getPackageName())), Toast.LENGTH_LONG).show();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } else if (v.getId() == getResources().getIdentifier("tv_cancel", "id", getPackageName())) {
            for (CandidateEntity candidateEntity : ballot.getCandidates()) {
                candidateEntity.setVoting(false);
                if (candidateEntity.isVoted()) {
                    candidateEntity.setVoted(false);
                }
            }
            adapter.notifyDataSetChanged();

            ll_toolBar.setVisibility(View.GONE);
            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            layoutParams.setMargins(0, 0, 0, 0);
            lv_contents.setLayoutParams(layoutParams);
        } else if (v.getId() == getResources().getIdentifier("tv_submit", "id", getPackageName())) {
            int unCheckCount = checkVotes();
            if (unCheckCount > 0) {
                Toast.makeText(PAChainBallotActivity.this, unCheckCount + " " + getResources().getString(getResources().getIdentifier("ballot_voteMissing", "string", getPackageName())), Toast.LENGTH_SHORT).show();
            } else {
                Intent intent = new Intent(PAChainBallotActivity.this, PAChainVotingActivity.class);
                intent.putExtra("ballotno", ballot.getNumber());
                intent.putExtra("votes", votes.toString());
                intent.putExtra("election", ballot.getElection());
                intent.putExtra("electionKey", ballot.getElectionKey());
                startActivityForResult(intent, 1);
            }
        }
    }

    private int checkVotes() {
        votes = new JSONArray();
        JSONArray checkedCandidates = new JSONArray();
        JSONObject voteObject, candidateObject;
        int unCheckCount = 0;
        int checkEveryCount = 0;
        int lastSeatID = 0, lastSeatVoteLimit = 0, lastElectionID = 0;
        for (int i = 0; i < adapter.getCount(); i++) {
            CandidateEntity candidateEntity = (CandidateEntity) adapter.getItem(i);
            if (candidateEntity.getId() > 0) {
                if (lastSeatID > 0 && lastSeatID != candidateEntity.getSeat().getId()) {
                    if (checkEveryCount != lastSeatVoteLimit) {
                        unCheckCount++;
                    }
                    checkEveryCount = 0;
                }
                if (lastSeatID > 0 && lastSeatID != candidateEntity.getSeat().getId() && checkedCandidates != null && checkedCandidates.length() > 0) {
                    try {
                        boolean exists = false;
                        for (int m = 0; m < votes.length(); m++) {
                            if (votes.getJSONObject(m).getInt("electionID") == lastElectionID && votes.getJSONObject(m).getInt("seatID") == lastSeatID) {
                                exists = true;
                                votes.getJSONObject(m).put("candidates", checkedCandidates);
                                break;
                            }
                        }
                        if (!exists) {
                            voteObject = new JSONObject();
                            voteObject.put("electionID", lastElectionID);
                            voteObject.put("seatID", lastSeatID);
                            voteObject.put("candidates", checkedCandidates);
                            votes.put(voteObject);
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    checkedCandidates = new JSONArray();
                }
                if (candidateEntity.isVoted()) {
                    checkEveryCount++;
                    candidateObject = new JSONObject();
                    try {
                        candidateObject.put("id", candidateEntity.getId());
                        candidateObject.put("name", candidateEntity.getName());
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    checkedCandidates.put(candidateObject);
                }
                lastSeatID = candidateEntity.getSeat().getId();
                lastSeatVoteLimit = 1;
                lastElectionID = candidateEntity.getElection().getId();
            }
            if (i == adapter.getCount() - 1) {
                if (checkedCandidates != null && checkedCandidates.length() > 0) {
                    try {
                        boolean exists = false;
                        for (int m = 0; m < votes.length(); m++) {
                            if (votes.getJSONObject(m).getInt("electionID") == lastElectionID && votes.getJSONObject(m).getInt("seatID") == lastSeatID) {
                                exists = true;
                                votes.getJSONObject(m).put("candidates", checkedCandidates);
                                break;
                            }
                        }
                        if (!exists) {
                            voteObject = new JSONObject();
                            voteObject.put("electionID", lastElectionID);
                            voteObject.put("seatID", lastSeatID);
                            voteObject.put("candidates", checkedCandidates);
                            votes.put(voteObject);
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                if (checkEveryCount != lastSeatVoteLimit) {
                    unCheckCount++;
                }
            }
        }
        return unCheckCount;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (data == null || data.getExtras() == null) {
            return;
        }
        Bundle bundle = data.getExtras();
        if (bundle.containsKey("votedSuccess") && bundle.getBoolean("votedSuccess")) {
            try {
                JSONObject vote, candidate;
                JSONArray candidates;
                for (CandidateEntity candidateEntity : ballot.getCandidates()) {
                    if (candidateEntity.getId() < 1 && (candidateEntity.getSeat() == null || candidateEntity.getSeat().getId() < 1) &&
                            candidateEntity.getElection() != null && candidateEntity.getElection().getId() > 0) {
                        candidateEntity.setVoted(true);
                        candidateEntity.setVoting(false);
                    } else if (candidateEntity.getId() > 0) {
                        candidateEntity.setVoting(false);
                        for (int m = 0; m < votes.length(); m++) {
                            vote = votes.getJSONObject(m);
                            candidates = new JSONArray(vote.getString("candidates"));
                            for (int d = 0; d < candidates.length(); d++) {
                                candidate = candidates.getJSONObject(d);
                                if (candidate.getInt("id") == candidateEntity.getId()
                                        && candidateEntity.getElection().getId() == vote.getInt("electionID")
                                        && candidateEntity.getSeat().getId() == vote.getInt("seatID")) {
                                    candidateEntity.setVoted(true);
                                }
                            }
                        }
                    }
                }
                adapter.notifyDataSetChanged();

                ll_toolBar.setVisibility(View.GONE);
                RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                layoutParams.setMargins(0, 0, 0, 0);
                lv_contents.setLayoutParams(layoutParams);
            } catch (Exception ex) {
            }
        }
    }

}
