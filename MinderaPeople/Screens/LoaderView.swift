import SwiftUI

struct LoaderView: View {
    var body: some View {
        VStack {
            Image("minderaLoader")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            Text("Please be patient.")
                .customFont(size: .M, weight: .semiBold)
            Text("We are preparing your space.")
                .customFont(size: .M, weight: .regular)
        }
        .padding()
        .navigationBarBackButtonHidden()
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderView()
    }
}
