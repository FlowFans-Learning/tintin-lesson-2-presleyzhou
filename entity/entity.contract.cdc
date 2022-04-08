pub contract Entity {
  pub event ElementGenerateSuccess(hex:String)
  pub event ElementGenerateFailure(hex:String)


  // 元特征
  pub struct MetaFeature {

    pub let bytes: [UInt8]
    pub let raw: String?

    init(bytes: [UInt8], raw: String?) {
      self.bytes = bytes
      self.raw = raw
    }
  }

  // 元要素
  pub resource Element {

    pub let feature: MetaFeature
    
    init(feature: MetaFeature) {
      self.feature = feature
    }
  }

  // 特征收集器
  pub resource Generator {

    pub let features: {String: MetaFeature}

    init() {
      self.features = {}
    }

    pub fun generate(feature: MetaFeature): @Element? {
      // 只收集唯一的 bytes
      let hex = String.encodeHex(feature.bytes)

      if self.features.containsKey(hex) == false {
        let element <- create Element(feature: feature)
        self.features[hex] = feature
        emit ElementGenerateSuccess(hex:hex)
        return <- element
      } else {
        emit ElementGenerateFailure(hex:hex)
        return nil
      }
    }
  } 
  
  //Q2,创建资源Collection
  pub resource Collection {
    pub let elements : @[Element]
    pub fun deposit(element: @Element){
      self.elements.append(<- element)
    }
    init(){
      self.elements <- []
  } destroy(){
      destroy  self.elements
    }
  //返回MetaFeature Struct
  pub fun getElement():[MetaFeature]{
      var Metas:[MetaFeature] = []
      var index=0
      while index < self.elements.length{
        Metas.append(self.elements[index].feature)
        index = index+1
      }
      return Metas
    }
     
    //定义Withdraw
    pub fun withdraw(hex:String) : @Element?{
      var index = 0
      while index < self.elements.length{
        if self.elements[index].feature.raw == hex {
          return <- self.elements.remove(at: index)
        }
        index = index+1
     }
      return nil }
    }
 
  pub fun createCollection():@Collection{
    return <- create Collection()
  }
  

  init() {
    // 保存到存储空间
    self.account.save(
      <- create Generator(),
      to: /storage/ElementGenerator
    )
    // 链接到公有空间
    self.account.link<&Generator>(
      /public/ElementGenerator, // 共有空间
      target: /storage/ElementGenerator // 目标路径
    )
  }
}
