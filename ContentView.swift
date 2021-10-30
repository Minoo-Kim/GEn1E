// Need to make log-in page somewhere for names of doctors (assinging) and nurses (assigned)

import SwiftUI
struct ContentView: View {
    var body: some View {
        NavigationView{
            VStack(){
                Spacer()
                // For doctors
                NavigationLink(destination:DoctorView()){
                    Text("Doctor")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                }
                Spacer()
                // For nurses
                NavigationLink(destination:NurseView()){
                    Text("Nurse")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                }
                Spacer()
            }
        }
    }
}

// Doctor's screen
struct DoctorView: View{
    var body: some View{
        VStack(){
           Spacer()
            // Text-input only for now
            NavigationLink(destination:TextInput()){
                Text("Input")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
            }
            Spacer()
            // Dashboard
            NavigationLink(destination:DashboardView()){
                Text("Dashboard")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
            }
            Spacer()
        }
    }
}

struct TextInput: View{
    var body: some View{
        VStack(spacing: 10.0){
            TextField("Patient name", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/).padding()
            TextField("Medication", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/).padding()
            TextField("Quantity", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/).padding()
            TextField("Time", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/).padding()
            TextField("Nurse name", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/).padding()
            TextField("Additional notes", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/).padding()
        }
    }
}

// Nurse's screen
struct NurseView: View{
    var body: some View{
        VStack(){
           Spacer()
            // Text-input only for now
            NavigationLink(destination:CheckInView()){
                Text("Check-in")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
            }
            Spacer()
            // Dashboard
            NavigationLink(destination:DashboardView()){
                Text("Dashboard")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
            }
            Spacer()
        }
    }
}

struct CheckInView: View{
    var body: some View{
        Text("This is the check-in page")
    }
}

// For both doctors and nurses
struct DashboardView: View{
    var body: some View{
        Text("This is the Dashboard")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
