package com.tokbox.android.accpack.screensharing.test;


import android.graphics.PixelFormat;
import android.media.ImageReader;
import android.view.View;

import com.opentok.android.BaseVideoCapturer;
import com.tokbox.android.accpack.screensharing.ScreenSharingCapturer;
import com.tokbox.android.accpack.screensharing.testbase.TestBase;

import junit.framework.Assert;

import org.junit.Test;

public class ScreenSharingCapturerTest extends TestBase{

    public ScreenSharingCapturer screenSharingCapturer;
    private ImageReader imageReader;
    private View view;

    protected void setUp() throws Exception {
        super.setUp();
        imageReader = ImageReader.newInstance(1, 1, PixelFormat.RGBA_8888, 2);
        view = new View(context);
    }

    protected void tearDown() throws Exception {
        super.tearDown();
    }

    @Test
    public void screenSharingBar_When_OK() throws Exception{
        screenSharingCapturer = new ScreenSharingCapturer(context, view, imageReader);
        Assert.assertNotNull(screenSharingCapturer);
        Assert.assertFalse(screenSharingCapturer.isCaptureStarted());
    }

    @Test(expected=Exception.class)
    public void screenSharingBar_When_ContextIsNull() throws Exception{
        screenSharingCapturer = new ScreenSharingCapturer(null, view, imageReader);
    }

    @Test(expected=Exception.class)
    public void screenSharingBar_When_ViewIsNull() throws Exception{
        screenSharingCapturer = new ScreenSharingCapturer(context, null, imageReader);
    }

    @Test(expected=Exception.class)
    public void screenSharingBar_When_ImageIsNull() throws Exception{
        screenSharingCapturer = new ScreenSharingCapturer(context, view, null);
    }

    @Test
    public void startCapture_When_OK() throws Exception{
        screenSharingCapturer = new ScreenSharingCapturer(context, view, imageReader);
        Assert.assertEquals(0, screenSharingCapturer.startCapture());
        Assert.assertTrue(screenSharingCapturer.isCaptureStarted());
    }

    @Test
    public void stopCapture_When_OK() throws Exception{
        screenSharingCapturer = new ScreenSharingCapturer(context, view, imageReader);
        Assert.assertEquals(0, screenSharingCapturer.stopCapture());
        Assert.assertFalse(screenSharingCapturer.isCaptureStarted());
    }

    @Test
    public void getCaptureSettings_When_OK() throws Exception{
        screenSharingCapturer = new ScreenSharingCapturer(context, view, imageReader);
        BaseVideoCapturer.CaptureSettings captureSettings = screenSharingCapturer.getCaptureSettings();
        Assert.assertEquals(2, captureSettings.format);
        Assert.assertEquals(0, captureSettings.width);
        Assert.assertEquals(0, captureSettings.height);
    }

//    @Test
//    public void runnable_When_OK() throws Exception{
//        screenSharingCapturer = new ScreenSharingCapturer(context, new View(context), ImageReader.newInstance(0, 0, PixelFormat.RGBA_8888, 2));
//        Assert.assertNotNull(screenSharingCapturer.newFrame());
//    }

}
