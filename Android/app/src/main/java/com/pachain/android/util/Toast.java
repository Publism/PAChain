package com.pachain.android.util;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

public class Toast {
    private final Context context;
    private final Handler handler = new Handler(Looper.getMainLooper());

    public Toast(final Context context) {
        this.context = context;
    }

    public final void postToast(final int textResId, final Object... formatArgs) {
        handler.post(() -> toast(textResId, formatArgs));
    }

    public final void toast(final int textResId, final Object... formatArgs) {
        customToast(textResId, android.widget.Toast.LENGTH_SHORT, formatArgs);
    }

    public final void postToast(final CharSequence text) {
        handler.post(() -> toast(text));
    }

    public final void toast(final CharSequence text) {
        customToast(text, android.widget.Toast.LENGTH_SHORT);
    }

    public final void postLongToast(final int textResId, final Object... formatArgs) {
        handler.post(() -> longToast(textResId, formatArgs));
    }

    public final void longToast(final int textResId, final Object... formatArgs) {
        customToast(textResId, android.widget.Toast.LENGTH_LONG, formatArgs);
    }

    public final void postLongToast(final CharSequence text) {
        handler.post(() -> longToast(text));
    }

    public final void longToast(final CharSequence text) {
        customToast(text, android.widget.Toast.LENGTH_LONG);
    }

    private void customToast(final int textResId, final int duration, final Object... formatArgs) {
        customToast(context.getString(textResId, formatArgs), duration);
    }

    private void customToast(final CharSequence text, final int duration) {
        android.widget.Toast.makeText(context, text, duration).show();
    }
}
