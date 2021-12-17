package com.pachain.android.activity.keymanage;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.ContentResolver;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Base64;
import android.widget.Toast;

import com.google.common.io.CharStreams;
import com.pachain.android.activity.register.PAChainRegisterActivity;
import com.pachain.android.common.ToolPackage;
import com.pachain.android.util.CryptoUtil;
import com.pachain.android.util.SPUtils;
import com.pachain.android.util.Secp256k1Utils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.security.PublicKey;
import java.util.Map;

import androidx.annotation.Nullable;

import static androidx.core.util.Preconditions.checkNotNull;

public class PAChainRestoreActivity extends Activity {
    private Secp256k1Utils ecKeyUtil;
    private Map<String, Object> ecKey;
    private static final Logger log = LoggerFactory.getLogger(PAChainRegisterActivity.class);
    private final int REQUEST_CODE_OPEN_DOCUMENT = 4;
    private String password = "*****";
    private ContentResolver contentResolver;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ecKeyUtil = new Secp256k1Utils(this);
        contentResolver = getApplicationContext().getContentResolver();

        final Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        try {
            startActivityForResult(intent, REQUEST_CODE_OPEN_DOCUMENT);
        } catch (final ActivityNotFoundException x) {
            log.warn("Cannot open document selector: {}", intent);
            Toast.makeText(this, getResources().getString(getResources().getIdentifier("toast_start_storage_provider_selector_failed", "string", getPackageName())), Toast.LENGTH_LONG).show();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        if (requestCode == REQUEST_CODE_OPEN_DOCUMENT) {
            if (resultCode == Activity.RESULT_OK) {
                if (intent != null) {
                    Uri targetUri = checkNotNull(intent.getData());
                    String targetProvider = ToolPackage.uriToProvider(targetUri);
                    handleRestore(targetUri, password);
                } else {
                    log.info("didn't get uri");
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                log.info("cancelled restoring private key");
            }
        }
    }

    private void handleRestore(Uri backupUri, final String password) {
        if (backupUri != null) {
            try {
                final InputStream is = contentResolver.openInputStream(backupUri);
                final BufferedReader cipherIn = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
                final StringBuilder cipherText = new StringBuilder();
                CharStreams.copy(cipherIn, cipherText);
                cipherIn.close();

                final byte[] plainText = CryptoUtil.decryptBytes(cipherText.toString(), password.toCharArray());

                PublicKey publicKey = ecKeyUtil.generateOriginalPublicKey(ecKeyUtil.getPrivateKeyFromString(new String(plainText)));
                ecKeyUtil.savePrivateKey(new String(plainText));
                ecKeyUtil.savePublicKey(Base64.encodeToString(publicKey.getEncoded(), Base64.NO_WRAP));
                ecKey = ecKeyUtil.getKeyPair();

                SPUtils.put(this, SPUtils.PREFS_KEY_REMIND_BACKUP, false);
                SPUtils.put(this, SPUtils.PREFS_KEY_LAST_BACKUP, System.currentTimeMillis());
                log.info("successfully restored encrypted private key from external source");
            } catch (final Exception x) {
                log.info("problem restoring private key", x);
            }
        } else {
            final String message = "no backup data provided";
            log.info("problem restoring private key: {}", message);
        }
    }
}
