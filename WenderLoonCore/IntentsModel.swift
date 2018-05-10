import Intents

// The Intents framework uses its own image class (INImage).
public extension UIImage {
  public var inImage: INImage {
    return INImage(imageData: UIImagePNGRepresentation(self)!)
  }
}

// Adds INRideDriver object based on Driver (app's model) data.
public extension Driver {
  public var rideIntentDriver: INRideDriver {
    return INRideDriver(
      personHandle: INPersonHandle(value: name, type: .unknown),
      nameComponents: .none,
      displayName: name,
      image: picture.inImage,
      rating: rating.toString,
      phoneNumber: .none)
  }
}

// Adds INRideVehicle object based on Ballon (app's model) data.
public extension Balloon {
  public var rideIntentVehicle: INRideVehicle {
    let vehicle = INRideVehicle()
    vehicle.location = location
    vehicle.manufacturer = "Hot Air Balloon"
    vehicle.registrationPlate = "B4LL 00N"
    vehicle.mapAnnotationImage = image.inImage
    return vehicle
  }
}
