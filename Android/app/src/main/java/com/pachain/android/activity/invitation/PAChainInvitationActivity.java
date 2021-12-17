package com.pachain.android.activity.invitation;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.TextView;
import android.widget.Toast;
import com.pachain.android.common.DataToolPackage;
import com.pachain.android.common.PostApi;
import com.pachain.android.common.ToolPackage;
import com.pachain.android.config.Config;
import com.pachain.android.entity.InvitationEntity;
import com.pachain.android.entity.VoterEntity;
import com.pachain.android.tool.DBManager;
import com.pachain.android.util.SPUtils;
import com.pachain.android.util.Secp256k1Utils;
import com.pachain.android.util.Secp256r1KeyStoreUtils;

import org.json.JSONObject;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import androidx.annotation.Nullable;

public class PAChainInvitationActivity extends Activity implements View.OnClickListener {
    private TextView tv_back;
    private TextView tv_title;
    private TextView tv_electionName;
    private TextView tv_invitationDate;
    private TextView tv_content;
    private CheckBox ch_confirmVote;
    private CheckBox ch_refuseVote;
    private TextView tv_submit;

    private Secp256k1Utils ecKeyUtil;
    private Map<String, Object> ecKey;
    private Secp256r1KeyStoreUtils myKeyUtil;
    private DataToolPackage dataToolPackage;
    private DBManager dbManager;
    private ProgressDialog progressDialog;

    private InvitationEntity invitation;
    private VoterEntity registeredVoter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(getResources().getIdentifier("pachain_activity_invitation", "layout", getPackageName()));

        tv_back = findViewById(getResources().getIdentifier("tv_back", "id", getPackageName()));
        tv_back.setOnClickListener(this);
        tv_title = findViewById(getResources().getIdentifier("tv_title", "id", getPackageName()));
        tv_title.setText(getResources().getString(getResources().getIdentifier("invitation_title", "string", getPackageName())));
        tv_electionName = findViewById(getResources().getIdentifier("tv_electionName", "id", getPackageName()));
        tv_invitationDate = findViewById(getResources().getIdentifier("tv_invitationDate", "id", getPackageName()));
        tv_content = findViewById(getResources().getIdentifier("tv_content", "id", getPackageName()));
        ch_confirmVote = findViewById(getResources().getIdentifier("ch_confirmVote", "id", getPackageName()));
        ch_refuseVote = findViewById(getResources().getIdentifier("ch_refuseVote", "id", getPackageName()));
        tv_submit = findViewById(getResources().getIdentifier("tv_submit", "id", getPackageName()));
        tv_submit.setOnClickListener(this);

        myKeyUtil = new Secp256r1KeyStoreUtils(this);
        try {
            if (!myKeyUtil.containsAlias()) {
                myKeyUtil.generateECKeyPairKeystore();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        ecKeyUtil = new Secp256k1Utils(this);
        ecKey = ecKeyUtil.getKeyPair();

        dbManager = DBManager.getInstance(getApplicationContext());
        dataToolPackage = new DataToolPackage(getApplicationContext(), dbManager, ecKeyUtil, ecKey);
        registeredVoter = dataToolPackage.getRegisteredVoter();

        Bundle bundle = getIntent().getExtras();
        invitation = bundle != null && bundle.containsKey("invitation") ? (InvitationEntity) getIntent().getExtras().getSerializable("invitation") : null;

        tv_electionName.setText(invitation.getElectionName());
        tv_invitationDate.setText(ToolPackage.ConvertToStringByDate(invitation.getInviteDate()));
        tv_content.setText(String.format(getResources().getString(getResources().getIdentifier("invitation_content", "string", getPackageName())), registeredVoter.getFirstName(),
                invitation.getStatus() == 0 ? getResources().getString(getResources().getIdentifier("invitation_noResponse", "string", getPackageName())) :
                        getResources().getString(getResources().getIdentifier("invitation_responded", "string", getPackageName()))));
        if (invitation.getStatus() != 0) {
            tv_submit.setEnabled(false);
            tv_submit.setBackground(getResources().getDrawable(getResources().getIdentifier("pachain_shape_button_solidfilletgray", "drawable", getPackageName())));
            if (invitation.getStatus() == 1) {
                ch_confirmVote.setChecked(true);
            } else if (invitation.getStatus() == 2) {
                ch_refuseVote.setChecked(true);
            }
        }
        ch_confirmVote.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                if (b && ch_refuseVote.isChecked()) {
                    ch_refuseVote.setChecked(false);
                }
            }
        });
        ch_refuseVote.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                if (b && ch_confirmVote.isChecked()) {
                    ch_confirmVote.setChecked(false);
                }
            }
        });
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == getResources().getIdentifier("tv_back", "id", getPackageName())) {
            setResultIntent();
            finish();
        } else if (v.getId() == getResources().getIdentifier("tv_submit", "id", getPackageName())) {
            if (ch_confirmVote.isChecked() || ch_refuseVote.isChecked()) {
                responseInvitation();
                tv_submit.setEnabled(false);
                tv_submit.setBackground(getResources().getDrawable(getResources().getIdentifier("pachain_shape_button_solidfilletgray", "drawable", getPackageName())));
            }
        }
    }

    private void responseInvitation() {
        showProgressDialog();
        JSONObject object = new JSONObject();
        String param = null;
        List<String> params = new ArrayList<>();
        String accessToken = SPUtils.getString(PAChainInvitationActivity.this, SPUtils.ACCESS_TOKEN, "");
        try {
            object.put("signature", myKeyUtil.signByPrivateKey(accessToken));
            object.put("status", ch_confirmVote.isChecked() ? 1 : 2);
            object.put("electionKey", invitation.getElectionKey());
            param = ecKeyUtil.encryptByPublicKey(object.toString(), ecKeyUtil.getPublicKeyFromString(SPUtils.getString(PAChainInvitationActivity.this, SPUtils.SERVER_KEY, "")));

            object = new JSONObject();
            object.put("accessToken", accessToken);
            object.put("params", param);
            param = ecKeyUtil.encryptByPublicKey(object.toString(), ecKeyUtil.getPublicKeyFromString(SPUtils.getString(PAChainInvitationActivity.this, SPUtils.ENCRYPT_KEY, "")));

            params.add("params=" + URLEncoder.encode(param));
        } catch (Exception e) {
            e.printStackTrace();
        }
        PostApi api = new PostApi(Config.RESPONSE_INVITATION, params);
        api.setOnApiListener(new PostApi.onApiListener() {
            @Override
            public void onExecute(String content) { }

            @Override
            public void onSuccessed(String successed) {
                try {
                    JSONObject json = new JSONObject(successed);
                    if (json.getBoolean("ret")) {
                        JSONObject object = new JSONObject(json.getString("response"));
                        if (object.getBoolean("ret")) {
                            AlertDialog.Builder builder = new AlertDialog.Builder(PAChainInvitationActivity.this);
                            builder.setMessage(ch_confirmVote.isChecked() ? getResources().getString(getResources().getIdentifier("invitation_confirmSuccess", "string", getPackageName())) :
                                    getResources().getString(getResources().getIdentifier("invitation_refuseSuccess", "string", getPackageName())))
                                    .setNegativeButton(getResources().getString(getResources().getIdentifier("common_ok", "string", getPackageName())), new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {
                                            dialog.dismiss();
                                        }
                                    })
                                    .create().show();
                            tv_content.setText(String.format(getResources().getString(getResources().getIdentifier("invitation_content", "string", getPackageName())), registeredVoter.getFirstName(),
                                    getResources().getString(getResources().getIdentifier("invitation_responded", "string", getPackageName()))));

                            invitation.setStatus(ch_confirmVote.isChecked() ? 1 : 2);
                        } else {
                            Toast.makeText(PAChainInvitationActivity.this, getResources().getString(getResources().getIdentifier("network_unavailable", "string", getPackageName())), Toast.LENGTH_LONG).show();
                        }
                    } else {
                        Toast.makeText(PAChainInvitationActivity.this, getResources().getString(getResources().getIdentifier("network_unavailable", "string", getPackageName())), Toast.LENGTH_LONG).show();
                    }
                } catch (Exception e) {
                    Toast.makeText(PAChainInvitationActivity.this, e.getMessage(), Toast.LENGTH_LONG).show();
                }
                closeProgressDialog();
            }

            public void onFailed(String error) {
                Toast.makeText(PAChainInvitationActivity.this, error, Toast.LENGTH_LONG).show();
                closeProgressDialog();
            }
        });
        api.call();
    }

    private void setResultIntent() {
        Intent intent = new Intent();
        intent.putExtra("invitation", invitation);
        setResult(0, intent);
    }

    @Override
    public void onBackPressed() {
        setResultIntent();
        finish();
    }

    private void showProgressDialog() {
        if (progressDialog == null) {
            progressDialog = new ProgressDialog(PAChainInvitationActivity.this);
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
