//
//  chooseADateView.swift
//  AlDwaaNewApp
//
//  Created by ahmed hussien on 31/08/2023.
//

import SwiftUI

struct servicesBookingView: View {
    
    @State private var selectedMonth: Date = Date()
    @State private var months: [Date] = []
    @State private var isSelectedDay: Date? = nil
    let numberOfMonths = 12
    
    var selectedDay: ((Date?) -> Void)
    var selectedTime: ((String?) -> Void)
    @Binding var timeSlots : [AvaliableTime]?
    
    init(selectedDay: @escaping (Date?) -> Void, selectedTime: @escaping (String?) -> Void, timeSlots: Binding<[AvaliableTime]?>) {
           self.selectedDay = selectedDay
           self.selectedTime = selectedTime
           self._timeSlots = timeSlots
       }
    
    var body: some View {
        VStack {
            HStack{
                Text("Choose a date".localized())
                    .appFont(.headline)
                    .foregroundColor(.theme.primary)
                    
                Spacer()
                
                Picker("Select Month", selection: $selectedMonth) {
                    ForEach(months, id: \.self) { monthDate in
                        Text(monthDate.formattedMonth()).tag(monthDate)
                    }
                }
                .colorMultiply(.theme.primary)
                .pickerStyle(MenuPickerStyle())
                .background(Color.theme.txtDisabled.opacity(0.1))
                .cornerRadius(30)
               
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
           
            HorizontalScrollView (showsIndicators: false){
               HStack(spacing: 10) {
                    let currentDate = Date()
                    let daysToDisplay = selectedMonth.isSameMonthAs(currentDate) ? (Calendar.current.component(.day, from: currentDate)...selectedMonth.numberOfDaysInMonth()): (1...selectedMonth.numberOfDaysInMonth())
                    
                    ForEach(daysToDisplay, id: \.self) { day in
                        let dayDate = Calendar.current.date(bySetting: .day, value: day, of: selectedMonth)!
                        DayCard(date: dayDate)
                            .onTapGesture {
                                isSelectedDay = dayDate
                                selectedDay(dayDate)
                                print("sday : \(dayDate)")
                            }
                            .frame(width: 65)
                            .background(isSelectedDay?.dayNumber() == day ? Color.theme.secondary : Color.clear)
                            .cornerRadius(15)
                    }
               }.padding(.horizontal)
                
            }
        }
        .onAppear {
            months = (0..<numberOfMonths).compactMap { i in
                Calendar.current.date(byAdding: .month, value: i, to: selectedMonth)?.firstDayOfMonth()
            }
        }
        if (isSelectedDay != nil) {
            if let timeSlots = timeSlots{
                TimesScrollView(dateTime: timeSlots, selectedTime: {selectedTime($0)})
            }
        }
    }
}


struct TimesScrollView: View {
    let dateTime : [AvaliableTime]
    @State private var isSelectedTime: String? = nil
    var selectedTime: ((String?) -> Void)

    var body: some View {
        HorizontalScrollView(showsIndicators: false){
                HStack(spacing: 20) {
                   
                    ForEach(dateTime, id: \.time) { item in
                        TimeCard(text: item.time,isSelected: item.time == isSelectedTime)
                            .onTapGesture {
                                print("timeSlots : \(item)")
                                selectedTime(item.dateTime)
                                withAnimation {
                                    isSelectedTime = item.time
                                }
                            }
                    }
                }
                .padding()
        }
       
    }
}

struct TimeCard: View {
    let text: String
    let isSelected: Bool

    var body: some View {
        VStack{
            Image(isSelected ? "dropdownNew" : "")
                .foregroundColor(.theme.secondary)
            
            Text(text)
                .appFont(.subheadline)
                .padding(.horizontal,15)
                .padding(.vertical,5)
                .background(isSelected ? Color.theme.secondary : Color.clear)
                .foregroundColor(Color.theme.primary)
                .cornerRadius(30)
        }
        
    }
}

struct DayCard: View {
    let date: Date
    var body: some View {
        VStack {
            Text(date.shortDayName())
                .appFont(.subheadline)
            Text("\(date.dayNumber())")
                .appFont(.subheadline)
        }
        .padding(10)
        .foregroundColor(.theme.primary)
    }
}

extension Date {
    func formattedMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self)
    }
    
    func numberOfDaysInMonth() -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)!
        return range.count
    }
    
    func firstDayOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
//    func dayNumber() -> String {
//        let calendar = Calendar.current
//        return "\(calendar.component(.day, from: self))"
//    }
    
    func shortDayName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self)
    }
    
    func dayNumber() -> Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: self)
    }
    
    func isSameMonthAs(_ otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let selfComponents = calendar.dateComponents([.year, .month], from: self)
        let otherComponents = calendar.dateComponents([.year, .month], from: otherDate)
        return selfComponents == otherComponents
    }
    
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: self)
    }
    
}

struct chooseADateView_Previews: PreviewProvider {
    static var previews: some View {
        servicesBookingView(selectedDay: { _ in }, selectedTime: { _ in }, timeSlots: .constant([]))
    }
}
