package com.claudestudio.xpiki;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class MainActivity extends Activity {

    private WebView webView;
    private ValueCallback<Uri[]> uploadMessage;
    private final static int REQUEST_SELECT_FILE = 100;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        webView = new WebView(this);
        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        webSettings.setDatabaseEnabled(true);
        webSettings.setAllowFileAccess(true);
        webSettings.setAllowContentAccess(true);
        webSettings.setAllowFileAccessFromFileURLs(true);
        webSettings.setAllowUniversalAccessFromFileURLs(true);
        webSettings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                webView.evaluateJavascript(
                    "(function() {" +
                    "  try {" +
                    "    if (!localStorage.getItem('api_base_url') && !localStorage.getItem('anthropic_base_url')) {" +
                    "      localStorage.setItem('api_base_url', 'https://api.anthropic.com');" +
                    "      localStorage.setItem('anthropic_base_url', 'https://api.anthropic.com');" +
                    "    }" +
                    "    const origFetch = window.fetch;" +
                    "    window.fetch = async function(resource, init) {" +
                    "      init = init || {};" +
                    "      init.headers = init.headers || {};" +
                    "      if (resource.toString().includes('anthropic.com')) {" +
                    "        if (init.headers instanceof Headers) {" +
                    "          init.headers.set('anthropic-dangerous-direct-browser-access', 'true');" +
                    "        } else {" +
                    "          init.headers['anthropic-dangerous-direct-browser-access'] = 'true';" +
                    "        }" +
                    "      }" +
                    "      return origFetch(resource, init);" +
                    "    };" +
                    "  } catch(e) {}" +
                    "})();", null);
            }
        });
        
        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onShowFileChooser(WebView mWebView, ValueCallback<Uri[]> filePathCallback, WebChromeClient.FileChooserParams fileChooserParams) {
                if (uploadMessage != null) {
                    uploadMessage.onReceiveValue(null);
                    uploadMessage = null;
                }
                uploadMessage = filePathCallback;
                
                try {
                    Intent intent = fileChooserParams.createIntent();
                    startActivityForResult(intent, REQUEST_SELECT_FILE);
                } catch (Exception e) {
                    uploadMessage = null;
                    return false;
                }
                return true;
            }
        });

        webView.loadUrl("file:///android_asset/index.html");
        setContentView(webView);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        if (requestCode == REQUEST_SELECT_FILE) {
            if (uploadMessage == null) return;
            Uri[] results = null;
            if (resultCode == Activity.RESULT_OK) {
                // Use Android's native parser to correctly handle PDF Uris from any file provider
                results = WebChromeClient.FileChooserParams.parseResult(resultCode, intent);
            }
            uploadMessage.onReceiveValue(results);
            uploadMessage = null;
        }
    }

    @Override
    public void onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}