package com.pachain.android.activity.keymanage;

import android.app.Activity;
import android.os.Bundle;
import android.text.TextUtils;

import com.pachain.android.activity.register.PAChainRegisterActivity;
import com.pachain.android.util.CryptoUtil;
import com.pachain.android.util.SPUtils;
import com.pachain.android.util.Secp256k1Utils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

import androidx.annotation.Nullable;

public class PAChainEncryptKeyActivity extends Activity {
    private Secp256k1Utils ecKeyUtil;
    private static final Logger log = LoggerFactory.getLogger(PAChainRegisterActivity.class);
    private String oldPassword = "*****";
    private String newPassword = "*****";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ecKeyUtil = new Secp256k1Utils(this);

        // Decrypt from old password
        if (SPUtils.getBoolean(this, SPUtils.PREFS_KEY_IS_ENCRYPTED, false)) {
            if (TextUtils.isEmpty(oldPassword)) {
                log.info("private key is encrypted, but did not provide spending password");
                return;
            } else {
                String privateStr = ecKeyUtil.getPrivateKey();
                try {
                    final byte[] plainBytes2 = CryptoUtil.decryptBytes(privateStr, oldPassword.toCharArray());
                    ecKeyUtil.savePrivateKey(new String(plainBytes2));
                    SPUtils.put(this, SPUtils.PREFS_KEY_IS_ENCRYPTED, false);
                    log.info("private key successfully decrypted");
                } catch (IOException e) {
                    log.info("private key decryption failed: " + e.getMessage());
                    e.printStackTrace();
                    return;
                }
            }
        }

        // Encrypt to new password
        if (!TextUtils.isEmpty(newPassword) && !SPUtils.getBoolean(this, SPUtils.PREFS_KEY_IS_ENCRYPTED, false)) {
            String privateStr = ecKeyUtil.getPrivateKey();
            try {
                final String cipherText = CryptoUtil.encrypt(privateStr, newPassword.toCharArray());
                ecKeyUtil.savePrivateKey(cipherText);
                SPUtils.put(this, SPUtils.PREFS_KEY_IS_ENCRYPTED, true);
                SPUtils.put(this, SPUtils.PREFS_KEY_LAST_ENCRYPT_KEYS, System.currentTimeMillis());
                log.info("private key successfully encrypted");
            } catch (IOException e) {
                log.info("private key encrypt failed: " + e.getMessage());
                e.printStackTrace();
                return;
            }
        }

    }
}
