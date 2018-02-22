import ballerina.file;
import ballerina.io;
import ballerina.mime;
import ballerina.net.http;

@http:configuration {
    basePath:"/"
}
service<http> reactServer {

    @http:resourceConfig {
        methods:["GET"],
        path:"/static/*"
    }
    resource staticFileServe (http:Connection conn, http:InRequest req) {
        string srcFilePath = "/home/natasha/Documents/workspace/ballerina-central/build" + req.rawPath;
        http:OutResponse res = serveThis(srcFilePath);
        _ = conn.respond(res);
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/*"
    }
    resource htmlFileServe (http:Connection conn, http:InRequest req) {
        string srcFilePath = "/home/natasha/Documents/workspace/ballerina-central/build/index.html";
        http:OutResponse res = serveThis(srcFilePath);
        _ = conn.respond(res);
    }
}

function getFileChannel (string filePath, string permission) (io:ByteChannel) {
    file:File src = {path:filePath};
    io:ByteChannel channel = src.openChannel(permission);
    return channel;
}

function readBytes (io:ByteChannel channel, int numberOfBytes) (blob, int) {
    blob bytes;
    int numberOfBytesRead;
    bytes, numberOfBytesRead = channel.readBytes(numberOfBytes);
    return bytes, numberOfBytesRead;
}

function getBytesOfFile (io:ByteChannel src) (blob) {
    int bytesChunk = 10000;
    blob readContent;
    int readCount = -1;
    string temp = "";
    while (readCount != 0) {
        readContent, readCount = readBytes(src, bytesChunk);
        temp = temp + readContent.toString("UTF-8");
    }
    blob allContents = temp.toBlob("UTF-8");
    return allContents;
}

function serveThis (string srcFilePath) (http:OutResponse) {

    file:File file = {path:srcFilePath};
    if (!file.exists()) {
        error err = {msg:"File to be served doesnot exists"};
        throw err;
    }
    string contentType = mime:APPLICATION_OCTET_STREAM;
    if (srcFilePath.contains(".js")) {
        contentType = "application/javascript";
    } else if (srcFilePath.contains(".css")) {
        contentType = "text/css";
    } else if (srcFilePath.contains(".html")) {
        contentType = mime:TEXT_HTML;
    }
    http:OutResponse res = {};
    io:ByteChannel src = getFileChannel(srcFilePath, "r");
    blob content = getBytesOfFile(src);
    res.setBinaryPayload(content);
    res.setHeader("Content-Type", contentType);
    return res;

}