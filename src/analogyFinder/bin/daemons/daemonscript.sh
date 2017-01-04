#! /bin/sh
#  /etc/init.d/codewebsindexdaemon

### BEGIN INIT INFO
# Provides:          mydaemon
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Short-Description: Starts the MyDaemon service
# Description:       This file is used to start the daemon
#                    and should be placed in /etc/init.d
### END INIT INFO

NAME="codewebsindexdaemon"
DESC="CodewebsIndexDaemon service"

# The path to Jsvc
EXEC="/usr/bin/jsvc -verbose -debug -Xms10g -Xmx10g"

# The path to the folder containing MyDaemon.jar
FILE_PATH="/usr/local/codewebsindexdaemon"

# The path to the folder containing the java runtime
JAVA_HOME="/usr/lib/jvm/java-6-openjdk-amd64/"

# Our classpath including our jar file and the Apache Commons Daemon library
CLASS_PATH="$FILE_PATH/CodewebsIndexDaemon.jar:$FILE_PATH/commons-daemon-1.0.15/commons-daemon-1.0.15.jar:$FILE_PATH/rabbitmq/rabbitmq-client.jar:$FILE_PATH/commons-math3-3.2/commons-math3-3.2.jar"

# The fully qualified name of the class to execute
CLASS="daemons.CodewebsIndexDaemon"

# Any command line arguments to be passed to the our Java Daemon implementations init() method 
#ARGS="myArg1 myArg2 myArg3"

#The user to run the daemon as
USER="root"

# The file that will contain our process identification number (pid) for other scripts/programs that need to access it.
PID="/var/run/$NAME.pid"

# System.out writes to this file...
LOG_OUT="$FILE_PATH/log/$NAME.out"

# System.err writes to this file...
LOG_ERR="$FILE_PATH/err/$NAME.err"

jsvc_exec()
{   
    cd $FILE_PATH
    $EXEC -home $JAVA_HOME -cp $CLASS_PATH -user $USER -outfile $LOG_OUT -errfile $LOG_ERR -pidfile $PID $1 $CLASS $ARGS
}

case "$1" in
    start)  
        echo "Starting the $DESC..."        
        
        # Start the service
        jsvc_exec
        
        echo "The $DESC has started."
    ;;
    stop)
        echo "Stopping the $DESC..."
        
        # Stop the service
        jsvc_exec "-stop"       
        
        echo "The $DESC has stopped."
    ;;
    restart)
        if [ -f "$PID" ]; then
            
            echo "Restarting the $DESC..."
            
            # Stop the service
            jsvc_exec "-stop"
            
            # Start the service
            jsvc_exec
            
            echo "The $DESC has restarted."
        else
            echo "Daemon not running, no action taken"
            exit 1
        fi
            ;;
    *)
    echo "Usage: /etc/init.d/$NAME {start|stop|restart}" >&2
    exit 3
    ;;
esac
