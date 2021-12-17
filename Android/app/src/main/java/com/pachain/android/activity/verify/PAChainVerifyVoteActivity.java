package com.pachain.android.activity.verify;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.ContentValues;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Base64;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import com.biometric.manager.FingerManager;
import com.biometric.manager.callback.SimpleFingerCallback;
import com.pachain.android.adapter.voting.BallotHomeAdapter;
import com.pachain.android.common.DataToolPackage;
import com.pachain.android.common.PostApi;
import com.pachain.android.common.ToolPackage;
import com.pachain.android.config.Config;
import com.pachain.android.config.Constants;
import com.pachain.android.entity.BallotEntity;
import com.pachain.android.entity.CandidateEntity;
import com.pachain.android.entity.VoterEntity;
import com.pachain.android.tool.DBManager;
import com.pachain.android.util.SPUtils;
import com.pachain.android.util.Secp256k1Utils;
import com.pachain.android.util.Secp256r1KeyStoreUtils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.net.URLEncoder;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import androidx.appcompat.app.AppCompatActivity;

public class PAChainVerifyVoteActivity extends AppCompatActivity implements View.OnClickListener {
    private RelativeLayout rl_confirm;
    private TextView tv_back;
    private TextView tv_title;
    private ListView lv_contents;
    private LinearLayout ll_toolBar;
    private TextView tv_yes;
    private TextView tv_no;
    private LinearLayout ll_verify;
    private EditText et_verificationCode;
    private TextView tv_verifyMobile_next;
    private TextView tv_requestNewCode;

    private BallotEntity ballot;
    private BallotHomeAdapter adapter;

    private DBManager dbManager;
    private SQLiteDatabase database;
    private DataToolPackage dataToolPackage;
    private int verificationCode;
    private boolean requestNewCode;
    private boolean verified;
    private VoterEntity registeredVoter;
    private ProgressDialog progressDialog;

    private Secp256k1Utils ecKeyUtil;
    private Map<String, Object> ecKey;
    private Secp256r1KeyStoreUtils myKeyUtil;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(getResources().getIdentifier("pachain_activity_verifyvote", "layout", getPackageName()));

        rl_confirm = findViewById(getResources().getIdentifier("rl_confirm", "id", getPackageName()));
        tv_back = findViewById(getResources().getIdentifier("tv_back", "id", getPackageName()));
        tv_back.setOnClickListener(this);
        tv_title = findViewById(getResources().getIdentifier("tv_title", "id", getPackageName()));
        tv_title.setText(getResources().getString(getResources().getIdentifier("verifyVote_title", "string", getPackageName())));
        lv_contents = findViewById(getResources().getIdentifier("lv_contents", "id", getPackageName()));
        ll_toolBar = findViewById(getResources().getIdentifier("ll_toolBar", "id", getPackageName()));
        tv_yes = findViewById(getResources().getIdentifier("tv_yes", "id", getPackageName()));
        tv_yes.setOnClickListener(this);
        tv_no = findViewById(getResources().getIdentifier("tv_no", "id", getPackageName()));
        tv_no.setOnClickListener(this);
        ll_verify = findViewById(getResources().getIdentifier("ll_verify", "id", getPackageName()));
        et_verificationCode = findViewById(getResources().getIdentifier("et_verificationCode", "id", getPackageName()));
        tv_verifyMobile_next = findViewById(getResources().getIdentifier("tv_verifyMobile_next", "id", getPackageName()));
        tv_verifyMobile_next.setOnClickListener(this);
        tv_requestNewCode = findViewById(getResources().getIdentifier("tv_requestNewCode", "id", getPackageName()));
        tv_requestNewCode.setOnClickListener(this);

        requestNewCode = false;
        verificationCode = 0;
        verified = false;

        ecKeyUtil = new Secp256k1Utils(this);
        ecKey = ecKeyUtil.getKeyPair();

        dbManager = DBManager.getInstance(getApplicationContext());
        dataToolPackage = new DataToolPackage(getApplicationContext(), dbManager, ecKeyUtil, ecKey);

        ballot = (BallotEntity) getIntent().getExtras().getSerializable("ballot");
        for (CandidateEntity entity : ballot.getCandidates()) {
            if (entity.getId() < 1 && (entity.getSeat() == null || entity.getSeat().getId() < 1) &&
                entity.getElection() != null && entity.getElection().getId() > 0) {
                HashMap<String, String> params = new HashMap<>();
                params.put("votingDate", ballot.getVotingDate());
                params.put("verify", "true");
                params.put("verified", ballot.isVerified() || dataToolPackage.checkVerify(ballot.getNumber()) ? "true" : "false");
                entity.setParams(params);
                if (params.get("verified").equals("true")) {
                    ll_toolBar.setVisibility(View.GONE);
                    RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                    layoutParams.setMargins(0, 0, 0, 0);
                    lv_contents.setLayoutParams(layoutParams);
                }
                break;
            }
        }

        registeredVoter = dataToolPackage.getRegisteredVoter();
        HashMap<String, JSONObject> localVotes = dataToolPackage.getLocalVotes(ballot.getElection());
        if (localVotes.containsKey(ballot.getNumber().toLowerCase())) {
            try {
                JSONObject localVote = localVotes.get(ballot.getNumber().toLowerCase());
                JSONArray votes = new JSONArray(localVote.getString("votes"));
                if (localVote.getString("status").equals("Draft")) {
                } else {
                    ballot.setVoted(true);

                    JSONObject vote, candidate;
                    JSONArray candidates;
                    for (CandidateEntity candidateEntity : ballot.getCandidates()) {
                        if (candidateEntity.getId() < 1 && (candidateEntity.getSeat() == null || candidateEntity.getSeat().getId() < 1) &&
                                candidateEntity.getElection() != null && candidateEntity.getElection().getId() > 0) {
                            candidateEntity.setVoted(true);
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
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        adapter = new BallotHomeAdapter(this, ballot.getCandidates());
        lv_contents.setAdapter(adapter);
        adapter.setOnItemClickListener(new BallotHomeAdapter.OnItemClickListener() {
            @Override
            public void onVoteClick(View view, int i) { }

            @Override
            public void onViewProgressClick(View view, int i) { }
        });

        myKeyUtil = new Secp256r1KeyStoreUtils(this);
        try {
            if (!myKeyUtil.containsAlias()) {
                myKeyUtil.generateECKeyPairKeystore();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        androidx.appcompat.app.ActionBar actionBar = getSupportActionBar();
        if(actionBar != null) {
            actionBar.hide();
        }
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == getResources().getIdentifier("tv_back", "id", getPackageName())) {
            finish();
        } else if (v.getId() == getResources().getIdentifier("tv_yes", "id", getPackageName())) {
            sendVerificationCode();
            rl_confirm.setVisibility(View.GONE);
            ll_verify.setVisibility(View.VISIBLE);
        } else if (v.getId() == getResources().getIdentifier("tv_no", "id", getPackageName())) {
            Intent intent = new Intent(this, PAChainAppealVoteDialogActivity.class);
            intent.putExtra("state", registeredVoter.getState());
            intent.putExtra("county", registeredVoter.getCounty());
            startActivity(intent);
        } else if (v.getId() == getResources().getIdentifier("tv_requestNewCode", "id", getPackageName())) {
            requestNewCode = true;
            tv_requestNewCode.setEnabled(false);
            sendVerificationCode();
        } else if (v.getId() == getResources().getIdentifier("tv_verifyMobile_next", "id", getPackageName())) {
            if (TextUtils.isEmpty(et_verificationCode.getText().toString().trim())) {
                et_verificationCode.setError(getResources().getString(getResources().getIdentifier("register_emptyVerificationCode", "string", getPackageName())));
                return;
            } else if (!et_verificationCode.getText().toString().trim().equals(verificationCode + "")) {
                et_verificationCode.setError(getResources().getString(getResources().getIdentifier("register_errorVerificationCode", "string", getPackageName())));
                return;
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && registeredVoter.isEnableFingerprint()) {
                switch (FingerManager.checkSupport(this)) {
                    case DEVICE_UNSUPPORTED:
                    case SUPPORT_WITHOUT_DATA:
                        verifyBallot();
                        break;
                    case SUPPORT:
                        FingerManager.build().setApplication(getApplication())
                            .setTitle(getResources().getString(getResources().getIdentifier("biometric_dialog_title", "string", getPackageName())))
                            .setDes(getResources().getString(getResources().getIdentifier("biometric_dialog_subtitle", "string", getPackageName())))
                            .setNegativeText(getResources().getString(getResources().getIdentifier("biometric_dialog_cancel", "string", getPackageName())))
                            .setFingerCallback(new SimpleFingerCallback() {
                                @Override
                                public void onSucceed() {
                                    verifyBallot();
                                }

                                @Override
                                public void onFailed() {

                                }

                                @Override
                                public void onChange() {
                                }
                            })
                            .create()
                            .startListener(PAChainVerifyVoteActivity.this);

                        break;
                    default:
                }
            } else {
                verifyBallot();
            }
        }
    }

    private void sendVerificationCode() {
        verificationCode = (int) ((Math.random() * 9 + 1) * 100000);
        JSONObject object = new JSONObject();
        String param = null;
        List<String> params = new ArrayList<>();
        try {
            String base64PublicKey = Base64.encodeToString(((PublicKey) ecKey.get("publicKey")).getEncoded(), Base64.NO_WRAP);
            object.put("publicKey", base64PublicKey);
            object.put("signature", ecKeyUtil.signByPrivateKey(base64PublicKey, (PrivateKey) ecKey.get("privateKey")));
            object.put("to", "1" + registeredVoter.getCellPhone());
            object.put("message", verificationCode);
            param = ecKeyUtil.encryptByPublicKey(object.toString(), ecKeyUtil.getPublicKeyFromString(SPUtils.getString(PAChainVerifyVoteActivity.this, SPUtils.ENCRYPT_KEY, "")));

            params.add("params=" + URLEncoder.encode(param));
        } catch (Exception e) {
            e.printStackTrace();
        }
        PostApi api = new PostApi(Config.SEND_VERIFICATIONCODE, params);
        api.setOnApiListener(new PostApi.onApiListener() {
            @Override
            public void onExecute(String content) {

            }

            @Override
            public void onSuccessed(String successed) {
                try {
                    JSONObject json = new JSONObject(successed);
                    if (json.getBoolean("ret")) {
                        if (requestNewCode) {
                            Toast.makeText(PAChainVerifyVoteActivity.this, getResources().getString(getResources().getIdentifier("register_requestNewCodeSuccess", "string", getPackageName())), Toast.LENGTH_LONG).show();
                        }
                    } else {
                        Toast.makeText(PAChainVerifyVoteActivity.this, json.getString("error"), Toast.LENGTH_LONG).show();
                    }
                } catch (Exception e) {
                    Toast.makeText(PAChainVerifyVoteActivity.this, e.getMessage(), Toast.LENGTH_LONG).show();
                }
                requestNewCode = false;
            }

            @Override
            public void onFailed(String error) {
                Toast.makeText(PAChainVerifyVoteActivity.this, error, Toast.LENGTH_LONG).show();
                requestNewCode = false;
            }
        });
        api.call();
    }

    private void verifyBallot() {
        showProgressDialog();
        JSONObject object = new JSONObject();
        String param = null;
        List<String> params = new ArrayList<>();
        String accessToken = SPUtils.getString(PAChainVerifyVoteActivity.this, SPUtils.ACCESS_TOKEN, "");
        try {
            object.put("signature", myKeyUtil.signByPrivateKey(accessToken));
            object.put("verifiedDate", ToolPackage.getDateNow());
            object.put("electionKey", ballot.getElectionKey());
            param = ecKeyUtil.encryptByPublicKey(object.toString(), ecKeyUtil.getPublicKeyFromString(SPUtils.getString(PAChainVerifyVoteActivity.this, SPUtils.SERVER_KEY, "")));

            object = new JSONObject();
            object.put("accessToken", accessToken);
            object.put("params", param);
            param = ecKeyUtil.encryptByPublicKey(object.toString(), ecKeyUtil.getPublicKeyFromString(SPUtils.getString(PAChainVerifyVoteActivity.this, SPUtils.ENCRYPT_KEY, "")));

            params.add("params=" + URLEncoder.encode(param));
        } catch (Exception e) {
            e.printStackTrace();
        }
        PostApi api = new PostApi(Config.VERIFY_BALLOT, params);
        api.setOnApiListener(new PostApi.onApiListener() {
            @Override
            public void onExecute(String content) { }

            @Override
            public void onSuccessed(String successed) {
                try {
                    JSONObject json = new JSONObject(successed);
                    if (json.getBoolean("ret")) {
                        String responseEncrypt = json.getString("response");
                        String response = ecKeyUtil.decryptByPrivateKey(responseEncrypt, (PrivateKey) ecKey.get("privateKey"));
                        JSONObject object = new JSONObject(response);
                        if (object.getBoolean("ret")) {
                            verified = true;
                            ll_verify.setVisibility(View.GONE);
                            rl_confirm.setVisibility(View.VISIBLE);

                            ll_toolBar.setVisibility(View.GONE);
                            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                            layoutParams.setMargins(0, 0, 0, 0);
                            lv_contents.setLayoutParams(layoutParams);
                            for (CandidateEntity entity : ballot.getCandidates()) {
                                if (entity.getId() < 1 && (entity.getSeat() == null || entity.getSeat().getId() < 1) &&
                                    entity.getElection() != null && entity.getElection().getId() > 0) {
                                    HashMap<String, String> params = new HashMap<>();
                                    params.put("votingDate", ballot.getVotingDate());
                                    params.put("verify", "true");
                                    params.put("verified", "true");
                                    entity.setParams(params);
                                    break;
                                }
                            }
                            adapter.notifyDataSetChanged();

                            AlertDialog.Builder builder = new AlertDialog.Builder(PAChainVerifyVoteActivity.this);
                            builder.setMessage(getResources().getString(getResources().getIdentifier("verifyVote_success", "string", getPackageName())))
                            .setNegativeButton(getResources().getString(getResources().getIdentifier("common_ok", "string", getPackageName())), new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    dialog.dismiss();
                                }
                            })
                            .create().show();

                            database = dbManager.openDb();
                            database.delete(Constants.TABLE_ENCRYPTDATA, "DataType=?", new String[] { "VerifyBallot_" + ballot.getElection() });

                            JSONObject encryptObject = new JSONObject();
                            encryptObject.put("ballotNumber", ballot.getNumber());
                            encryptObject.put("verifyDate", ToolPackage.getDateNow());

                            ContentValues values = new ContentValues();
                            values.put("DataType", "VerifyBallot_" + ballot.getElection());
                            values.put("Value", ecKeyUtil.encryptByPublicKey(encryptObject.toString(), (PublicKey) ecKey.get("publicKey")));
                            database.insert(Constants.TABLE_ENCRYPTDATA, null, values);
                            dbManager.closeDb(database);
                        } else {
                            Toast.makeText(PAChainVerifyVoteActivity.this, getResources().getString(getResources().getIdentifier("network_unavailable", "string", getPackageName())), Toast.LENGTH_LONG).show();
                        }
                    } else {
                        Toast.makeText(PAChainVerifyVoteActivity.this, getResources().getString(getResources().getIdentifier("network_unavailable", "string", getPackageName())), Toast.LENGTH_LONG).show();
                    }
                } catch (Exception e) {
                    Toast.makeText(PAChainVerifyVoteActivity.this, e.getMessage(), Toast.LENGTH_LONG).show();
                }
                closeProgressDialog();
            }

            public void onFailed(String error) {
                Toast.makeText(PAChainVerifyVoteActivity.this, error, Toast.LENGTH_LONG).show();
                closeProgressDialog();
            }
        });
        api.call();
    }

    private void showProgressDialog() {
        if (progressDialog == null) {
            progressDialog = new ProgressDialog(PAChainVerifyVoteActivity.this);
            progressDialog.setMessage(getResources().getString(getResources().getIdentifier("common_loading", "string", getPackageName())));
            progressDialog.setCanceledOnTouchOutside(false);
            progressDialog.setCancelable(false);
        }
        progressDialog.show();
    }

    private void closeProgressDialog() {
        if (progressDialog != null) {
            progressDialog.dismiss();
        }
    }
}
