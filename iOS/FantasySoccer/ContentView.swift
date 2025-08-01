import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            DraftView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Draft")
                }
            
            TeamView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("My Team")
                }
            
            LeagueView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("League")
                }
        }
        .accentColor(.green)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 