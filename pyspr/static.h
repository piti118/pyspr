#include <SprClassifierReader.hh>
#include <SprAbsTrainedClassifier.hh>

SprAbsTrainedClassifier* ReadClassifier(const char* f){
    return SprClassifierReader::readTrained(f);
}