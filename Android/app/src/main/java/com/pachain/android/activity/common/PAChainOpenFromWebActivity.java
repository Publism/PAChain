package com.pachain.android.activity.common;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import com.pachain.android.activity.register.PAChainRegisterActivity;
import com.pachain.android.util.SPUtils;
import java.util.List;
import androidx.annotation.Nullable;

public class PAChainOpenFromWebActivity extends Activity {
    private ProgressDialog progressDialog;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(getResources().getIdentifier("pachain_activity_openfromweb", "layout", getPackageName()));
        showProgressDialog();
        getUri();
    }

    private String getUri() {
        Uri uri = getIntent().getData();
        if (uri != null) {
            StringBuffer sb = new StringBuffer();
            sb.append("url: " + uri.toString());
            sb.append("\nscheme: " + uri.getScheme());
            sb.append("\nhost: " + uri.getHost());
            sb.append("\npath: ");
            List<String> pathSegments = uri.getPathSegments();
            for (int i = 0; pathSegments != null && i < pathSegments.size(); i++) {
                sb.append("/" + pathSegments.get(i));
            }
            sb.append("\nquery: ?" + uri.getQuery());

            enterActivity(uri.getPath().replace("/", ""), uri.getQuery());
            return sb.toString();
        }
        return null;
    }

    private void enterActivity(String activityName, String query) {
        try {
            Uri uri;
            Intent intent;
            boolean isMain = false;
            switch (activityName.toLowerCase()) {
                case "":
                case "mainactivity":
                    isMain = true;
                    intent = new Intent(PAChainOpenFromWebActivity.this, PAChainRegisterActivity.class);
                    break;
                default:
                    Class currentClass = Class.forName(activityName);
                    intent = new Intent(this, currentClass);
                    break;
            }
            if (!TextUtils.isEmpty(query)) {
                int index = query.indexOf("?");
                String temp = query;
                if (index > -1) {
                    temp = query.substring(index + 1);
                }
                String[] keyValue = temp.split("&");
                for (String str : keyValue) {
                    intent.putExtra(str.substring(0, str.indexOf("=")), str.substring(str.indexOf("=") + 1));
                }
            }
            if (!isMain) {
                if (!SPUtils.checkActivity("MainActivity")) {
                    Intent mainIntent = new Intent(PAChainOpenFromWebActivity.this, PAChainRegisterActivity.class);
                    startActivity(mainIntent);
                }
            }
            startActivity(intent);
            finish();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            Intent mainIntent = new Intent(PAChainOpenFromWebActivity.this, PAChainRegisterActivity.class);
            startActivity(mainIntent);
            finish();
        }
    }

    private void showProgressDialog() {
        if (progressDialog == null) {
            progressDialog = new ProgressDialog(PAChainOpenFromWebActivity.this);
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
