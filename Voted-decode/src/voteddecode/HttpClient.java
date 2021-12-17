package voteddecode;

import okhttp3.*;

import java.io.IOException;
import java.util.Map;

public class HttpClient {

    private static OkHttpClient client = new OkHttpClient();
    public static String  getResponse(String url) throws IOException {
        Request request = new Request.Builder().url(url).build();
        Response response = client.newCall(request).execute();
        return response.body().string();
        }

    public static String getResponse(String url, Map<String,String> params) throws IOException {
        FormBody.Builder builder = new FormBody.Builder();
        if(params!=null) {
            for (String key : params.keySet()) {
                builder.add(key, params.get(key));
            }
        }
        RequestBody body = builder.build();
        Request request = new Request.Builder().url(url).post(body).build();
        Response response = client.newCall(request).execute();
        return response.body().string();
    }
}
