import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.SparkConf
import java.util.logging.Logger
import scala.collection.mutable.ArrayBuffer
import java.io._

package mil.darpa.xdata.jpl.netscan {
	object GetIPV4RandomSample {
		
		val LOG : Logger = Logger.getLogger(this.getClass.getName)

		// constants
		val DEFAULT_OUTPUT_FILE = "/tmp/"+this.getClass.getName

		def main(args : Array[String]) {
			
			var output_file = ""
			if (args.length != 1) {
				LOG.warning("No output file defined, using default output file "
					+DEFAULT_OUTPUT_FILE)
				output_file = DEFAULT_OUTPUT_FILE
			} else {
				output_file = args(0)
			}

			// Initialize Spark
			val conf = new SparkConf().setAppName(this.getClass.getName)
			val sc = new SparkContext(conf)

			// Spark custom actions go here
			val netscan_port80_data = sc.textFile("hdfs://xd-namenode.xdata.data-tactics-corp.com:8020/SummerCamp2014/voldemort-serviceprobes/port=80/*")
			val netscan_port80_data_random_sample = 
				netscan_port80_data.takeSample(false, 1000)

			var ip_servers : ArrayBuffer[(String, String)] = new ArrayBuffer()
			for (netscan_entry <- netscan_port80_data_random_sample) {
				val server_name = extractServerName(netscan_entry)
				val ip = netscan_entry.split("[^a-zA-Z_0-9\\.]")(3)

				ip_servers.append((ip, server_name))
			}

			// Write results to output file
			val writer = new PrintWriter(new File(output_file))
			for (entry <- ip_servers) {
				writer.write(entry+"\n")
			}
			writer.close

		}

		def extractServerName(httpdump : String) : String = {
			val server_prefix = "Server:=20"
			val start_index = httpdump.indexOf(server_prefix)

			if (start_index == -1) {
				""
			} else {
				val end_index = httpdump.indexOf("=0D=0A", start_index)

				if (end_index == -1) {
					""
				}
				else {
 					httpdump.substring(start_index + server_prefix.length, end_index)
 				}
 			}
		}

	}
}