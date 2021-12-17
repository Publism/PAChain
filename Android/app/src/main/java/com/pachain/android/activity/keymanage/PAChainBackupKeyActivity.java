package com.pachain.android.activity.keymanage;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.widget.Toast;

import com.google.common.io.CharStreams;
import com.pachain.android.activity.register.PAChainRegisterActivity;
import com.pachain.android.common.ToolPackage;
import com.pachain.android.config.Constants;
import com.pachain.android.util.CryptoUtil;
import com.pachain.android.util.SPUtils;
import com.pachain.android.util.Secp256k1Utils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;

import androidx.annotation.Nullable;

import static androidx.core.util.Preconditions.checkNotNull;

public class PAChainBackupKeyActivity extends Activity {
    private Secp256k1Utils ecKeyUtil;
    private static final Logger log = LoggerFactory.getLogger(PAChainRegisterActivity.class);
    private final int REQUEST_CODE_CREATE_DOCUMENT = 3;
    private String password = "*****";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ecKeyUtil = new Secp256k1Utils(this);

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd-HH-mm");

        final StringBuilder filename = new StringBuilder(Constants.EXTERNAL_PRIVATEKEY_BACKUP);
        filename.append('-');
        filename.append(dateFormat.format(new Date()));

        final Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType(Constants.MIMETYPE_WALLET_BACKUP);
        intent.putExtra(Intent.EXTRA_TITLE, filename.toString());
        try {
            startActivityForResult(intent, REQUEST_CODE_CREATE_DOCUMENT);
        } catch (final ActivityNotFoundException x) {
            log.warn("Cannot open document selector: {}", intent);
            Toast.makeText(this, getResources().getString(getResources().getIdentifier("toast_start_storage_provider_selector_failed", "string", getPackageName())), Toast.LENGTH_LONG).show();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        if (requestCode == REQUEST_CODE_CREATE_DOCUMENT) {
            if (resultCode == Activity.RESULT_OK) {
                Uri targetUri = checkNotNull(intent.getData());
                String targetProvider = ToolPackage.uriToProvider(targetUri);
                String privateKeyStr = ecKeyUtil.getPrivateKey();
                try (final Writer cipherOut = new OutputStreamWriter(getContentResolver().openOutputStream(targetUri), StandardCharsets.UTF_8)) {
                    final String cipherText = CryptoUtil.encrypt(privateKeyStr, password.toCharArray());
                    cipherOut.write(cipherText);
                    cipherOut.flush();
                } catch (final IOException x) {
                    log.error("problem backing up private key to " + targetUri, x);
                    Toast.makeText(this, x.toString(), Toast.LENGTH_LONG).show();
                    return;
                }
                try (final Reader cipherIn = new InputStreamReader(getContentResolver().openInputStream(targetUri), StandardCharsets.UTF_8)) {
                    final StringBuilder cipherText = new StringBuilder();
                    CharStreams.copy(cipherIn, cipherText);
                    cipherIn.close();

                    final byte[] plainBytes2 = CryptoUtil.decryptBytes(cipherText.toString(), password.toCharArray());
                    if (!privateKeyStr.equals(new String(plainBytes2)))
                        throw new IOException("verification failed");

                    log.info("verified successfully: '" + targetUri + "'");

                    SPUtils.put(this, SPUtils.PREFS_KEY_REMIND_BACKUP, false);
                    SPUtils.put(this, SPUtils.PREFS_KEY_LAST_BACKUP, System.currentTimeMillis());

                    Toast.makeText(this, "Backing up private key to " + (targetProvider != null ? targetProvider : targetUri.toString()) + " successfully.", Toast.LENGTH_LONG).show();
                } catch (final IOException x) {
                    log.error("problem verifying backup from " + targetUri, x);
                    Toast.makeText(this, x.toString(), Toast.LENGTH_LONG).show();
                    return;
                }

            } else if (resultCode == Activity.RESULT_CANCELED) {
                log.info("cancelled backing up private key");
            }
        }
    }

}
