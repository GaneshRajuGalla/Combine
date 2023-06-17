import UIKit
import Combine


let notification = Notification(name: .NSSystemClockDidChange,object: nil,userInfo: nil)
let clockNotification = NotificationCenter.default.publisher(for: .NSSystemClockDidChange)
    .sink(receiveValue: {(value) in
        print("Value is \(value)")
    })
NotificationCenter.default.post(notification)

let _ = Just("Hello World")
    .sink{(value) in
        print("Value is \(value)")
    }

[1,5,9]
    .publisher
    .map{$0 * $0}
    .sink{print($0)}


let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!

struct Task:Decodable{
    let id:Int
    let title:String
    let userId:Int
    let body:String
}


let dataPublisher = URLSession.shared.dataTaskPublisher(for: url)
    .map{$0.data}
    .decode(type: [Task].self, decoder: JSONDecoder())

let cancellableSink = dataPublisher
    .sink(receiveCompletion: {completion in
        print(completion)
    }, receiveValue: {itmes in
        print("Result \(itmes[0].title)")
    })

// MARK: Assign
let lable = UILabel()
Just("Ganesh")
    .map{"My Name is \($0)"}
    .assign(to: \.text, on: lable)

//(1) Declare an Int PassthroughSubject
let subject = PassthroughSubject<Int,Never>()
//(2) Attch a subscriber to subject
let subscription = subject
    .sink{print($0)}
//(3) Publish the value '94' via the subject,directlt
subject.send(94)
//(4) Connect subject to a publisher,and publish the value '29'
Just(29)
    .subscribe(subject)
//(5) Declare Another subject, a CurrentvalueSubject, with an initial "I am a value cached"
let anotherSubjcet = CurrentValueSubject<String,Never>("I am a...")
//(6) Attach a subscriber to the subject
let anothersubscriber = anotherSubjcet
    .sink{print($0)}
//(7) Publish a value "Subjcet" via the subject directly
anotherSubjcet.send("Subject")

// Simple use of Future in a Function
enum FutureError:Error{
    case notMultiple
}

let future = Future<String,FutureError>{ promise in
    let calender = Calendar.current
    let second = calender.component(.second, from: Date())
    print("Seconds is : \(second)")
    if second.isMultiple(of: 3){
        promise(.success("We are successful:\(second)"))
    }else{
        promise(.failure(.notMultiple))
    }
}.catch{error in
    Just("Caught the error")
}
.delay(for: .init(1), scheduler: RunLoop.main)
.eraseToAnyPublisher()

future.sink(receiveCompletion: {print($0)}, receiveValue: {print($0)})


// Challenge
let textField = UITextField()
let array = [true,false,true,false,false,false,true,true]
let publisher = array.publisher
let subscriber = publisher.assign(to: \.isEnabled, on: textField)
textField.publisher(for: \.isEnabled).sink{print($0)}
let _ = publisher.dropFirst(2).sink{print($0)}
