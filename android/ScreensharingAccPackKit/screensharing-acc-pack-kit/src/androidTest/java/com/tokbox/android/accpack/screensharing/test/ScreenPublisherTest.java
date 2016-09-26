package com.tokbox.android.accpack.screensharing.test;

import android.content.Context;

import com.opentok.android.BaseVideoCapturer;
import com.tokbox.android.accpack.screensharing.ScreenPublisher;
import com.tokbox.android.accpack.screensharing.testbase.TestBase;
import com.tokbox.android.accpack.screensharing.utils.TestUtils;

import junit.framework.Assert;
import junit.framework.TestResult;

import org.junit.Test;

public class ScreenPublisherTest extends TestBase {

    private ScreenPublisher screenPublisher;

    protected void setUp() throws Exception {
        super.setUp();
    }

    protected void tearDown() throws Exception {
        super.tearDown();
    }

    @Test
    public void screenPublisher_When_OK() throws Exception{
        screenPublisher = new ScreenPublisher(context);
        Assert.assertNotNull(screenPublisher);
    }

    @Test(expected=Exception.class)
    public void screenPublisher_When_ConextIsNull() throws Exception{
        screenPublisher = new ScreenPublisher(null);
    }

    @Test
    public void screenPublisher_When_StringIsOK() throws Exception{
        String name = TestUtils.generateString(6);
        screenPublisher = new ScreenPublisher(context, name);
        Assert.assertNotNull(screenPublisher);
        Assert.assertEquals(name, screenPublisher.getName());
    }

    @Test
    public void screenPublisher_When_StringIsEmpty() throws Exception{
        screenPublisher = new ScreenPublisher(context, "");
        Assert.assertNotNull(screenPublisher);
    }

    @Test
    public void screenPublisher_When_StringIsNull() throws Exception{
        screenPublisher = new ScreenPublisher(context, null);
        Assert.assertNotNull(screenPublisher);
    }

    @Test
    public void screenPublisher_When_StringIsLong() throws Exception{
        String name = TestUtils.generateString(60);
        screenPublisher = new ScreenPublisher(context, name);
        Assert.assertNotNull(screenPublisher);
        Assert.assertEquals(name, screenPublisher.getName());
    }

    @Test(expected=Exception.class)
    public void  screenPublisher_When_CapturerIsNull() throws Exception {
        screenPublisher = new ScreenPublisher(context, TestUtils.generateString(6), null);
    }

    @Test
    public void  screenPublisher_When_CapturerIsOK() throws Exception {
        String name = TestUtils.generateString(6);
        screenPublisher = new ScreenPublisher(context, name, new BaseVideoCapturer() {
            @Override
            public void init() {

            }

            @Override
            public int startCapture() {
                return 0;
            }

            @Override
            public int stopCapture() {
                return 0;
            }

            @Override
            public void destroy() {

            }

            @Override
            public boolean isCaptureStarted() {
                return false;
            }

            @Override
            public CaptureSettings getCaptureSettings() {
                return null;
            }

            @Override
            public void onPause() {

            }

            @Override
            public void onResume() {

            }
        });
        Assert.assertNotNull(screenPublisher);
        Assert.assertEquals(name, screenPublisher.getName());
    }

}
