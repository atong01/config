
#on "linux", assuming your shell is bash, you should "source" this file.
# otherwise, adjust to set environment variables CLASSPATH and WEKADATA 

setenv CLASSPATH /r/aiml/ml-software/weka-3-6-11/weka.jar
setenv WEKADATA /r/aiml/ml-software/weka-3-6-11/data/

# then you should be able to use the weka system as in 

#java weka.gui.GUIChooser
#java weka.classifiers.trees.J48 -t $WEKADATA/weather.numeric.arff
#java weka.classifiers.trees.J48 -t $WEKADATA/weather.nominal.arff
#java weka.classifiers.trees.J48 -t $WEKADATA/iris.arff
