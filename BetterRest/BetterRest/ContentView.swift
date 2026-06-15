//
//  ContentView.swift
//  BetterRest
//
//  Created by Tarun on 27/05/26.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
//    @State private var sleepingHours = 8.0
//    @State private var wakeUp = Date.now
    
    //Variables for real app.
//    @State private var wakeUp = Date.now
    @State private var wakeUp = defaultWakeupTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    //To fix the wake up time to 7 am by default.
    static var defaultWakeupTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
//        Stepper("\(sleepingHours.formatted()) hours", value: $sleepingHours, in: 4...12, step: 0.25)
        
        //$sleepingHours means two-way connection of state of varible, reads the values and update the value.
        //sleepingHours means only the writes the current state value.
        
        
        //Datepicker
//        DatePicker("Please enter the date", selection: $wakeUp)
//            .labelsHidden() // for not to show the text.
        
        //Providing data and time,
//        Text(Date.now, format: .dateTime.day().month().year())
//        Text(Date.now, format: .dateTime.hour().minute())
        
        
        
        //Now building the actual app.
        NavigationStack{
            VStack{
                Text("When do you wakeup?")
                    .font(.headline)
                DatePicker("Please enter the time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Desired amount of sleep:")
                    .font(.headline)
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                
                Text("Amount of coffee you drink?")
                    .font(.headline)
                Stepper("\(coffeeAmount) of cup(s)", value: $coffeeAmount, in: 1...20)
            }
            .navigationTitle("Better Rest")
            .toolbar{
                Button("Calculate", action: calculateBedTime)
            }.alert(alertTitle, isPresented: $showingAlert){
                Button("OK") {}
            }message: {
                Text(alertMessage)
            }
        }
        
    }
    
    func exampleDates(){
        //Setting data range from today and tommorrow.
//        let now = Date.now
//        let tommorrow = Date.now.addingTimeInterval(86400)
//        let range = now...tommorrow
        
//        var components = DateComponents()
//        components.hour = 8
//        components.minute = 0
//        let date = Calendar.current.date(from: components) ?? .now
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: .now)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        print("hour \(hour), minute \(minute)")
    }
    
    func calculateBedTime(){
        //Drag and drop mlmodel into our project navigator. I have changed the name as SleepCalculator.
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            //more to come in.
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount)) //we are giving inputs to the model.
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bed time is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }catch{
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
