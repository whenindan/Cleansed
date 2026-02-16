import SwiftUI

struct PlanView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "crown.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.yellow)

            Text("Premium Plan")
                .font(.title)
                .bold()

            Text("Unlock all features with our premium plan.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button(action: {
                // Placeholder action
            }) {
                Text("Subscribe Now")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle("Plan")
    }
}

#Preview {
    PlanView()
}
