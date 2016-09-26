package com.tokbox.android.accpack.screensharing.test;

import com.opentok.android.Connection;
import com.opentok.android.Session;
import com.opentok.impl.ConnectionImpl;
import com.tokbox.android.accpack.AccPackSession;
import com.tokbox.android.accpack.screensharing.ScreenSharingFragment;
import com.tokbox.android.accpack.screensharing.config.APIConfig;
import com.tokbox.android.accpack.screensharing.testbase.TestBase;
import com.tokbox.android.accpack.screensharing.utils.TestUtils;
import com.tokbox.android.annotations.AnnotationsToolbar;

import junit.framework.Assert;

import org.junit.Test;

public class ScreenSharingFragmentTest extends TestBase {

    private ScreenSharingFragment screenSharingFragment;
    private String apiKey = String.valueOf(APIConfig.API_KEY);
    private Connection connection;

    protected void setUp() throws Exception {
        super.setUp(APIConfig.SESSION_ID, APIConfig.TOKEN, APIConfig.API_KEY);
        //Class[] params = {String.class, long.class, String.class};
        //connection = (Connection) TestUtils.getConstructor(Connection.class, params).newInstance(TestUtils.generateString(6), 0, TestUtils.generateString(6));
        connection = new ConnectionImpl(TestUtils.generateString(6), 0, TestUtils.generateString(6));
    }

    protected void tearDown() throws Exception {
        super.tearDown();
    }

    @Test
    public void screenSharingFragment_When_OK() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        Assert.assertNotNull(screenSharingFragment);
    }

    @Test(expected=Exception.class)
    public void screenSharingFragment_When_SessionIsNull() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(null, apiKey);
    }

    @Test(expected=Exception.class)
    public void screenSharingFragment_When_ApiKeyIsNull() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, null);
    }

    @Test(expected=Exception.class)
    public void screenSharingFragment_When_ApiKeyIsEmpty() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, "");
    }

    @Test(expected=Exception.class)
    public void screenSharingFragment_When_ApiKeyIsLongString() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, TestUtils.generateString(50));
    }

    @Test
    public void start_When_OK() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.start();
        Assert.assertTrue(screenSharingFragment.isStarted());
    }

    @Test
    public void stop_When_OK() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.stop();
        Assert.assertFalse(screenSharingFragment.isStarted());
    }

    @Test
    public void onSiganlReceived_When_OK() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, TestUtils.generateString(6), TestUtils.generateString(6), connection);
    }

    @Test(expected=Exception.class)
    public void onSiganlReceived_When_SessionIsNull() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(null, TestUtils.generateString(6), TestUtils.generateString(6), connection);
    }

    @Test
    public void onSiganlReceived_When_TypeIsNull() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, null, TestUtils.generateString(6), connection);
    }

    @Test
    public void onSiganlReceived_When_TypeIsEmpty() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, "", TestUtils.generateString(6), connection);
    }

    @Test
    public void onSiganlReceived_When_TypeIsLong() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, TestUtils.generateString(600), TestUtils.generateString(6), connection);
    }

    @Test
    public void onSiganlReceived_When_DataIsNull() throws Exception {
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, TestUtils.generateString(6), null, connection);
    }
    @Test
    public void onSiganlReceived_When_DataIsEmpty() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, TestUtils.generateString(6), "", connection);
    }

    @Test
    public void onSiganlReceived_When_DataIsLong() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, TestUtils.generateString(6), TestUtils.generateString(600), connection);
    }

    @Test(expected=Exception.class)
    public void onSiganlReceived_When_ConnectionIsNull() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onSignalReceived(session, TestUtils.generateString(6), TestUtils.generateString(6), null);
    }

    @Test
    public void enableAnnotations_When_OK() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.enableAnnotations(true, new AnnotationsToolbar(context));
        Assert.assertTrue(TestUtils.getPrivateField(screenSharingFragment, "isAnnotationsEnabled").get(screenSharingFragment).equals(true));
        screenSharingFragment.enableAnnotations(false, new AnnotationsToolbar(context));
        Assert.assertTrue(TestUtils.getPrivateField(screenSharingFragment, "isAnnotationsEnabled").get(screenSharingFragment).equals(false));
    }

    @Test
    public void enableAudioScreenSharing_When_OK() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.enableAudioScreensharing(true);
        Assert.assertTrue(TestUtils.getPrivateField(screenSharingFragment, "isAudioEnabled").get(screenSharingFragment).equals(true));
        screenSharingFragment.enableAudioScreensharing(false);
        Assert.assertTrue(TestUtils.getPrivateField(screenSharingFragment, "isAudioEnabled").get(screenSharingFragment).equals(false));
    }

    @Test
    public void onPause_When_OK() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onPause();
        Assert.assertFalse(screenSharingFragment.isStarted());
    }

    @Test
    public void onResume_When_OK() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onResume();
        Assert.assertTrue(screenSharingFragment.isStarted());
    }

    @Test
    public void onDestroy_When_OK() throws Exception{
        screenSharingFragment = ScreenSharingFragment.newInstance(session, apiKey);
        screenSharingFragment.onDestroy();
        Assert.assertNull(TestUtils.getPrivateField(screenSharingFragment, "mScreensharingBar").get(screenSharingFragment));
        Assert.assertNull(TestUtils.getPrivateField(screenSharingFragment, "mMediaProjection").get(screenSharingFragment));
    }
}
