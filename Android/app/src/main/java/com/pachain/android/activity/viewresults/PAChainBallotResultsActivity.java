package com.pachain.android.activity.viewresults;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.AdapterView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.pachain.android.adapter.viewresults.BallotResultAdapter;
import com.pachain.android.adapter.CountyAdapter;
import com.pachain.android.adapter.PrecinctAdapter;
import com.pachain.android.adapter.StateAdapter;
import com.pachain.android.common.ConstantDataToolPackage;
import com.pachain.android.common.DataToolPackage;
import com.pachain.android.common.PostApi;
import com.pachain.android.common.ToolPackage;
import com.pachain.android.config.Config;
import com.pachain.android.entity.BallotEntity;
import com.pachain.android.entity.CandidateEntity;
import com.pachain.android.entity.CountyEntity;
import com.pachain.android.entity.ElectionEntity;
import com.pachain.android.entity.PartyEntity;
import com.pachain.android.entity.PrecinctEntity;
import com.pachain.android.entity.SeatEntity;
import com.pachain.android.entity.StateEntity;
import com.pachain.android.entity.VoterEntity;
import com.pachain.android.tool.DBManager;
import com.pachain.android.util.SPUtils;
import com.pachain.android.util.Secp256k1Utils;
import org.json.JSONArray;
import org.json.JSONObject;
import java.lang.reflect.Type;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import androidx.annotation.Nullable;

public class PAChainBallotResultsActivity extends Activity implements View.OnClickListener {
    private TextView tv_back;
    private TextView tv_title;
    private LinearLayout ll_election;
    private TextView tv_electionName;
    private TextView tv_electionDay;
    private Spinner sp_state;
    private Spinner sp_county;
    private Spinner sp_precinct;
    private TextView tv_go;
    private LinearLayout ll_votedInfo;
    private TextView tv_votes;
    private TextView tv_lastUpdate;
    private TextView tv_area;
    private ListView lv_contents;

    private DBManager dbManager;
    private DataToolPackage dataToolPackage;
    private ConstantDataToolPackage constantDataToolPackage;
    private ProgressDialog progressDialog;
    private Gson gson;
    private HashMap<String, PartyEntity> parties;
    private ArrayList<StateEntity> states;
    private StateAdapter stateAdapter;
    private StateEntity stateEntity;
    private ArrayList<CountyEntity> counties;
    private ArrayList<CountyEntity> stateCounties;
    private CountyAdapter countyAdapter;
    private ArrayList<PrecinctEntity> precincts;
    private PrecinctAdapter precinctAdapter;
    private ArrayList<CandidateEntity> candidates;
    private BallotResultAdapter adapter;

    private Secp256k1Utils ecKeyUtil;
    private Map<String, Object> ecKey;

    private int stateChangeCount;
    private int countyChangeCount;
    private String state;
    private String stateName;
    private String county;
    private String countyName;
    private String precinct;

    private BallotEntity ballot;
    private VoterEntity registeredVoter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(getResources().getIdentifier("pachain_activity_ballotresults", "layout", getPackageName()));

        stateChangeCount = 0;
        countyChangeCount = 0;
        state = "";
        stateName = "";
        county = "";
        countyName = "";
        precinct = "";
        stateCounties = new ArrayList<>();
        candidates = new ArrayList<>();
        gson = new Gson();

        ecKeyUtil = new Secp256k1Utils(this);
        ecKey = ecKeyUtil.getKeyPair();

        Bundle bundle = getIntent().getExtras();
        ballot = bundle != null && bundle.containsKey("ballot") ? (BallotEntity) getIntent().getExtras().getSerializable("ballot") : null;
        if (ballot != null) {
            candidates = ballot.getCandidates();
        }
        dbManager = DBManager.getInstance(getApplicationContext());
        dataToolPackage = new DataToolPackage(getApplicationContext(), dbManager, ecKeyUtil, ecKey);
        constantDataToolPackage = new ConstantDataToolPackage(getApplicationContext());
        registeredVoter = dataToolPackage.getRegisteredVoter();
        parties = constantDataToolPackage.getParties();

        states = constantDataToolPackage.getStates();
        if (states != null && states.size() > 0) {
            stateEntity = new StateEntity();
            stateEntity.setId(0);
            stateEntity.setCode("");
            stateEntity.setName(getResources().getString(getResources().getIdentifier("ballotResults_national", "string", getPackageName())));
            states.add(0, stateEntity);
        }
        counties = constantDataToolPackage.getCounties();
        CountyEntity countyEntity = new CountyEntity();
        countyEntity.setId(0);
        countyEntity.setCode("");
        countyEntity.setNumber("");
        countyEntity.setName(getResources().getString(getResources().getIdentifier("common_all", "string", getPackageName())));
        stateCounties.add(0, countyEntity);
        precincts = new ArrayList<>();
        PrecinctEntity precinctEntity = new PrecinctEntity();
        precinctEntity.setState("");
        precinctEntity.setCounty("");
        precinctEntity.setNumber(getResources().getString(getResources().getIdentifier("common_all", "string", getPackageName())));
        precincts.add(0, precinctEntity);

        tv_back = findViewById(getResources().getIdentifier("tv_back", "id", getPackageName()));
        tv_back.setOnClickListener(this);
        tv_title = findViewById(getResources().getIdentifier("tv_title", "id", getPackageName()));
        tv_title.setText(getResources().getString(getResources().getIdentifier("gotv_results", "string", getPackageName())));
        ll_election = findViewById(getResources().getIdentifier("ll_election", "id", getPackageName()));
        tv_electionName = findViewById(getResources().getIdentifier("tv_electionName", "id", getPackageName()));
        tv_electionDay = findViewById(getResources().getIdentifier("tv_electionDay", "id", getPackageName()));
        sp_state = findViewById(getResources().getIdentifier("sp_state", "id", getPackageName()));
        ll_votedInfo = findViewById(getResources().getIdentifier("ll_votedInfo", "id", getPackageName()));
        tv_votes = findViewById(getResources().getIdentifier("tv_votes", "id", getPackageName()));
        tv_lastUpdate = findViewById(getResources().getIdentifier("tv_lastUpdate", "id", getPackageName()));
        tv_area = findViewById(getResources().getIdentifier("tv_area", "id", getPackageName()));
        tv_go = findViewById(getResources().getIdentifier("tv_go", "id", getPackageName()));
        tv_go.setOnClickListener(this);
        lv_contents = findViewById(getResources().getIdentifier("lv_contents", "id", getPackageName()));
        adapter = new BallotResultAdapter(this, candidates);
        lv_contents.setAdapter(adapter);

        stateAdapter = new StateAdapter(this, states);
        sp_state.setAdapter(stateAdapter);
        sp_state.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                stateChangeCount++;
                StateEntity model = (StateEntity) stateAdapter.getItem(i);
                state = model.getCode();
                stateName = model.getName();
                if (stateChangeCount == 1 && state.toUpperCase().equals(registeredVoter.getState().toUpperCase()) && !TextUtils.isEmpty(registeredVoter.getCounty())) {
                } else {
                    county = "";
                    countyName = "";
                    if (stateCounties != null && stateCounties.size() > 1) {
                        sp_county.setSelection(1, false);
                    }
                    getCountiesByState(state);
                    sp_county.setSelection(1, false);
                    sp_county.setSelection(0, true);
                }

                LinearLayout ll = (LinearLayout) view;
                ll.setPadding(15, 15, 0, 15);
            }
            @Override
            public void onNothingSelected(AdapterView<?> adapterView) { }
        });

        sp_county = findViewById(getResources().getIdentifier("sp_county", "id", getPackageName()));
        countyAdapter = new CountyAdapter(this, stateCounties);
        sp_county.setAdapter(countyAdapter);
        sp_county.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                countyChangeCount++;
                CountyEntity model = (CountyEntity) countyAdapter.getItem(i);
                if (i > 0) {
                    county = model.getNumber();
                    countyName = model.getName();
                } else {
                    county = "";
                    countyName = "";
                }
                if (countyChangeCount == 1 && county.toUpperCase().equals(registeredVoter.getCounty().toUpperCase()) && !TextUtils.isEmpty(registeredVoter.getPrecinctNumber())) {
                } else {
                    precinct = "";
                    if (precincts != null && precincts.size() > 1) {
                        sp_precinct.setSelection(1, false);
                    }
                    getPrecinctsByCounty(state, county);
                    sp_precinct.setSelection(1, false);
                    sp_precinct.setSelection(0, true);
                }
                LinearLayout ll = (LinearLayout) view;
                ll.setPadding(15, 15, 0, 15);
            }
            @Override
            public void onNothingSelected(AdapterView<?> adapterView) { }
        });

        sp_precinct = findViewById(getResources().getIdentifier("sp_precinct", "id", getPackageName()));
        precinctAdapter = new PrecinctAdapter(this, precincts);
        sp_precinct.setAdapter(precinctAdapter);
        sp_precinct.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                PrecinctEntity model = (PrecinctEntity) precinctAdapter.getItem(i);
                if (!TextUtils.isEmpty(model.getState())) {
                    precinct = model.getNumber();
                } else {
                    precinct = "";
                }
                LinearLayout ll = (LinearLayout) view;
                ll.setPadding(15, 15, 0, 15);
            }
            @Override
            public void onNothingSelected(AdapterView<?> adapterView) { }
        });

        if (!TextUtils.isEmpty(registeredVoter.getState())) {
            state = registeredVoter.getState();
            int i = 0;
            for (StateEntity stateEntity : states) {
                if (stateEntity.getCode().toUpperCase().equals(registeredVoter.getState().toUpperCase())) {
                    stateName = stateEntity.getName();
                    sp_state.setSelection(i, true);
                    break;
                }
                i++;
            }

            getCountiesByState(registeredVoter.getState());
            if (!TextUtils.isEmpty(registeredVoter.getCounty())) {
                i = 0;
                county = registeredVoter.getCounty();
                for (CountyEntity entity : stateCounties) {
                    if (entity.getNumber().toUpperCase().equals(registeredVoter.getCounty().toUpperCase())) {
                        countyName = entity.getName();
                        sp_county.setSelection(i, true);
                        break;
                    }
                    i++;
                }
            }

            getPrecinctsByCounty(registeredVoter.getState(), registeredVoter.getCounty());
            if (!TextUtils.isEmpty(registeredVoter.getPrecinctNumber())) {
                i = 0;
                precinct = registeredVoter.getPrecinctNumber();
                for (PrecinctEntity entity : precincts) {
                    if (entity.getNumber().toUpperCase().equals(registeredVoter.getPrecinctNumber().toUpperCase())) {
                        sp_precinct.setSelection(i, true);
                        break;
                    }
                    i++;
                }
            }
        }

        if (ballot != null) {
            tv_electionName.setText(ballot.getName());
            tv_electionDay.setText(ballot.getDate());
            getVotedResults(registeredVoter.getState(), registeredVoter.getCounty(), registeredVoter.getPrecinctNumber());
        }
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == getResources().getIdentifier("tv_back", "id", getPackageName())) {
            finish();
        } else if (v.getId() == getResources().getIdentifier("tv_go", "id", getPackageName())) {
            getVotedResults(state, county, precinct);
        }
    }

    private void getCountiesByState(String state) {
        stateCounties.clear();
        if (!TextUtils.isEmpty(state)) {
            for (CountyEntity countyEntity : counties) {
                if (countyEntity.getState().toLowerCase().equals(state.toLowerCase())) {
                    stateCounties.add(countyEntity);
                }
            }
        }
        CountyEntity countyEntity = new CountyEntity();
        countyEntity.setId(0);
        countyEntity.setCode("");
        countyEntity.setNumber("");
        countyEntity.setName(getResources().getString(getResources().getIdentifier("common_all", "string", getPackageName())));
        stateCounties.add(0, countyEntity);
        countyAdapter.notifyDataSetChanged();
    }

    private void getPrecinctsByCounty(String state, String county) {
        precincts.clear();
        if (!TextUtils.isEmpty(state) && !TextUtils.isEmpty(county)) {
            precincts.addAll(constantDataToolPackage.getPrecincts(state, county));
        }
        PrecinctEntity precinctEntity = new PrecinctEntity();
        precinctEntity.setState("");
        precinctEntity.setCounty("");
        precinctEntity.setNumber(getResources().getString(getResources().getIdentifier("common_all", "string", getPackageName())));
        precincts.add(0, precinctEntity);
        precinctAdapter.notifyDataSetChanged();
    }

    private void getVotedResults(final String state, final String county, final String precinct) {
        showProgressDialog();
        JSONObject object = new JSONObject();
        String param = null;
        List<String> params = new ArrayList<>();
        try {
            object.put("electionID", ballot.getElection());
            object.put("electionKey", ballot.getElectionKey());
            object.put("state", state);
            object.put("county", county);
            object.put("precinctNumber", precinct);
            param = ecKeyUtil.encryptByPublicKey(object.toString(), ecKeyUtil.getPublicKeyFromString(SPUtils.getString(PAChainBallotResultsActivity.this, SPUtils.ENCRYPT_KEY, "")));

            params.add("params=" + URLEncoder.encode(param));
        } catch (Exception e) {
            e.printStackTrace();
        }
        PostApi api = new PostApi(Config.GET_VOTERESULTS, params);
        api.setOnApiListener(new PostApi.onApiListener() {
            @Override
            public void onExecute(String content) { }

            @Override
            public void onSuccessed(String successed) {
                try {
                    JSONObject json = new JSONObject(successed);
                    if (json.getBoolean("ret")) {
                        JSONObject response = new JSONObject(json.getString("response"));
                        JSONArray votesArray = new JSONArray(response.getString("data"));
                        JSONObject object;
                        HashMap<String, JSONObject> votedData = new HashMap<>();
                        JSONObject votedObject;
                        String candidateKey = "";
                        CandidateEntity candidateEntity;
                        ElectionEntity election = new ElectionEntity();
                        election.setId(Integer.parseInt(ballot.getElection()));

                        candidates.clear();
                        if (response.has("candidates")) {
                            JSONArray seatsAndCandidatesArray = new JSONArray(response.getString("candidates"));
                            for (int m = 0; m < seatsAndCandidatesArray.length(); m++) {
                                JSONObject seatAndCandidateObject = seatsAndCandidatesArray.getJSONObject(m);
                                SeatEntity seatEntity = gson.fromJson(seatAndCandidateObject.getString("seat"), SeatEntity.class);
                                seatEntity.setName((!TextUtils.isEmpty(seatEntity.getNumber()) ? seatEntity.getOffice() + " " : "") + seatEntity.getName());
                                candidateEntity = new CandidateEntity();
                                candidateEntity.setSeat(seatEntity);
                                candidates.add(candidateEntity);

                                Type type1 = new TypeToken<ArrayList<CandidateEntity>>() {}.getType();
                                ArrayList<CandidateEntity> seatCandidates = gson.fromJson(seatAndCandidateObject.getString("candidates"), type1);
                                for (CandidateEntity entity : seatCandidates) {
                                    entity.setSeat(seatEntity);
                                    entity.setElection(election);
                                    entity.setPartyCode("");
                                    if (parties.containsKey(entity.getParty().toLowerCase())) {
                                        entity.setPartyCode(parties.get(entity.getParty().toLowerCase()).getCode());
                                    }
                                    if (!TextUtils.isEmpty(entity.getParty()) && TextUtils.isEmpty(entity.getPartyCode())) {
                                        entity.setPartyCode("O");
                                    }
                                }
                                candidates.addAll(seatCandidates);
                            }

                            for (int i = 0; i < votesArray.length(); i++) {
                                object = votesArray.getJSONObject(i);
                                votedData.put(object.getInt("electionID") + "_" + object.getInt("seatID") + "_" + object.getInt("candidateID"), object);
                            }
                            for (CandidateEntity candidate : candidates) {
                                if (candidate.getElection() != null && candidate.getElection().getId() > 0 &&
                                    candidate.getSeat() != null && candidate.getSeat().getId() > 0 && candidate.getId() > 0) {
                                    candidateKey = candidate.getElection().getId() + "_" + candidate.getSeat().getId() + "_" + candidate.getId();
                                    if (votedData.containsKey(candidateKey)) {
                                        votedObject = votedData.get(candidateKey);
                                        candidate.setVoteBallots(votedObject.getInt("count"));
                                        candidate.setVoteRate(response.getDouble("percent") * votedObject.getDouble("percent") * 100.0);
                                    } else {
                                        candidate.setVoteBallots(0);
                                        candidate.setVoteRate(0);
                                    }
                                }
                            }
                        }
                        adapter.notifyDataSetChanged();
                        String votesStr = "";
                        String areaStr = "";
                        votesStr = ToolPackage.decimalFormat(response.getInt("voteCount")) + " " + getResources().getString(getResources().getIdentifier("ballotResults_totalVotes", "string", getPackageName())) +
                            (response.getInt("voteCount") > 0 ? ", " + ToolPackage.doubleFormat(response.getDouble("percent") * 100.0) + "% " +
                            (!TextUtils.isEmpty(precinct) ? getResources().getString(getResources().getIdentifier("ballotResults_reporting", "string", getPackageName())) :
                            !TextUtils.isEmpty(county) ? getResources().getString(getResources().getIdentifier("ballotResults_precinctsReporting", "string", getPackageName())) :
                            !TextUtils.isEmpty(state) ? getResources().getString(getResources().getIdentifier("ballotResults_countiesReporting", "string", getPackageName())) :
                            getResources().getString(getResources().getIdentifier("ballotResults_statesReporting", "string", getPackageName()))) : "");
                        areaStr = !TextUtils.isEmpty(precinct) ? countyName + ": " + getResources().getString(getResources().getIdentifier("viewVotingProgress_precinct", "string", getPackageName())) + " " + precinct :
                            !TextUtils.isEmpty(county) ? countyName : stateName;
                        tv_votes.setText(votesStr);
                        tv_area.setText(areaStr);
                        if (response.has("latedVotedDate")) {
                            tv_lastUpdate.setText(getResources().getString(getResources().getIdentifier("ballotResults_lastUpdate", "string", getPackageName())) + " " + ToolPackage.ConvertToStringByTime(response.getString("latedVotedDate")));
                            tv_lastUpdate.setVisibility(View.VISIBLE);
                        } else {
                            tv_lastUpdate.setVisibility(View.GONE);
                        }
                        ll_votedInfo.setVisibility(View.VISIBLE);
                    } else {
                        Toast.makeText(PAChainBallotResultsActivity.this, json.getString("error"), Toast.LENGTH_LONG).show();
                    }
                } catch (Exception e) {
                    Toast.makeText(PAChainBallotResultsActivity.this, e.getMessage(), Toast.LENGTH_LONG).show();
                }
                closeProgressDialog();
            }

            @Override
            public void onFailed(String error) {
                Toast.makeText(PAChainBallotResultsActivity.this, error, Toast.LENGTH_LONG).show();
                closeProgressDialog();
            }
        });
        api.call();
    }

    private void showProgressDialog() {
        if (progressDialog == null) {
            progressDialog = new ProgressDialog(PAChainBallotResultsActivity.this);
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
