package com.github.dhaval2404.imageresizer;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.imageio.ImageIO;

import org.apache.commons.io.FilenameUtils;

import com.mortennobel.imagescaling.ResampleFilters;
import com.mortennobel.imagescaling.ResampleOp;


public class ImageResizer {

	private final String mFileName;
    private final String mFileBaseName;
    private final String mExtention;
    private final InputStream mInputStream;

    private ZipOutputStream mZipOutputStream;
    private BufferedImage mBufferedImage;

    public ImageResizer(InputStream inputStream, String fileName) {
        this.mInputStream = inputStream;
        this.mFileName = fileName;
        this.mFileBaseName = FilenameUtils.getBaseName(fileName);
        this.mExtention = FilenameUtils.getExtension(fileName);
    }

    /**
     * This if for remote usage
     */
    public ByteArrayOutputStream getByteArrayOutputStream(boolean isAndroid, boolean isIos) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        mZipOutputStream = new ZipOutputStream(baos);
        performResizeOperation(isAndroid, isIos);
        mZipOutputStream.close();
        return baos;
    }

    public void getByteArrayOutputStream(OutputStream baos, boolean isAndroid, boolean isIos) throws IOException {
        mZipOutputStream = new ZipOutputStream(baos);
        performResizeOperation(isAndroid, isIos);
        mZipOutputStream.close();
    }

    /**
     * This is for local testing only
     */
    public void getFileOutputStream(boolean isAndroid, boolean isIos) throws IOException {
        String baseName = FilenameUtils.getBaseName(mFileName);
        FileOutputStream fileOutputStream = new FileOutputStream(baseName + ".zip");
        mZipOutputStream = new ZipOutputStream(fileOutputStream);
        performResizeOperation(isAndroid, isIos);
        mZipOutputStream.close();
    }

    private void performResizeOperation(boolean isAndroid, boolean isIos) throws IOException {
        mBufferedImage = ImageIO.read(mInputStream);
        if (isAndroid) {
            float width = mBufferedImage.getWidth() / 4f;
            float height = mBufferedImage.getHeight() / 4f;
            androidResizeOperation(width, height);
        }

        if(isIos){
            float width = mBufferedImage.getWidth() / 3f;
            float height = mBufferedImage.getHeight() / 3f;
            iosResizeOperation(width, height);
        }
    }

    private void androidResizeOperation(float width, float height) throws IOException {
        putAndroidEntry("mdpi", width, height);
        putAndroidEntry("hdpi", width * 1.5f, height * 1.5f);
        putAndroidEntry("xhdpi", width * 2f, height * 2f);
        putAndroidEntry("xxhdpi", width * 3f, height * 3f);
        putAndroidEntry("xxxhdpi", width * 4f, height * 4f);
    }

    private void iosResizeOperation(float width, float height) throws IOException {
        putIphoneEntry("", width, height);
        putIphoneEntry("@2x", width * 2f, height * 2f);
        putIphoneEntry("@3x", width * 3f, height * 3f);
    }

    private void putAndroidEntry(String density, float width, float height) throws IOException {
        String entryName = "drawable-" + density + "/" + mFileName;
        putEntry(entryName, width, height);
    }

    private void putIphoneEntry(String density, float width, float height) throws IOException {
        String entryName = mFileBaseName + density + "." + mExtention;
        putEntry(entryName, width, height);
    }

    private void putEntry(String entryName, float width, float height) throws IOException {
        ZipEntry entry = new ZipEntry(entryName);
        mZipOutputStream.putNextEntry(entry);

        ByteArrayOutputStream os = resizeImage((int) width, (int) height);
        mZipOutputStream.write(os.toByteArray());

        mZipOutputStream.closeEntry();
    }

    private ByteArrayOutputStream resizeImage(int width, int height) throws IOException {
        ResampleOp resizeOp = new ResampleOp(width, height);
        resizeOp.setFilter(ResampleFilters.getLanczos3Filter());
        BufferedImage scaledImage = resizeOp.filter(mBufferedImage, null);
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ImageIO.write( scaledImage, mExtention, os);
        return os;
    }

}
