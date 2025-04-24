//
//  ViewModelType.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import Combine

protocol ViewModelType: AnyObject, ObservableObject {
    associatedtype Input
    associatedtype Output
    associatedtype Action
    
    var cancellables: Set<AnyCancellable> { get set }
    
    var input: Input { get set }
    var output: Output { get set }
    
    func transform()
    
    func action(_ action: Action)
}
