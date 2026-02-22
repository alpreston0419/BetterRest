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
    
    @State private var predictedSleepTime = defaultWakeUp.formatted(date: .omitted, time: .shortened)

    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: wakeUp, calcBedtime)
                }
                
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount, calcBedtime)
                }
                
                Section("Daily coffee intake") {
                    Picker("^[\(coffeeAmt) cup](inflect: true)", selection: $coffeeAmt) {
                        ForEach(0...20, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .onChange(of: coffeeAmt, calcBedtime)
                }
            }
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $isAlertShown) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            
            Text("Ideal Sleep Time: \(predictedSleepTime)")
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
            
            predictedSleepTime = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            isAlertShown = true
            alertTitle = "Error"
            alertMessage = "Apologizes, there was a problem calculating your bedtime"
        }
        
        
    }
}

#Preview {
    ContentView()
}
