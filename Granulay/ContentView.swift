import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "camera.filters")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Granulay")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}