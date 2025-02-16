protocol ServiceLocating {
    func resolve<T>() -> T?
}

final class ServiceLocator: ServiceLocating {

    static let shared = ServiceLocator()

    private lazy var services = [String: Any]()

    // MARK: - Init

    private init() {}

    // MARK: - Internal

    func register<T>(service: T) {
        let key = typeName(T.self)
        services[key] = service
    }

    func resolve<T>() -> T? {
        let key = typeName(T.self)
        return services[key] as? T
    }

    // MARK: - Private

    private func typeName(_ some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }
}
