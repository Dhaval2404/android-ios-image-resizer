package com.github.dhaval2404.imageresizer;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FilenameUtils;

@WebServlet(name = "HelloAppEngine", urlPatterns = { "/image-resizer" })
public class HelloAppEngine extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
		System.out.println("Serve GET Request");

		response.addHeader("Access-Control-Allow-Origin", "*");
		response.addHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE, HEAD");
		response.addHeader("Access-Control-Allow-Headers",
				"X-PINGOTHER, Origin, X-Requested-With, Content-Type, Accept");
		response.addHeader("Access-Control-Max-Age", "1728000");

		PrintWriter out = response.getWriter();
		out.print("Hello World");
		out.flush();
	}

	@Override
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		System.out.println("Serve POST Request");

		response.addHeader("Access-Control-Allow-Origin", "*");
		response.addHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE, HEAD");
		response.addHeader("Access-Control-Allow-Headers",
				"X-PINGOTHER, Origin, X-Requested-With, Content-Type, Accept");
		response.addHeader("Access-Control-Max-Age", "1728000");

		List<FileItem> items;
		try {
			items = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
		} catch (FileUploadException e) {
			e.printStackTrace();
			set401Error(response);
			return;
		}

		FileItem filesItem = null;
		Map<String, String> formFields = new HashMap<>();
		for (FileItem item : items) {
			if (item.isFormField()) {
				String fieldName = item.getFieldName();
				String fieldValue = item.getString();
				formFields.put(fieldName, fieldValue);
				System.out.println(fieldName + "-->" + fieldValue);
			} else {
				filesItem = item;
			}
		}

		if (filesItem != null) {
			String fileName = FilenameUtils.getName(filesItem.getName());
			InputStream targetStream = new DataInputStream(filesItem.getInputStream());
			ImageResizer resizer = new ImageResizer(targetStream, fileName);

			String isAndroid = formFields.get("android");
			String isIos = formFields.get("ios");

			boolean android = false;
			if (isAndroid != null && Boolean.valueOf(isAndroid)) {
				android = true;
			}

			boolean ios = false;
			if (isIos != null && Boolean.valueOf(isIos)) {
				ios = true;
			}

			System.out.println("android->" + android);
			System.out.println("ios->" + ios);

			String baseName = FilenameUtils.getBaseName(fileName);

			response.setContentType("application/zip");
			response.setHeader("Content-disposition", "attachment; filename=" + baseName + ".zip");

			OutputStream out = response.getOutputStream();
			resizer.getByteArrayOutputStream(out, android, ios);
			out.flush();
		}else {
			set401Error(response);
		}
	}

	private void set401Error(HttpServletResponse response) {
		try {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid request parameter");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

}