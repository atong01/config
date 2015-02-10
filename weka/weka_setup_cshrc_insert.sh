#!/bin/bash
#weka_setup_cshrc_insert.sh
#Written by Alex Tong February 9, 2015
#CAUTION: This script should only be run once per user!!!
#This scripts adds necessary enviroment variables for a cshell terminall
#   to run weka on Tufts CS servers
exportFile=~/.cshrc
echo "#added by auto script \" weka_setup_cshrc_insert.sh \"
#Written by Alex Tong February 9, 2015
setenv CLASSPATH /r/aiml/ml-software/weka-3-6-11/weka.jar
setenv WEKADATA /r/aiml/ml-software/weka-3-6-11/data/ " >> $exportFile

