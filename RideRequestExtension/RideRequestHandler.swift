import Intents
import WenderLoonCore

class RideRequestHandler: NSObject, INRequestRideIntentHandling {

  let simulator: WenderLoonSimulator

  init(simulator: WenderLoonSimulator) {
    self.simulator = simulator
    super.init()
  }

  func handle(intent: INRequestRideIntent,
              completion: @escaping (INRequestRideIntentResponse) -> Void) {
    guard let pickup = intent.pickupLocation?.location else {
      let response = INRequestRideIntentResponse(code: .failure, userActivity: .none)
      completion(response)
      return
    }

    let dropoff = intent.dropOffLocation?.location ?? pickup.randomPointWithin(radius: 10_000)

    let response: INRequestRideIntentResponse

    if let balloon = simulator.requestRide(pickup: pickup, dropoff: dropoff) {
      let status = INRideStatus()
      status.rideIdentifier = balloon.driver.name
      status.phase = .confirmed
      status.vehicle = balloon.rideIntentVehicle
      status.driver = balloon.driver.rideIntentDriver
      status.estimatedPickupDate = balloon.etaAtNextDestination
      status.pickupLocation = intent.pickupLocation
      status.dropOffLocation = intent.dropOffLocation

      response = INRequestRideIntentResponse(code: .success, userActivity: .none)
      response.rideStatus = status
    } else {
      response = INRequestRideIntentResponse(code: .failureRequiringAppLaunchNoServiceInArea, userActivity: .none)
    }

    completion(response)
  }


  // Required parameter: Pickup location.
  func resolvePickupLocation(for intent: INRequestRideIntent,
                             with completion: @escaping (INPlacemarkResolutionResult) -> Void) {
    if let pickup = intent.pickupLocation {
      completion(.success(with: pickup))
    } else {
      completion(.needsValue())
    }
  }

  // Required parameter: Dropoff location.
  func resolveDropOffLocation(for intent: INRequestRideIntent,
                              with completion: @escaping (INPlacemarkResolutionResult) -> Void) {
    if let dropOff = intent.dropOffLocation {
      completion(.success(with: dropOff))
    } else {
      completion(.notRequired())
    }
  }

  // Required parameter: Party size.
  func resolvePartySize(for intent: INRequestRideIntent,
                        with completion: @escaping (INIntegerResolutionResult) -> Void) {
    switch intent.partySize {
    case .none:
      completion(.needsValue())
    case let .some(p) where simulator.checkNumberOfPassengers(p):
      completion(.success(with: p))
    default:
      completion(.unsupported())
    }
  }

  // Called once all the parameters are resolved.
  func confirm(intent: INRequestRideIntent,
               completion: @escaping (INRequestRideIntentResponse) -> Void) {
    let responseCode: INRequestRideIntentResponseCode
    if let location = intent.pickupLocation?.location, simulator.pickupWithinRange(location) {
      responseCode = .ready
    } else {
      responseCode = .failureRequiringAppLaunchNoServiceInArea
    }
    let response = INRequestRideIntentResponse(code: responseCode, userActivity: nil)
    completion(response)
  }
}
