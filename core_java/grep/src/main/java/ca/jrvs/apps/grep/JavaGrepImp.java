package ca.jrvs.apps.grep;

import com.sun.corba.se.impl.orb.ORBConfiguratorImpl;
import com.sun.org.slf4j.internal.Logger;
import com.sun.org.slf4j.internal.LoggerFactory;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

public class JavaGrepImp implements JavaGrep {

    final Logger logger = LoggerFactory.getLogger(JavaGrep.class);

    private String regex;
    private String rootPath;
    private String outFile;

    @Override
    public void process() throws IOException {
        List<String> matchedLines = new ArrayList<>();
        List<File> allFiles = this.listFiles(this.rootPath);
        for (File file : allFiles) {
            List<String> lines = this.readLines(file);
            for (String line : lines) {
                // Add line to list if pattern matches
                if (this.containsPattern(line)) {
                    matchedLines.add(line);
                }
            }
        }
        // Write output
        this.writeToFile(matchedLines);
    }

    @Override
    public List<File> listFiles(String rootDir) {
        // Get all current files
        File root = new File(rootDir);
        File[] files = root.listFiles();
        List<File> fileList = new ArrayList<>();
        for (File file : files) {
            if (file.isDirectory()) {
                fileList.addAll(this.listFiles(file.toString()));
            }
            else {
                fileList.add(file); // Only include non-directory files
            }
        }
        return fileList;
    }

    @Override
    public List<String> readLines(File inputFile) throws IOException {
        List<String> lines = new ArrayList<>();
        try {
            BufferedReader reader = new BufferedReader(new FileReader(inputFile));
            String line = reader.readLine();
            while (line != null) {
                lines.add(line);
                line = reader.readLine();
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return lines;
    }

    @Override
    public boolean containsPattern(String line) {
        return Pattern.matches(this.regex, line);
    }

    @Override
    public void writeToFile(List<String> lines) throws IOException {
        BufferedWriter writer = new BufferedWriter(new FileWriter(this.outFile));
        for (String line : lines) {
            writer.write(line + "\n");
        }
        writer.close();
    }

    @Override
    public String getRootPath() {
        return this.rootPath;
    }

    @Override
    public void setRootPath(String rootPath) {
        this.rootPath = rootPath;
    }

    @Override
    public String getRegex() {
        return this.regex;
    }

    @Override
    public void setRegex(String regex) {
        this.regex = regex;
    }

    @Override
    public String getOutFile() {
        return this.outFile;
    }

    @Override
    public void setOutFile(String outFile) {
        this.outFile = outFile;
    }

}
