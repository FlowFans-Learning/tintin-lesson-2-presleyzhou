import Entity from "./entity.contract.cdc"

transaction(entityAddress: Address) {

  let message: String
  let element: @Entity.Element?
  let collectionRef : &Entity.Collection?

  prepare(account: AuthAccount) {
    // use get PublicAccount instance by address
    let generatorRef = getAccount(entityAddress)
      .getCapability<&Entity.Generator>(/public/ElementGenerator)
      .borrow()
      ?? panic("Couldn't borrow generator reference.")
    
    self.message = "Hello World"
    let feature = Entity.MetaFeature(
      bytes: self.message.utf8,
      raw: self.message
    )

    // save resource
    self.element <- generatorRef.generate(feature: feature)
    
    self.collectionRef = account
      .getCapability<&Entity.Collection>(/public/ElementCollection)
      .borrow()
    //If Collection not exist
    if self.collectionRef == nil {
      let collection <- Entity.createCollection()  
      //Save it
      account.save(<- collection,
        to:/storage/ElementCollection)
      //Link it
      account.link<&Entity.Collection>(
        /public/ElementCollection,
        target: /storage/ElementCollection
      )
      log("Had create Element collection")
    }
}

  execute {
    if self.element == nil {
      log("Element of feature<".concat(self.message).concat("> already exists!"))
      destroy self.element

    } else {
      if(self.collectionRef == nil) {
        log("This time it don't have element collection")
        destroy self.element
    } else{
      self.collectionRef!.deposit(element: <- self.element!)
      log("Element had deposit")
     }
    }
  }
}