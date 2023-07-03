import 'package:ai_app/classifier.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class ClassifierFloat extends Classifier {
  ClassifierFloat({int? numThreads}) : super(numThreads: numThreads);

  @override
  String get modelName => 'model_lung_1 (1).tflite';

  @override
  NormalizeOp get preProcessNormalizeOp => NormalizeOp(127.5, 127.5);

  @override
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 1);
}

while(p1!= null && 2!= null && p2.next!= null){
    if(p1==p2){
      return true;
    }
    p1 = p1.next;
    p2 = p2.next.next;
}
    return false