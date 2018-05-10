import Intents
import WenderLoonCore

class IntentHandler: INExtension {

  let simulator = WenderLoonSimulator(renderer: nil)
  
  override func handler(for intent: INIntent) -> Any? {
    if intent is INRequestRideIntent {
      return RideRequestHandler(simulator: simulator)
    }
    return .none
  }
}
