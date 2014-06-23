package mil.darpa.xdata.jpl;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.commons.cli.CommandLineParser;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;

/**
 * Created by rverma on 6/23/14.
 */
public class GetIPV4Entries {
    public static void main(String[] args) {

        // set up argument parsing
        String filePattern = args[0];
        String outputProduct = args[1];

        SparkConf sparkConf = new SparkConf().setAppName(GetIPV4Entries.class.getName());
        JavaSparkContext sc = new JavaSparkContext(sparkConf);
        JavaRDD<String> ipv4Data = sc.textFile(filePattern);

        PrintWriter printWriter = null;
        try {
            printWriter = new PrintWriter(outputProduct);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        printWriter.write(ipv4Data.first());
        printWriter.close();
    }
}
