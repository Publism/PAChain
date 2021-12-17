package com.pachain.android.util;

import android.content.Context;
import android.os.Build;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.util.Base64;
import java.security.InvalidAlgorithmParameterException;
import java.security.Key;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.ECGenParameterSpec;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import androidx.annotation.RequiresApi;

public class Secp256r1KeyStoreUtils {
    private static String aliasName;
    private static KeyStore keyStore;
    private Context context;

    public Secp256r1KeyStoreUtils(Context context){
        this.context = context.getApplicationContext();
        init();
    }

    private void init() {
        try {
            aliasName = "PAChainEC";

            keyStore = KeyStore.getInstance("AndroidKeyStore");
            keyStore.load(null);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    public Map<String, Object> generateECKeyPairKeystore() throws NoSuchAlgorithmException, InvalidAlgorithmParameterException, NoSuchProviderException {
        Map<String, Object> keyPairMap = new HashMap<>();

        Calendar end = Calendar.getInstance();
        end.add(Calendar.YEAR, 30);

        KeyPairGenerator kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore");
        kpg.initialize(new KeyGenParameterSpec.Builder(
                aliasName, KeyProperties.PURPOSE_SIGN | KeyProperties.PURPOSE_VERIFY)
                .setAlgorithmParameterSpec(new ECGenParameterSpec("secp256r1"))
                .setDigests(KeyProperties.DIGEST_SHA256, KeyProperties.DIGEST_SHA512)
                .setKeyValidityStart(Calendar.getInstance().getTime())
                .setKeyValidityEnd(end.getTime())
                //.setUserAuthenticationRequired(true)
                //.setInvalidatedByBiometricEnrollment(false)
                .build());

        KeyPair keyPair = kpg.generateKeyPair();
        Key publicKey = keyPair.getPublic();
        Key privateKey = keyPair.getPrivate();
        keyPairMap.put("publicKey", publicKey);
        keyPairMap.put("privateKey", privateKey);
        return keyPairMap;
    }

    public boolean containsAlias() throws Exception {
        boolean contains = false;
        try{
            contains = keyStore.containsAlias(aliasName);
        } catch (Exception e){
            e.printStackTrace();
        }
        return contains;
    }

    public KeyStore.PrivateKeyEntry getPrivateKeyEntry() throws Exception {
        /*
         * Use a PrivateKey in the KeyStore to create a signature over
         * some data.
         */
        KeyStore.Entry entry = keyStore.getEntry(aliasName, null);
        if (!(entry instanceof KeyStore.PrivateKeyEntry)) {
            return null;
        }
        else {
            return ((KeyStore.PrivateKeyEntry) entry);
        }
    }

    public PublicKey getPublicKey() throws Exception {
        if (keyStore.containsAlias(aliasName)) {
            return keyStore.getCertificate(aliasName).getPublicKey();
        } else {
            return null;
        }
    }

    public Enumeration<String> getAliases() throws Exception {
        try {
            return keyStore.aliases();
        } catch (KeyStoreException e) {
            e.printStackTrace();
        }

        return null;
    }

    public void deleteKey() {
        try {
            keyStore.deleteEntry(aliasName);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public String signByPrivateKey(String data) throws Exception {
        KeyStore.PrivateKeyEntry privateKeyEntry = getPrivateKeyEntry();
        if (privateKeyEntry == null) {
            return null;
        }
        Signature s = Signature.getInstance("SHA256withECDSA");
        s.initSign(privateKeyEntry.getPrivateKey());
        s.update(data.getBytes());
        return Base64.encodeToString(s.sign(), Base64.NO_WRAP);
    }

    public boolean verifySignature(String data, String signature, PublicKey publicKey) throws Exception {
        Signature s = Signature.getInstance("SHA256withECDSA");
        s.initVerify(publicKey);
        s.update(data.getBytes());
        return s.verify(Base64.decode(signature, Base64.NO_WRAP));
    }
}
