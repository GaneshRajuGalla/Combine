import UIKit
import Combine

var subscriptions = Set<AnyCancellable>()

//MARK: - Combining Operators

//Prepending

//prepend(Output...)
example(of: "prepend(Output...)") {
    let publisher = [3,4].publisher
    
    publisher
        .prepend(1,2)
        .prepend(-1,0)
        .sink(receiveValue: {print($0)})
        .store(in: &subscriptions)
}

//prepend(Sequence)
example(of: "prepend(Sequence)") {
    let publisher = [5,6,7].publisher
    
    publisher
        .prepend([3,4])
        .prepend(Set(1...2))
        .prepend(stride(from: 6, through: 11, by: 2))
        .sink(receiveValue: {print($0)})
        .store(in: &subscriptions)
}

//prepend(Publisher)
example(of: "prepend(Publisher)") {
    let publisher1 = [3,4].publisher
    let publisher2 = [1,2].publisher
    
    publisher1
        .prepend(publisher2)
        .sink(receiveValue: {print($0)})
        .store(in: &subscriptions)
}

//prepend(Publisher) #2
example(of: "prepend(Publisher) #2") {
    let publisher1 = [3,4].publisher
    let publisher2 = PassthroughSubject<Int,Never>()
    
    publisher1
        .prepend(publisher2)
        .sink(receiveValue: {print($0)})
        .store(in: &subscriptions)
    
    publisher2.send(1)
    publisher2.send(2)
    publisher2.send(completion: .finished)
}

//Appending
//append(Output...)
example(of: "append(Output...)") {
    let publisher = [1].publisher
    
    publisher
        .append(2,3)
        .append(4)
        .sink(receiveValue: {print($0)})
        .store(in: &subscriptions)
}

example(of: "append(Output...) #2") {
    let publisher = PassthroughSubject<Int,Never>()
    
    publisher
        .append(3,4)
        .append(5)
        .sink(receiveValue: {print($0)})
        .store(in: &subscriptions)
    
    publisher.send(1)
    publisher.send(2)
    publisher.send(completion: .finished)
}

//append(Sequence)
example(of: "append(Sequence)") {
    let publisher = [1,2,3].publisher
    
    publisher
        .append([4,5])
        .append(Set([6,7]))
        .append(stride(from: 8, to: 11, by: 2))
        .sink(receiveValue: {print($0)})
        .store(in: &subscriptions)
}

//append(Publisher)
example(of: "append(Publisher)") {
    let publisher1 = [1,2].publisher
    let publisher2 = [3,4].publisher
    
    publisher1
        .append(publisher2)
        .sink(receiveValue: {print($0)})
        .store(in: &subscriptions)
}

//Advanced combining
//switchToLatest
example(of: "switchToLatest") {
    let publisher1 = PassthroughSubject<Int,Never>()
    let publisher2 = PassthroughSubject<Int,Never>()
    let publisher3 = PassthroughSubject<Int,Never>()
    
    let publishers = PassthroughSubject<PassthroughSubject<Int,Never>,Error>()
    
    publishers
        .switchToLatest()
        .sink(receiveCompletion: {_ in print("Completed!")}, receiveValue: {print($0)})
        .store(in: &subscriptions)
    
    publishers.send(publisher1)
    publisher1.send(1)
    publisher1.send(2)
    
    publishers.send(publisher2)
    publisher1.send(3)
    publisher2.send(4)
    publisher2.send(5)
    
    publishers.send(publisher3)
    publisher2.send(6)
    publisher3.send(7)
    publisher3.send(8)
    publisher3.send(9)
    
    publisher3.send(completion: .finished)
    publishers.send(completion: .finished)
}

//example(of: "switchToLatest - Network Request") {
//    let url = URL(string: "https://source.unsplash.com/random")!
//
//    func getImage() -> AnyPublisher<UIImage?,Never>{
//        URLSession.shared
//            .dataTaskPublisher(for: url)
//            .map{data,_ in UIImage(data: data)}
//            .print("image")
//            .replaceError(with: nil)
//            .eraseToAnyPublisher()
//    }
//
//    let taps = PassthroughSubject<Void,Never>()
//
//    taps
//        .map{_ in getImage()}
//        .switchToLatest()
//        .sink(receiveValue: {_ in})
//        .store(in: &subscriptions)
//
//    taps.send()
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
//        taps.send()
//    })
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3.1, execute: {
//        taps.send()
//    })
//}

//merge(with:)
example(of: "merge(with:)") {
    let publisher1 = PassthroughSubject<Int,Never>()
    let publisher2 = PassthroughSubject<Int,Never>()
    
    publisher1
        .merge(with: publisher2)
        .sink(receiveValue: {print($0)})
        .store(in: &subscriptions)
    
    publisher1.send(1)
    publisher1.send(2)
    publisher1.send(3)
    publisher2.send(4)
    publisher1.send(5)
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}

//combineLatest
example(of: "combineLatest") {
    let publisher1 = PassthroughSubject<Int,Never>()
    let publisher2 = PassthroughSubject<String,Never>()
    
    publisher1
        .combineLatest(publisher2)
        .sink(receiveCompletion: {_ in print("Completed!")}, receiveValue: {print("p1: \($0), p2: \($1)")})
        .store(in: &subscriptions)
    
    publisher1.send(1)
    publisher1.send(2)
    
    publisher2.send("a")
    publisher2.send("b")
    
    publisher1.send(3)
    
    publisher2.send("c")
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}


//zip
example(of: "zip") {
    let publisher1 = PassthroughSubject<Int,Never>()
    let publisher2 = PassthroughSubject<String,Never>()
    
    publisher1
        .zip(publisher2)
        .sink(receiveCompletion: {_ in print("Completed!")}, receiveValue: {print("p1: \($0), p2: \($1)")})
        .store(in: &subscriptions)
    
    publisher1.send(1)
    publisher1.send(2)
    publisher2.send("a")
    publisher2.send("b")
    publisher1.send(3)
    publisher2.send("c")
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}
