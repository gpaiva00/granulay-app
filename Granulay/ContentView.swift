import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image("SettingsViewIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.accentColor)
            Text("Granulay")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
