//
//  OperationAdditions.swift
//  SwiftBeginner-L2
//
//  Created by Andrey Stecenko on 11/20/19.
//  Copyright © 2019 Andrii Stetsenko. All rights reserved.
//

import Foundation

class OperationWhithFinished: Operation {
    var currentState: Bool = false
    
    // если мы используем (работаем) с переменными "isFinished" где-то внутри операций то по документации (рекомендациям) APPLE нужно обязательно обязательно переопределить геттеры и сеттеры, нужно воспользоваться "KeyValue observing"
    override var isFinished: Bool {
        // если мы получаем, то мы просто возвращаем текущее состояние
        get {
            return currentState
        }

        // но если мы устанавливаем (задаем) новое значение, то нужно вызвать следующие функции и указать в качестве ключа название переменной "isFinished"
        set (newValue) {
            willChangeValue(forKey: "isFinished")
            currentState = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
}
