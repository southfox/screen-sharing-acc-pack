package com.tokbox.android.accpack.screensharing.test;

import android.app.Instrumentation;
import android.test.InstrumentationTestRunner;

import com.tokbox.android.accpack.AccPackSession;
import com.tokbox.android.accpack.screensharing.ScreenSharingBar;
import com.tokbox.android.accpack.screensharing.ScreenSharingFragment;
import com.tokbox.android.accpack.screensharing.config.APIConfig;
import com.tokbox.android.accpack.screensharing.testbase.TestBase;
import junit.framework.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

public class ScreenSharingBarTest extends TestBase {

    private ScreenSharingBar screenSharingBar;
    private String apiKey = String.valueOf(APIConfig.API_KEY);

    protected void setUp() throws Exception {
        super.setUp(APIConfig.SESSION_ID, APIConfig.TOKEN, APIConfig.API_KEY);
    }

    protected void tearDown() throws Exception {
        super.tearDown();
    }

    @Test
    public void screenSharingBar_When_OK() throws Exception{
        screenSharingBar = new ScreenSharingBar(context, ScreenSharingFragment.newInstance(session, apiKey));
        Assert.assertNotNull(screenSharingBar);
    }

    @Test(expected=Exception.class)
    public void screenSharingBar_When_ContextIsNull() throws Exception{
        screenSharingBar = new ScreenSharingBar(null, ScreenSharingFragment.newInstance(session, apiKey));
    }

    @Test(expected=Exception.class)
    public void screenSharingBar_When_ListenerIsNull() throws Exception{
        screenSharingBar = new ScreenSharingBar(context, null);
    }
}
