package com.pachain.android.util;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import com.facebook.drawee.backends.pipeline.Fresco;
import java.util.ArrayList;
import java.util.List;
import androidx.annotation.NonNull;

public class SPUtils extends Application {
    private static final String FILE_NAME = "config";
    private static SharedPreferences sPreferences;
    private static List<Activity> activities = new ArrayList<>();
    private static Context context;
    public static final String PREFS_KEY_IS_ENCRYPTED = "is_encrypted";
    public static final String PREFS_KEY_LAST_ENCRYPT_KEYS = "last_encrypt_keys";
    public static final String PREFS_KEY_REMIND_BACKUP = "remind_backup";
    public static final String PREFS_KEY_LAST_BACKUP = "last_backup";
    public static final String PREFS_KEY_LAST_RESTORE = "last_restore";
    public static final String ACCESS_TOKEN = "access_token";
    public static final String SERVER_KEY = "server_key";
    public static final String ENCRYPT_KEY = "encrypt_key";

    @SuppressLint("MissingSuperCall")
    @Override
    public void onCreate() {
        super.onCreate();
        context = getApplicationContext();
        sPreferences = context.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE);

        Fresco.initialize(this);
    }

    public static void put(Context context, String key, @NonNull Object object) {
        SharedPreferences.Editor editor = getSharedPreferences(context).edit();
        if (object instanceof String) {
            editor.putString(key, (String) object);
        } else if (object instanceof Integer) {
            editor.putInt(key, (Integer) object);
        } else if (object instanceof Boolean) {
            editor.putBoolean(key, (Boolean) object);
        } else if (object instanceof Float) {
            editor.putFloat(key, (Float) object);
        } else if (object instanceof Long) {
            editor.putLong(key, (Long) object);
        } else {
            editor.putString(key, object.toString());
        }
        editor.apply();
    }

    public static String getString(Context context, String key, String defaultValue) {
        return getSharedPreferences(context).getString(key, defaultValue);
    }

    public static boolean getBoolean(Context context, String key, boolean defaultValue) {
        return getSharedPreferences(context).getBoolean(key, defaultValue);
    }

    public static int getInt(Context context, String key, int defaultValue) {
        return getSharedPreferences(context).getInt(key, defaultValue);
    }

    public static long getLong(Context context, String key, long defaultValue) {
        return getSharedPreferences(context).getLong(key, defaultValue);
    }

    public static void remove(Context context, String key) {
        getSharedPreferences(context).edit().remove(key).apply();
    }

    public static boolean contains(Context context, String key) {
        return getSharedPreferences(context).contains(key);
    }

    private static SharedPreferences getSharedPreferences(Context context) {
        return sPreferences == null ? context.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE) : sPreferences;
    }

    public static void addActivity(Activity activity) {
        activities.add(activity);
    }

    public static void removeActivity(Activity activity) {
        if (activity != null) {
            activities.remove(activity);
        }
    }

    public static void removeActivity(String activityName) {
        boolean isExists = false;
        Activity currentActivity = null;
        for (Activity activity : activities) {
            if (activity.getLocalClassName().equals(activityName)) {
                isExists = true;
                currentActivity = activity;
                break;
            }
        }
        if (isExists && currentActivity != null) {
            currentActivity.finish();
            activities.remove(currentActivity);
        }
    }

    public static boolean checkActivity(String activityName) {
        boolean isExists = false;
        for (Activity activity : activities) {
            if (activity.getLocalClassName().equals(activityName)) {
                isExists = true;
                break;
            }
        }
        return isExists;
    }

    public static Activity getActivity(String activityName) {
        Activity existsActivity = null;
        for (Activity activity : activities) {
            if (activity.getLocalClassName().equals(activityName)) {
                existsActivity = activity;
                break;
            }
        }
        return existsActivity;
    }

    public static void exit() {
        for (Activity activity : activities) {
            if (activity != null) {
                activity.finish();
            }
        }
        System.exit(0);
    }
}