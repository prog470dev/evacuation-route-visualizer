import MapKit

class EvacueeMKPointAnnotation: MKPointAnnotation {
    var id: String!
    var type: Int!
    
    init(id: String, type: Int){
        self.id = id
        self.type = type    //0:人, 1:モノ, 2: 避難所
    }
}
