//
//  ContentView.swift
//  BetterRest
//
//  Created by MJ Ajiduah on 6/6/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime // current date
    @State private var sleepAmount = 8.0 // preferred amt of sleep
    @State private var coffeeAmount = 1 // how much coffee user drinks
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    // default wake time is set to 7AM on the current date
    // variable is state since it belongs to the ContentView struct
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("When do you want to wake up?")) {
                    // allow the user to choose the hr and min they want to wake up
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section(header: Text("Desired amount of sleep")) {
                    // let the users choose roughly how much sleep they want
                    // range of 4 to 12 hours in increments of 0.25hrs
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section(header: Text("Daily coffee intake")) {
                    // allow the user to choose how much coffee they want to drink
                    // range of 1 to 20 cups of coffee/day
                    // use Markdown format to tell SwiftUI that the word cup needs to be inflected to match whatever is in the coffeeAmount variable
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
                }
                
                Section(header: Text("Recommended bedtime")) {
                    Text("\(calculateBedtime())")
                        .font(.title2.bold())
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    func calculateBedtime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            // get DateComponents by calling them from Calendar
            // we will then pass these hr & min components into the wake up date
            // convert hr & min components into units of seconds
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            // feed our values into CoreML and see what the ML model predicts
            // use double type for variable values
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            // calculate the exact time the user should go to sleep
            let sleepTime = wakeUp - prediction.actualSleep
            
            let bedTime = sleepTime.formatted(date: .omitted, time: .shortened)
            return bedTime
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
        }
        
        return ""
    }
}



#Preview {
    ContentView()
}
