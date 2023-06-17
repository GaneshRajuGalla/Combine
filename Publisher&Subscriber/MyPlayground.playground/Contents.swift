import Foundation
import Combine

//Hello Publisher
example(of: "Publisher") {
    let center = NotificationCenter.default
    let myNotification = Notification.Name("MyNotification")
    let publisher = center.publisher(for: myNotification,object:nil)
    let observer = center.addObserver(forName: myNotification, object: nil, queue: nil) { notification in
        print("Notification recieved!")
    }
    center.post(name: myNotification, object: nil)
    center.removeObserver(observer)
}

//Hello Subscriber
example(of: "Subscriber") {
    let myNotification = Notification.Name("MyNotification")
    let center = NotificationCenter.default
    let publisher = center.publisher(for: myNotification,object:nil)
    let subscription = publisher
        .sink{ _ in
            print("Notification recived from publisher")
        }
    center.post(name: myNotification, object: nil)
    subscription.cancel()
}

//Subscribing with sink(_:_:)
example(of: "Just") {
    let just = Just("Hello World")
    
    _ = just
        .sink(receiveCompletion: {
            print("Recived Completion",$0)
        }, receiveValue: {
            print("Recived Value",$0)
        })
    
    _ = just
        .sink(receiveCompletion: {
            print("Recived completion (another)",$0)
        }, receiveValue: {
            print("Recived value (another)",$0)
        })
}

//Subscribing with assign(to:on:)
example(of: "assign(to:on:)") {
    class SomeObject{
        var value:String = "" {
            didSet{
                print(value)
            }
        }
    }
    
    let object = SomeObject()
    
    let publisher = ["Hello","World"].publisher
    _ = publisher
        .assign(to: \.value, on: object)
}

//Republishing with assign(to:)
example(of: "assign(to:)") {
    class SomeObjcet{
        @Published var value = 0
    }
    
    let object = SomeObjcet()
    
    object.$value
        .sink{
            print($0)
        }
    
    (0..<10).publisher
        .assign(to: &object.$value)
}

//Publisher protocol
//public protocol Publisher {
//  associatedtype Output
//  associatedtype Failure : Error
//  func receive<S>(subscriber: S)
//    where S: Subscriber,
//    Self.Failure == S.Failure,
//    Self.Output == S.Input
//}

//extension Publisher {
//  public func subscribe<S>(_ subscriber: S)
//    where S : Subscriber,
//    Self.Failure == S.Failure,
//          Self.Output == S.Input
//}

//Subscriber protocol:
//public protocol Subscriber:CustomCombineIdentifierConvertible{
//    associatedtype Input
//    associatedtype Failure:Error
//    func recive(subcription:Subscription)
//    func recive(_ input:Self.Input) -> Subscribers.Demand
//    func recive(completion:Subscribers.Completion<Self.Failure>)
//}

// Custom Subscriber
example(of: "Custom Subscriber") {
  let publisher = (1...6).publisher
  
  final class IntSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never

    func receive(subscription: Subscription) {
      subscription.request(.max(3))
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
      print("Received value", input)
      return .none
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
      print("Received completion", completion)
    }
  }
  
  let subscriber = IntSubscriber()

  publisher.subscribe(subscriber)
}


// Hello Future
//example(of: "Future") {
//  func futureIncrement(
//    integer: Int,
//    afterDelay delay: TimeInterval) -> Future<Int, Never> {
//    Future<Int, Never> { promise in
//      print("Original")
//      DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
//        promise(.success(integer + 1))
//      }
//    }
//  }
//
//  // 1
//  let future = futureIncrement(integer: 1, afterDelay: 3)
//
//  // 2
//  future
//    .sink(receiveCompletion: { print($0) },
//          receiveValue: { print($0) })
//    .store(in: &subscriptions)
//
//  future
//    .sink(receiveCompletion: { print("Second", $0) },
//          receiveValue: { print("Second", $0) })
//    .store(in: &subscriptions)
//}


// Hello Subject
example(of: "PassthroughSubject") {
    enum MyError:Error{
        case test
    }

    final class StringSubscriber:Subscriber{
        typealias Input = String

        typealias Failure = MyError

        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }

        func receive(_ input: String) -> Subscribers.Demand {
            print("Recived Value",input)
            return input == "World" ? .max(3) : .none
        }

        func receive(completion: Subscribers.Completion<MyError>) {
            print("Received completion",completion)
        }
    }

    let subscriber = StringSubscriber()

    let subject = PassthroughSubject<String,MyError>()
    subject.subscribe(subscriber)
    let subscription = subject
        .sink(receiveCompletion: {completion in
            print("Recived completion (sink)",completion)
        }, receiveValue: { value in
            print("Recived value (sink)",value)
        })

    subject.send("Hello")
    subject.send("World")
    
    subscription.cancel()
    subject.send("Still there..?")
    subject.send(completion: .failure(MyError.test))
    subject.send(completion: .finished)
    subject.send("How about another one..?")
}

// CurrentValueSubject
example(of: "CurrentValueSubject") {
    var subscriptions = Set<AnyCancellable>()
    let subject = CurrentValueSubject<Int,Never>(0)
    
    subject
        .print()
        .sink(receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
    
    subject.send(1)
    subject.send(2)
    print(subject.value)
    subject.value = 3
    print(subject.value)
    
    subject
        .print()
        .sink(receiveValue: {
            print("Second Subscription \($0)")
        })
        .store(in: &subscriptions)
    
    subject.send(completion: .finished)
}

// Dynamically adjusting demand
example(of: "Dynamically adjusting demand") {
    final class IntSubscriber: Subscriber{
        typealias Input = Int
        
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received Value \(input)")
            
            switch input{
            case 1:
                return .max(2)
            case 3:
                return .max(1)
            default:
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received Completion \(completion)")
        }
    }
    
    let subscriber = IntSubscriber()
    
    let subject = PassthroughSubject<Int,Never>()
    
    subject.subscribe(subscriber)
    subject.send(1)
    subject.send(2)
    subject.send(3)
    subject.send(4)
    subject.send(5)
    subject.send(6)
}

// Type erasure
example(of: "Type erasure") {
    let subject = PassthroughSubject<Int,Never>()
    
    let publisher = subject.eraseToAnyPublisher()
    
    publisher
        .sink(receiveValue: {
            print($0)
        })
        //.store(in: &subscriptions)
    
    subject.send(0)
}


// Challenge
var subscription = Set<AnyCancellable>()

example(of: "Create a Blackjack card dealer") {
  let dealtHand = PassthroughSubject<Hand, HandError>()
  
  func deal(_ cardCount: UInt) {
    var deck = cards
    var cardsRemaining = 52
    var hand = Hand()
    
    for _ in 0 ..< cardCount {
      let randomIndex = Int.random(in: 0 ..< cardsRemaining)
      hand.append(deck[randomIndex])
      deck.remove(at: randomIndex)
      cardsRemaining -= 1
    }
    
    // Add code to update dealtHand here
    if hand.points > 21 {
      dealtHand.send(completion: .failure(.busted))
    } else {
      dealtHand.send(hand)
    }
  }
  
  // Add subscription to dealtHand here
  _ = dealtHand
    .sink(receiveCompletion: {
      if case let .failure(error) = $0 {
        print(error)
      }
    }, receiveValue: { hand in
      print(hand.cardString, "for", hand.points, "points")
    })
  
  deal(3)
}

