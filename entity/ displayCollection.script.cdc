import Entity from "./entity.contract.cdc"

pub fun main(account:Address):[String]? {
    let acc = getAccount(account)
    let collectionRef = acc.getCapability(/public/ElementCollection)
                            .borrow<&Entity.Collection>()
    if collectionRef == nil {
        log("Account".concat(acc.address.toString()).concat("Don't have element collection"))
        return nil 
    }
    else{
        var items: [String] = []
        for item in collectionRef!.getElement(){
            items.append(item.raw!)
        }
        return items
    }
}