import UIKit
import Combine


var subscription = Set<AnyCancellable>()

//Filter
example(of: "filter") {
    let numbers = (1...10).publisher
    
    numbers
        .filter { $0.isMultiple(of: 3)}
        .sink(receiveValue: { n in
            print("\(n) is multiple of 3")
        })
        .store(in: &subscription)
}


//removeDuplicates
example(of: "removeDuplicates") {
    let words = "hey hey there! want to listen to mister mister ?".components(separatedBy: " ").publisher
    
    words
        .removeDuplicates()
        .sink(receiveValue: {print($0)})
        .store(in: &subscription)
}

//compactMap
example(of: "compactMap") {
    let strings = ["a", "1.24", "3","def", "45", "0.23"].publisher
    
    strings
        .compactMap { Float($0)}
        .sink(receiveValue: {print($0)})
        .store(in: &subscription)
}

//ignoreOutput
example(of: "ignoreOutput") {
    let numbers = (1...10_000).publisher
    
    numbers
        .ignoreOutput()
        .sink(receiveCompletion: {print("Completed with \($0)")}, receiveValue: {print($0)})
        .store(in: &subscription)
}


//first(where:)
example(of: "first(where:)") {
    let numbers = (1...9).publisher
    
    numbers
        .print("numbers")
        .first(where: {$0 % 2 == 0})
        .sink(receiveCompletion: {print("Completed with \($0)")}, receiveValue: {print($0)})
        .store(in: &subscription)
}


//last(where:)
example(of: "last(where:)") {
    let numbers = (1...9).publisher
    
    numbers
        .print("numbers")
        .last(where: {$0 % 2 == 0})
        .sink(receiveCompletion: {print("Completion with \($0)")}, receiveValue: {print($0)})
        .store(in: &subscription)
}

example(of: "last(where:)") {
    let numbers = PassthroughSubject<Int,Never>()
    
    numbers
        .last(where: {$0 % 2 == 0})
        .sink(receiveCompletion: {print("Completion with \($0)")}, receiveValue: {print($0)})
        .store(in: &subscription)
    
    numbers.send(1)
    numbers.send(2)
    numbers.send(3)
    numbers.send(4)
    numbers.send(5)
    numbers.send(completion: .finished)
}

//dropFirst
example(of: "dropFirst") {
    let numbers = (1...10).publisher
    
    numbers
        .dropFirst(5)
        .sink(receiveValue: {print($0)})
        .store(in: &subscription)
}

//drop(while:
example(of: "drop(while:)") {
    let numbers = (1...10).publisher
    
    numbers
        .drop(while: {$0%5 != 0})
        .sink(receiveValue: {print($0)})
        .store(in: &subscription)
}

example(of: "drop(while:)") {
    let numbers = (1...10).publisher
    
    numbers
        .drop(while: {
            print("x")
            return $0 % 5 != 0
        })
        .sink(receiveValue: {print($0)})
        .store(in: &subscription)
}

//drop(untilOutputFrom:)
example(of: "drop(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void,Never>()
    let taps = PassthroughSubject<Int,Never>()
    
    taps
        .drop(untilOutputFrom: isReady)
        .sink(receiveValue: {print($0)})
        .store(in: &subscription)
    
    (1...10).forEach{ n in
        taps.send(n)
        
        if n == 3{
            isReady.send()
        }
    }
}


//prefix
example(of: "prefix") {
    let numbers = (1...10).publisher
    
    numbers
        .prefix(2)
        .sink(receiveCompletion: {print("Recieved with completion \($0)")}, receiveValue: {print($0)})
        .store(in: &subscription)
}

//prefix(while:)

example(of: "prefix(while:)") {
    let numbers = (1...10).publisher
    
    numbers
        .prefix(while: {$0 < 3})
        .sink(receiveCompletion: {print("Recieved with completion \($0)")}, receiveValue: {print($0)})
        .store(in: &subscription)
}

//prefix(untilOutputFrom:)
example(of: "prefix(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void,Never>()
    let taps = PassthroughSubject<Int,Never>()
    
    taps
        .prefix(untilOutputFrom: isReady)
        .sink(receiveValue: {print($0)})
        .store(in: &subscription)
    
    (1...10).forEach{ n in
        taps.send(n)
        
        if n == 3{
            isReady.send()
        }
    }
}

// Challenge

example(of: "Challenge") {
    let numbers = (1...100).publisher
    
    numbers
        .dropFirst(50)
        .prefix(20)
        .filter{$0 % 2 == 0}
        .sink(receiveValue: {print($0)})
        .store(in: &subscription)
}
