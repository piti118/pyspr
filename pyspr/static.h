#include <SprClassifierReader.hh>
#include <SprAbsTrainedClassifier.hh>
#include <SprAbsVarTransformer.hh>
#include <SprVarTransformerReader.hh>
SprAbsTrainedClassifier* ReadClassifier(const char* f){
    return SprClassifierReader::readTrained(f);
}

static SprAbsVarTransformer* ReadTransformer(const char* filename){
    return SprVarTransformerReader::read(filename);
}