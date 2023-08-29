package ca.jrvs.apps.grep;

import com.sun.org.slf4j.internal.Logger;
import com.sun.org.slf4j.internal.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.util.List;

public class JavaGrepExec {

    final Logger logger = LoggerFactory.getLogger(JavaGrep.class);

    public static void main(String args[]) {
        if (args.length != 3) {
            throw new IllegalArgumentException("USAGE: JavaGrepExec regex rootPath outFile");
        }

        JavaGrepImp javaGrepImp = new JavaGrepImp();
        javaGrepImp.setRegex(args[0]);
        javaGrepImp.setRootPath(args[1]);
        javaGrepImp.setOutFile(args[2]);

        try {
            javaGrepImp.process();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
