package voteddecode;

import org.bouncycastle.jce.provider.BouncyCastleProvider;
import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;

import javax.crypto.Cipher;
import java.io.IOException;
import java.security.*;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import java.util.HashMap;

public class RSAUtils {
    static {
        Security.addProvider(new BouncyCastleProvider());
    }
    public static HashMap<String, String> getKeys() throws NoSuchAlgorithmException, IOException {
        HashMap<String, String> map = new HashMap<String, String>();
        KeyPairGenerator keyPairGen = KeyPairGenerator.getInstance("RSA");
        keyPairGen.initialize(2048);
        KeyPair keyPair = keyPairGen.generateKeyPair();
        RSAPublicKey publicKey = (RSAPublicKey) keyPair.getPublic();
        RSAPrivateKey privateKey = (RSAPrivateKey) keyPair.getPrivate();
        map.put("public",Base64.getEncoder().encodeToString(publicKey.getEncoded()));
        map.put("private",Base64.getEncoder().encodeToString(privateKey.getEncoded()));
        return map;
    }
    public  static  RSAPrivateKey getRSAPrivateKey(String data) throws Exception {
        BASE64Decoder base64Decoder= new BASE64Decoder();
        byte[] buffer= base64Decoder.decodeBuffer(data);
        PKCS8EncodedKeySpec keySpec= new PKCS8EncodedKeySpec(buffer);
        KeyFactory keyFactory= KeyFactory.getInstance("RSA");
        return  (RSAPrivateKey) keyFactory.generatePrivate(keySpec);
    }
    public static RSAPublicKey getRSAPublicKey(String data) throws Exception{
        BASE64Decoder base64Decoder= new BASE64Decoder();
        byte[] buffer= base64Decoder.decodeBuffer(data);
        KeyFactory keyFactory= KeyFactory.getInstance("RSA");
        X509EncodedKeySpec keySpec= new X509EncodedKeySpec(buffer);
        return  (RSAPublicKey) keyFactory.generatePublic(keySpec);
    }
    public static RSAPublicKey getRSAPublicKeyWithPKCS8(String data) throws Exception{
        BASE64Decoder base64Decoder= new BASE64Decoder();
        byte[] buffer= base64Decoder.decodeBuffer(data);
        KeyFactory keyFactory= KeyFactory.getInstance("RSA");
        PKCS8EncodedKeySpec keySpec= new PKCS8EncodedKeySpec(buffer);
        return  (RSAPublicKey) keyFactory.generatePublic(keySpec);
    }

    public static String encryptByPublicKey(String data, RSAPublicKey publicKey) throws Exception {
        //RSA/ECB/NoPadding,RSA/ECB/PKCS1Padding(
        Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
        cipher.init(Cipher.ENCRYPT_MODE, publicKey);
        int max_len=((publicKey.getModulus().bitLength() - 384) / 8) + 37;
        byte[] bts= data.getBytes();
        byte[] buffer=new byte[max_len];
        int blocks = (bts.length-1)/max_len+1;
        byte[] mi=new byte[0];
        if(blocks==1){
            mi = cipher.doFinal(bts);
        }
        else{
            for(int x=0;x<blocks;x++){
                if(x==blocks-1){
                    buffer=new byte[bts.length-x*max_len];
                }
                System.arraycopy(bts, x*max_len, buffer, 0,buffer.length);
                byte[] bytes = cipher.doFinal(buffer);
                mi=byteMerger(mi,bytes);
            }
        }
        return Base64.getEncoder().encodeToString(mi);
    }
    public static String decryptByPrivateKey(String data, RSAPrivateKey privateKey) throws Exception {
        //RSA/ECB/NoPadding,RSA/ECB/PKCS1Padding(
        Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
        cipher.init(Cipher.DECRYPT_MODE, privateKey);
        int key_len = privateKey.getModulus().bitLength() / 8;
        byte[] bytes = Base64.getDecoder().decode(data);
        String ming = "";
        byte[][] arrays = splitArray(bytes, key_len);
        for(byte[] arr : arrays) {
            ming += new String(cipher.doFinal(arr), "UTF-8");
        }
        return ming;
    }
    public static byte[][] splitArray(byte[] data,int len){
        int x = data.length / len;
        int y = data.length % len;
        int z = 0;
        if(y!=0){
            z = 1;
        }
        byte[][] arrays = new byte[x+z][];
        byte[] arr;
        for(int i=0; i<x+z; i++){
            arr = new byte[len];
            if(i==x+z-1 && y!=0){
                System.arraycopy(data, i*len, arr, 0, y);
            }else{
                System.arraycopy(data, i*len, arr, 0, len);
            }
            arrays[i] = arr;
        }
        return arrays;
    }
    public static byte[] byteMerger(byte[] bt1, byte[] bt2){
        byte[] bt3 = new byte[bt1.length+bt2.length];
        System.arraycopy(bt1, 0, bt3, 0, bt1.length);
        System.arraycopy(bt2, 0, bt3, bt1.length, bt2.length);
        return bt3;
    }
}
