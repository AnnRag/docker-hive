package hdfs;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.URI;
import java.net.URISyntaxException;

public class WriteToHdfs {
    public static void main(String[] args) throws IOException, URISyntaxException {
        Configuration configuration = new Configuration();
        FileSystem hdfs = FileSystem.get(new URI("hdfs://127.0.0.1:9010"), configuration);

        FileStatus[] fileStatus = hdfs.listStatus(new Path("hdfs://localhost:9010/"));
        for (FileStatus status : fileStatus) {
            System.out.println(status.getPath().toString());
        }

        Path file = new Path("hdfs://127.0.0.1:9010/table.csv");
        if (hdfs.exists(file)) {
            hdfs.delete(file, true);
        }
        OutputStream os = hdfs.create(file, () -> {});
        BufferedWriter br = new BufferedWriter(new OutputStreamWriter(os, "UTF-8"));
        br.write("Hello World");
        br.close();
        hdfs.close();
    }
}
