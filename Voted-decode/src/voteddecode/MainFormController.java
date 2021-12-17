package voteddecode;

import com.alibaba.fastjson.JSONObject;
import javafx.event.ActionEvent;
import javafx.scene.control.*;
import javafx.stage.DirectoryChooser;
import javafx.stage.FileChooser;

import java.io.*;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

public class MainFormController implements ICallBack {
    public TextField txtServer;
    public Button btnLoadTokenFromFile;
    public TextArea txtToken;
    public Button btnLoadPublicKeyFromFile;
    public TextArea txtPublicKey;
    public NumberTextField txtInterval;
    public Button btnStartDecode;
    public Button btnStopDecode;
    public TextArea labStatus;
    public Button btnSaveTokenFromFile;
    public Button btnSavePublicKeyFromFile;
    public Button btnCreateToken;
    public TextField txtElectionKey;
    public ComboBox cmbDecodeGroup;
    public TextField txtKeyPath;
    public Button btnSelectKeyPath;
    public ComboBox cmbKeyType;

    private DecodeRunning decodeRunning = new DecodeRunning(this);
    private Thread decodeThread=null;
    private Thread statusTimer=null;
    private String lastedStatus="";

    public MainFormController(){}

    private void  enableForm(boolean enable){
        try {
            txtServer.setDisable(!enable);
            txtElectionKey.setDisable(!enable);
            cmbKeyType.setDisable(!enable);
            txtToken.setDisable(!enable);
            txtPublicKey.setDisable(!enable);
            btnLoadTokenFromFile.setDisable(!enable);
            btnSaveTokenFromFile.setDisable(!enable);
            btnCreateToken.setDisable(!enable);
            btnLoadPublicKeyFromFile.setDisable(!enable);
            txtInterval.setDisable(!enable);
            txtKeyPath.setDisable(!enable);
            cmbDecodeGroup.setDisable(!enable);
            btnStartDecode.setDisable(!enable);
        }catch (Exception ex){}
    }
    public void loadTokenFromFile(ActionEvent actionEvent) {
        FileChooser chooser = new FileChooser();
        chooser.setTitle("Open Token File");
        chooser.getExtensionFilters().addAll(new FileChooser.ExtensionFilter("*,*", "*.*"));
        File file = chooser.showOpenDialog(Main.stage);
        if (file != null) {
            txtToken.setText(GlobalUtils.readFileContent(file.getAbsolutePath()));
        }
    }
    public void saveTokenToFile(ActionEvent actionEvent) {
        FileChooser chooser = new FileChooser();
        chooser.setTitle("Save Token to File");
        chooser.getExtensionFilters().addAll(new FileChooser.ExtensionFilter("*,*", "*.*"));
        File file = chooser.showSaveDialog(Main.stage);
        if (file != null) {
            try(FileWriter fw = new FileWriter(file.getAbsolutePath(), false)){
                fw.write(txtToken.getText().trim());
                fw.flush();
                showAlert(Alert.AlertType.NONE, "Save Token to File","","Save Completed!");
            } catch (IOException e) {
                showAlert(Alert.AlertType.ERROR, "Save Token to File","","Save Failed: "+e.getMessage());
            }
        }
    }
    public void createToken(ActionEvent actionEvent) {
        String keyType = cmbKeyType.getValue().toString();
        if(keyType.equals("Wallet")){
            String url = txtServer.getText().trim();
            url = url + "/api/newclient";
            url = url.replace("//", "/");
            FileChooser chooser = new FileChooser();
            chooser.setTitle("Open Admin Token File");
            chooser.getExtensionFilters().addAll(new FileChooser.ExtensionFilter("*,*", "*.*"));
            File file = chooser.showOpenDialog(Main.stage);
            if (file != null) {
                String token = GlobalUtils.readFileContent(file.getAbsolutePath());
                TextInputDialog dialog = new TextInputDialog("walter");
                dialog.setTitle("Input your Name");
                dialog.setHeaderText("Input your Name");
                dialog.setContentText("Please enter your name:");
                Optional<String> result = dialog.showAndWait();
                if (result.isPresent()){
                    JSONObject params=new JSONObject();
                    params.put("token",token);
                    params.put("userName",result.get());
                    try {
                        Map<String,String> tmpParams=new HashMap<>();
                        tmpParams.put("params", Base64.getEncoder().encodeToString(ECCUtils.encrypt(params.toJSONString().getBytes(),ECCUtils.getPublicKeyFromString(getPublicKey()))));
                        String response = HttpClient.getResponse(url, tmpParams);
                        JSONObject parse = (JSONObject) JSONObject.parse(response);
                        if(parse.containsKey("ret") && parse.getBooleanValue("ret")){
                            txtToken.setText(parse.getString("token"));
                            txtPublicKey.setText(parse.getString("publickey"));
                            showAlert(Alert.AlertType.NONE, "Create Key","","Create Completed! Please Save it!");
                        }
                        else if(parse.containsKey("error")){
                            showAlert(Alert.AlertType.ERROR, "Create Key","","Create Failed: "+parse.getString("error"));
                        }
                        else{
                            showAlert(Alert.AlertType.ERROR, "Create Key","","Create Failed: response unknown!");
                        }
                    }
                    catch (Exception ex){
                        showAlert(Alert.AlertType.ERROR, "Create Key","","Create Failed: "+ex.getMessage());
                    }
                }
            }
        }
        else{
            try {
                HashMap<String, String> keys = RSAUtils.getKeys();
                txtPublicKey.setText(keys.get("public"));
                txtToken.setText(keys.get("private"));
            }catch (Exception ex){
                showAlert(Alert.AlertType.ERROR, "Create Key","","Create Failed: "+ex.getMessage());
            }
        }
    }
    private String getPublicKey(){
        try
        {
            String url=this.txtServer.getText().trim();
            url=url+"/api/getpublickey";
            url=url.replace("//","/");
            Map<String,String> params=new HashMap<>();
            params.put("kp", "");
            String response = HttpClient.getResponse(url, params);
            try {
                JSONObject parse = (JSONObject) JSONObject.parse(response);
                if (parse.getBoolean("ret")) {
                    return parse.getString("publicKey");
                }
            }catch (Exception ex){
            }
        }catch (Exception ex){
        }
        return "";
    }
    public void loadPublicKeyFromFile(ActionEvent actionEvent) {
        FileChooser chooser = new FileChooser();
        chooser.setTitle("Open Token File");
        chooser.getExtensionFilters().addAll(new FileChooser.ExtensionFilter("*,*", "*.*"));
        File file = chooser.showOpenDialog(Main.stage);
        if (file != null) {
            String content = GlobalUtils.readFileContent(file.getAbsolutePath());
            content=content.replaceAll("[-]{2,}[^-]*[-]{2,}", "");
            content=content.replace("\n","").replace("\r", "").trim();
            txtPublicKey.setText(content);
        }
    }
    public void savePublicKeyToFile(ActionEvent actionEvent) {
        FileChooser chooser = new FileChooser();
        chooser.setTitle("Save PublicKey to File");
        chooser.getExtensionFilters().addAll(new FileChooser.ExtensionFilter("*,*", "*.*"));
        File file = chooser.showSaveDialog(Main.stage);
        if (file != null) {
            try(FileWriter fw = new FileWriter(file.getAbsolutePath(), false)){
                fw.write(txtPublicKey.getText().trim());
                fw.flush();
                showAlert(Alert.AlertType.NONE, "Save PublicKey to File","","Save Completed!");
            } catch (IOException e) {
                showAlert(Alert.AlertType.ERROR, "Save PublicKey to File","","Save Failed: "+e.getMessage());
            }
        }
    }
    public void selectKeyPath(ActionEvent actionEvent) {
        DirectoryChooser chooser = new DirectoryChooser();
        chooser.setTitle("Open Key Path");
        File file = chooser.showDialog(Main.stage);
        if(file!=null){
            txtKeyPath.setText(file.getAbsolutePath());
        }
    }
    private void  showAlert(Alert.AlertType type, String title,String header,String content){
        Alert alert = new Alert(type,content,new ButtonType[]{ButtonType.CLOSE});
        if(title!=null && !title.isEmpty()){
            alert.setTitle(title);
        }
        if(header!=null && !header.isEmpty()){
            alert.setHeaderText(header);
        }
        alert.show();
    }
    public void startDecode(ActionEvent actionEvent) {
        decodeRunning.setServer(txtServer.getText().trim());
        decodeRunning.setElectionKey(txtElectionKey.getText().trim());
        decodeRunning.setKeyType(cmbKeyType.getValue().toString());
        decodeRunning.setToken(txtToken.getText().trim());
        decodeRunning.setKey(txtPublicKey.getText().trim());
        String text = txtInterval.getText().trim();
        if(text.length()>0){
            decodeRunning.setInterval(Integer.valueOf(txtInterval.getText()));
        }
        else{
            decodeRunning.setInterval(0);
        }
        decodeRunning.setKeyPath(txtKeyPath.getText().trim());
        decodeRunning.setGroupName(cmbDecodeGroup.getValue().toString());
        decodeRunning.setCompleted(false);
        labStatus.setText("");
        if(decodeThread!=null && decodeThread.isAlive()){
            decodeThread.interrupt();
        }
        decodeThread = new Thread(decodeRunning);
        decodeThread.start();
        enableForm(false);
    }
    @Override
    public void showStatus(){
        try {
            javafx.application.Platform.runLater( () -> {
                String status = decodeRunning.getStatus();
                if(!status.equals(lastedStatus)){
                    lastedStatus=status;
                    labStatus.appendText(status+ "\n");
                }
            });
        }catch (Exception ex){}
    }
    @Override
    public void completed() {
        enableForm(true);
    }
    public void stopDecode(ActionEvent actionEvent) {
        //for(int x=1;x<=10;x++){
        //    try {
        //        HashMap<String, String> keys = RSAUtils.getKeys();
        //        File file = new File("D:\\RSAKeys", x + "_token.txt");
        //        try(FileWriter fw = new FileWriter(file.getAbsolutePath(), false)){
        //            fw.write(keys.get("private").trim());
        //            fw.flush();
        //        } catch (IOException e) {
        //            showAlert(Alert.AlertType.ERROR, "Save Private to File","","Save Failed: "+e.getMessage());
        //        }
        //        file = new File("D:\\RSAKeys",x+"_public.pem");
        //        try(FileWriter fw = new FileWriter(file.getAbsolutePath(), false)){
        //            fw.write(keys.get("public").trim());
        //            fw.flush();
        //        } catch (IOException e) {
        //            showAlert(Alert.AlertType.ERROR, "Save PublicKey to File","","Save Failed: "+e.getMessage());
        //        }
        //    }catch (Exception ex){
        //        showAlert(Alert.AlertType.ERROR, "Create Key","","Create Failed: "+ex.getMessage());
        //    }
        //}
        //showAlert(Alert.AlertType.INFORMATION, "Save PublicKey to File","","Save Completed");
        String s1 ="";
        try {
            String s = "ApCnmgvP8yrJnTqZfd3UPRinCqDogW5euJQoPNzkHeElMeI0hsfgVa4QBA9CsUHzzv2INVCVGI4aJsDUvmV3VGbaLUtYdFKoFpZQ9A24o0BCuhRGg3Js4j3nswmaUh4qB0S0t5SaYpwOUx90Z4JvTF/gozsTaUJkV2+0b64Z7dAFaycGWoxM2GPCdUILztA7CEjWzzdVNMs+ulhdDnQToxo1tzNpEtd4c+6d91f59nXTBPlOE/dae8fmu168CyxRKh8gONExZ8W7zI3sGsUIt5TiOsRrUZnPsYM65wBi89IHbpASy0YSkAUeZnlVzByfeRRvKLipydHf6JA/MugwhQ==";
            s1 = RSAUtils.decryptByPrivateKey(s, RSAUtils.getRSAPrivateKey("MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCubI9CzwlnujbcPVCmBi5rcZC0EEBTICIFjJYklp7XKNFdcx7PgJ+I8DdzNPjw25pkgzBpHdsENEo4a01Msp2G3Q3gFciPi3ZQq5pdGlgppsrfWyEN1V6n703uPPR4Ax8ZBCzd9Lb6v8B0sTkkAyk39y5YipMSHA5mciqhMK2/SXuzNhhqJ9XjnKZgKa2UmWojQTE4Qgx+YI61krX62V6Q6ghN8FMoyblOrPL2TCwRIonoZ3zarhLozvcdvUbVHIqTK1R2xhz/EMmhH8rTv+/lIBk6xGXcvA0GQKwM/EwBppppdxVRp+sgoAM8FAMmoaEwBz+4w9KKGKJmgNJAPE+TAgMBAAECggEBAIFg/RLtR2itc6wBvySnSR9haZhmxY/jMdkz4trY7pFiMYpDrgL0wWFt7XODQ3RFMEyGEw6lmqOPtc4LqZbOlpJGvdgN0GrJY8WKxEFzHRooIitzCR2du0yN8RxaEmxCxHpl4nHw5xkvyq3EF0JjJdvheXsrrtOsA/JxlLVjyj0sJxz+/vLglyiREfqGW54NOpI8XMcOZuskEQr0gnyQ6AWwrxwbr/w86hMljv3hTa2olX0DlPcPDa8bi5X9DzR0rwMuz/HzX0eTY1ICO4u5Qh7YSq5oEihpouS4CfrSar6/ocTk5MCzh27cALgrsUstAhRMOCqtB3mRr5yL2o2npUECgYEA08EKD831v9a5YBBCE/iM2u2Ssx1sSIXsMauRO9GXpUUUORH5+r4Digypb786NNseHxYno+Tn33ICfmIjPvBKz2It6oPf3DCTyRJ49k3hxVu6E2tqWR/FfT5PSY/rfCws1X4KfZZqlQw/rdi+qAJXAKH/B0mvw+6iCtjr1me28QkCgYEA0t6ycrl6ZAamw2WUG+9gdQIJVDsseo09goS4ixzU69aFlzgHjgb8VHU5XSdwRmC5g/bVUAZ1GQmXsLGdFDVvRv+1tsn+yYBYVZE2oY6VnAMTsY7LewJ09C8v2TyQNAhl0XNMhgHucrGreUgNaYOOJ3e7xiRwioR/HfSczbS9zrsCgYEAnpPG7DUKX8L3CjjCs2AEZANcRCS5rcoVKtFYLxrz3MHRtjd/JEbeMajvzo6/kUuy0AbwYq2O8+fWdD0cNgsPiyT0S9a8c5IxangZ/CIw/HKH8/kSKHJBnFxoViega1pNrQf55Tka0knc+l0B0qIF86Rdb2DAbxOraEIww1ziRLkCgYBxobgfwnuFs1/iI7bwZspfwz0rusd5MutWjha0QFEs1Wkf1/2aN4F6McE7xajnA/B0gGrquNAZMeYgPVYcMb9JTzqoyakXBKaVVa9O1/sfGzldkUltfCFyBIuQUOaUY4IaoDs4a4oHHF7++CjiFxZfhlIVsEVFH6kwh0SIRUGTSQKBgH2y8Ei1ekXW+AIlogFdVrjZcVsW1tf8+zTpeBbmu0EHv44zuKTw2TGLK27DxBsQwMqEVcIII/8pIviDEiQFYvY15mVxs3bwTzaHR/+SyYIAVjoUf2MCPfzNN6o0zQCUtYQOV4ii6QqoUZ3FAEDCoGKNc1v915QfSrzHAEmrML5m"));
        }catch (Exception ex){
            s1=ex.getMessage();
        }
        if(decodeThread!=null && decodeThread.isAlive()){
            decodeThread.interrupt();
        }
    }

}

