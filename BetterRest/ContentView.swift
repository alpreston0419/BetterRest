//
//  ContentView.swift
//  BetterRest
//
//  Created by Maggie Zhou on 1/23/26.
//

import CoreML
import SwiftUI

struct ContentView: View {
    static private var defaultWakeUp: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    @State private var wakeUp: Date = defaultWakeUp
    @State private var sleepAmount: Double = 8.0
    @State private var coffeeAmt = 1
    
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isAlertShown: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper("^[\(coffeeAmt) cup](inflect: true)", value: $coffeeAmt, in: 1...20)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calcBedtime)
            }
            .alert(alertTitle, isPresented: $isAlertShown) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calcBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmt))
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Apologizes, there was a problem calculating your bedtime"
        }
        
        isAlertShown = true
    }
}

#Preview {
    ContentView()
}
