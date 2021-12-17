package voteddecode;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

import java.security.interfaces.RSAPrivateKey;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DecodeRunning implements Runnable {
    private String status;
    private boolean completed;
    private String server;
    private String electionKey;
    private String keyType;
    private String token;
    private String key;
    private int interval;
    private ICallBack callBack;
    private String keyPath;
    private String groupName;
    private String publicKey = "";

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
        if(this.callBack!=null){
            this.callBack.showStatus();
        }
    }
    public boolean isCompleted() {
        return completed;
    }
    public void setCompleted(boolean completed) {
        this.completed = completed;
        if(this.callBack!=null && completed){
            this.callBack.completed();
        }
    }
    public String getServer() {
        return server;
    }
    public void setServer(String server) {
        this.server = server;
    }
    public String getElectionKey() { return electionKey; }
    public void setElectionKey(String electionKey) { this.electionKey = electionKey; }
    public String getKeyType() { return keyType; }
    public void setKeyType(String keyType) { this.keyType = keyType; }
    public String getToken() {
        return token;
    }
    public void setToken(String token) {
        this.token = token;
    }
    public String getKey() {
        return key;
    }
    public void setKey(String key) {
        this.key = key;
    }
    public int getInterval() {
        return interval;
    }
    public void setInterval(int interval) {
        this.interval = interval;
    }
    public String getKeyPath() { return keyPath; }
    public void setKeyPath(String keyPath) { this.keyPath = keyPath; }
    public String getGroupName() { return groupName; }
    public void setGroupName(String groupName) { this.groupName = groupName; }

    private RSAPrivateKey rsaPrivateKey=null;

    public DecodeRunning(ICallBack callBack){
        this.callBack=callBack;
        this.setCompleted(true);
        this.setStatus("");
        this.setServer("");
        this.setToken("");
        this.setKey("");
        this.setInterval(0);
    }

    @Override
    public  synchronized void run() {
        if(isValited()) {
            publicKey = getPublicKey();
            if(!this.getKeyType().equals("Wallet")){
                try {
                    rsaPrivateKey = RSAUtils.getRSAPrivateKey(this.getToken());
                }catch (Exception ex){
                    this.setStatus(getCurrentTime() + " Load Private Key Failed: "+ex.getMessage());
                    this.setCompleted(true);
                    return;
                }
            }
            while (true) {
                if(Thread.currentThread().isInterrupted()){
                    this.setStatus(getCurrentTime() + " Thread  Interrupted......");
                    break;
                }
                if(!this.getGroupName().isEmpty() && this.getGroupName().length()>0 && !this.getKeyPath().isEmpty() && this.getKeyPath().length()>0){
                    this.setStatus(getCurrentTime() + " decode " + this.getGroupName());
                    List<String> strings = GlobalUtils.getStrings(this.getKeyPath() + "\\" + this.getGroupName() + ".txt");
                    if(strings!=null){
                        for(String tk:strings){
                            this.setStatus(getCurrentTime() + " decode " + this.getGroupName()+" --> "+tk);
                            String tmpToken=GlobalUtils.readFileContent(this.getKeyPath()+"\\"+tk+"_token.txt");
                            String tmpKey=GlobalUtils.readFileContent(this.getKeyPath()+"\\"+tk+"_public.pem");
                            tmpKey=tmpKey.replaceAll("[-]{2,}[^-]*[-]{2,}", "");
                            tmpKey=tmpKey.replace("\n","").replace("\r", "").trim();
                            decode(this.getElectionKey(),tmpToken,tmpKey);
                        }
                    }
                }
                else{
                    decode(this.getElectionKey(),this.getToken(),this.getKey());
                }
                if (this.getInterval() <= 0) {
                    break;
                } else {
                    try {
                        this.setStatus(getCurrentTime() + " decode waiting " + this.getInterval() + " minutes......");
                        this.wait(this.getInterval() * 60 * 1000);
                    } catch (Exception ex) {
                        this.setStatus(getCurrentTime() + " decode " + ex.getMessage());
                        break;
                    }
                }
            }
        }
        this.setStatus(getCurrentTime() + " decode Completed");
        this.setCompleted(true);
    }
    private void decode(String eKey,String token,String key){
        String url = this.getServer().trim();
        url = url + "/api/voted/getdecodevoted";
        url = url.replace("//", "/");
        try {
            this.setStatus(getCurrentTime() + " decode start......");
            JSONObject params=new JSONObject();
            params.put("electionkey",eKey);
            params.put("token", token);
            params.put("publickey", key);
            params.put("walletKey", this.getKeyType().equals("Wallet"));
            Map<String,String> tmpParams=new HashMap<>();
            tmpParams.put("params",Base64.getEncoder().encodeToString(ECCUtils.encrypt(params.toJSONString().getBytes(),ECCUtils.getPublicKeyFromString(publicKey))));
            String response = HttpClient.getResponse(url, tmpParams);
            JSONObject parse = (JSONObject) JSONObject.parse(response);
            if (getJsonBoolean(parse, "ret")) {
                JSONObject resp = getJsonObject(parse, "response");
                if (resp != null) {
                    if (getJsonBoolean(resp, "ret")) {
                        this.setStatus(getCurrentTime() + " decode Responsed......");
                        JSONArray data = getJsonArray(resp, "data");
                        if (data != null ) {
                            int rowIndex = 0;
                            for (int x = 0; x < data.size(); x++) {
                                rowIndex++;
                                if(Thread.currentThread().isInterrupted()){
                                    this.setStatus(getCurrentTime() + " Thread  Interrupted......");
                                    break;
                                }
                                this.setStatus(getCurrentTime() + " decode (" + rowIndex + "/" + data.size() + ")......");
                                JSONObject o = (JSONObject) data.get(x);
                                if (!decodeVoted(publicKey, o,"(" + rowIndex + "/" + data.size() + ")")) {
                                    break;
                                }
                            }
                        }
                        this.setStatus(getCurrentTime() + " decode Completed");
                    } else {
                        if (resp.containsKey("msg")) {
                            this.setStatus(getCurrentTime() + " decode failed: " + resp.getString("msg"));
                        }
                    }
                }
            } else {
                if (parse.containsKey("error")) {
                    this.setStatus(getCurrentTime() + " decode failed: " + parse.getString("error"));
                }
            }
        } catch (Exception ex) {
            this.setStatus(getCurrentTime() + " decode failed: " + ex.getMessage());
        }
    }
    private String getPublicKey(){
        try
        {
            this.setStatus(getCurrentTime()+" get publicKey......");
            String url=this.getServer().trim();
            url=url+"/api/getpublickey";
            url=url.replace("//","/");
            Map<String,String> params=new HashMap<>();
            params.put("kp", "");
            String response = HttpClient.getResponse(url, params);
            try {
                JSONObject parse = (JSONObject) JSONObject.parse(response);
                if (getJsonBoolean(parse, "ret")) {
                    this.setStatus(getCurrentTime()+" get publicKey completed");
                    return getJsonString(parse,"publicKey");
                } else {
                    this.setStatus(getCurrentTime()+" get publicKey response unknown");
                }
            }catch (Exception ex){
                this.setStatus(getCurrentTime()+" get publicKey failed: "+ex.getMessage());
            }
        }catch (Exception ex){
            this.setStatus(getCurrentTime()+" get publicKey failed: "+ex.getMessage());
        }
        return "";
    }
    private boolean decodeVoted(String publicKey, JSONObject jo,String rowIndex){
        try
        {
            this.setStatus(getCurrentTime()+" start decode "+rowIndex+" voted.......");
            String url=this.getServer().trim();
            url=url+"/api/voted/setdecodevoted";
            url=url.replace("//","/");
            JSONObject params=new JSONObject();
            params.put("electionkey", this.getElectionKey());
            params.put("token",this.getToken());
            params.put("onionkey",getJsonString(jo,"onionkey"));
            params.put("votingnumber",getJsonString(jo,"votingnumber"));
            params.put("county",getJsonString(jo,"county"));
            params.put("encodekey",getJsonString(jo,"encodekey"));
            if(this.getKeyType().equals("Wallet")){
                params.put("packages",getJsonString(jo,"packages"));
                params.put("walletKey", true);
            }
            else{
                params.put("packages",RSAUtils.decryptByPrivateKey(getJsonString(jo, "packages"),rsaPrivateKey));
                params.put("walletKey", false);
            }
            Map<String,String> tmpParams=new HashMap<>();
            tmpParams.put("params",Base64.getEncoder().encodeToString(ECCUtils.encrypt(params.toJSONString().getBytes(),ECCUtils.getPublicKeyFromString(publicKey))));
            String response = HttpClient.getResponse(url, tmpParams);
            try {
                JSONObject parse = (JSONObject) JSONObject.parse(response);
                if (getJsonBoolean(parse, "ret")) {
                    this.setStatus(getCurrentTime()+" decode "+rowIndex+" voted response completed");
                    return true;
                } else {
                    this.setStatus(getCurrentTime()+" decode "+rowIndex+" voted response unknown");
                }
            }catch (Exception ex){
                this.setStatus(getCurrentTime()+" decode "+rowIndex+" voted failed: "+ex.getMessage());
            }
        }catch (Exception ex){
            this.setStatus(getCurrentTime()+" decode "+rowIndex+" voted failed: "+ex.getMessage());
        }
        return false;
    }
    private String getCurrentTime(){
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
        return formatter.format(LocalDateTime.now());
    }
    private boolean getJsonBoolean(JSONObject jo,String key){
        if(jo.containsKey(key)){
            return jo.getBooleanValue(key);
        }
        return false;
    }
    private String getJsonString(JSONObject jo,String key){
        if(jo.containsKey(key)){
            return jo.getString(key);
        }
        return "";
    }
    private JSONObject getJsonObject(JSONObject jo,String key){
        if(jo.containsKey(key)){
            return jo.getJSONObject(key);
        }
        return null;
    }
    private JSONArray getJsonArray(JSONObject jo,String key){
        if(jo.containsKey(key)){
            return jo.getJSONArray(key);
        }
        return null;
    }
    private boolean isValited(){
        boolean ret=true;
        if(!this.getGroupName().isEmpty() && this.getGroupName().length()>0 && !this.getKeyPath().isEmpty() && this.getKeyPath().length()>0){
            //
        }
        else{
            if (this.getKey().isEmpty()){
                this.setStatus(getCurrentTime() + " Missing Key......");
                ret = false;
            }
            if (this.getToken().isEmpty()){
                this.setStatus(getCurrentTime() + " Missing Token......");
                ret = false;
            }
            if (this.getServer().isEmpty()){
                this.setStatus(getCurrentTime() + " Missing Server......");
                ret = false;
            }
        }
        return ret;
    }
}
