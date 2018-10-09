package edu.washington.cs.nl35;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.InetSocketAddress;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

public class MicroBenchmarkServer
{
    public static void main( String[] args )
    {
        final String usage = "usage: ./MicroBenchmarkServer hostname port";
        if (args.length < 2) {
            System.err.println(usage);
            System.exit(1);
        }
        String hostname = args[0];
        int port = Integer.parseInt(args[1]);
        InetSocketAddress addr = new InetSocketAddress(hostname, port);

        HttpServer server = null;
        try {
            server = HttpServer.create(addr, 0);
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        }
        server.createContext("/arraydata", new HttpHandler() {
            public void handle(HttpExchange exchange) throws IOException {
                int payloadSizeBytes = 4;
                if (exchange.getRequestURI().getQuery() != null) {
                    String[] querySplit = exchange.getRequestURI().getQuery().split("&");
                    for (String queryParam : querySplit) {
                        String[] queryParamSplit = queryParam.split("=");
                        String key = queryParamSplit[0];
                        String value = queryParamSplit[1];
                        if (key.equals("size")) {
                            payloadSizeBytes = Integer.parseInt(value);
                        }
                    }
                }

                exchange.sendResponseHeaders(200, payloadSizeBytes);
                OutputStream output = exchange.getResponseBody();
                BufferedOutputStream bufferedOutput = new BufferedOutputStream(output);
                for (int i = 0; i < payloadSizeBytes; i++) {
                    bufferedOutput.write(42);
                }
                bufferedOutput.close();
                exchange.close();
            }
        });
        server.start();
    }
}
