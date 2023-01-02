import ComposableArchitecture

extension AlertState {
    static func configure(message: String, defaultAction: Action, cancelAction: Action) -> Self {
        return Self(
            title: TextState("Something went wrong"),
            message: TextState(message),
            primaryButton: .default(TextState("Retry"), action: .send(defaultAction)),
            secondaryButton: .cancel(TextState("Ok"), action: .send(cancelAction))
        )
    }
}
