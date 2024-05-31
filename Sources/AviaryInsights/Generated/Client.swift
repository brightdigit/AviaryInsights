// Generated by swift-openapi-generator, do not modify.
@_spi(Generated) import OpenAPIRuntime
#if os(Linux)
@preconcurrency import struct Foundation.URL
@preconcurrency import struct Foundation.Data
@preconcurrency import struct Foundation.Date
#else
import struct Foundation.URL
import struct Foundation.Data
import struct Foundation.Date
#endif
import HTTPTypes
/// Plausible API allows you to record pageviews or custom events.
internal struct Client: APIProtocol {
    /// The underlying HTTP client.
    private let client: UniversalClient
    /// Creates a new client.
    /// - Parameters:
    ///   - serverURL: The server URL that the client connects to. Any server
    ///   URLs defined in the OpenAPI document are available as static methods
    ///   on the ``Servers`` type.
    ///   - configuration: A set of configuration values for the client.
    ///   - transport: A transport that performs HTTP operations.
    ///   - middlewares: A list of middlewares to call before the transport.
    internal init(
        serverURL: Foundation.URL,
        configuration: Configuration = .init(),
        transport: any ClientTransport,
        middlewares: [any ClientMiddleware] = []
    ) {
        self.client = .init(
            serverURL: serverURL,
            configuration: configuration,
            transport: transport,
            middlewares: middlewares
        )
    }
    private var converter: Converter {
        client.converter
    }
    /// Record a pageview or custom event
    ///
    /// - Remark: HTTP `POST /event`.
    /// - Remark: Generated from `#/paths//event/post`.
    internal func post_sol_event(_ input: Operations.post_sol_event.Input) async throws -> Operations.post_sol_event.Output {
        try await client.send(
            input: input,
            forOperation: Operations.post_sol_event.id,
            serializer: { input in
                let path = try converter.renderedPath(
                    template: "/event",
                    parameters: []
                )
                var request: HTTPTypes.HTTPRequest = .init(
                    soar_path: path,
                    method: .post
                )
                suppressMutabilityWarning(&request)
                let body: OpenAPIRuntime.HTTPBody?
                switch input.body {
                case let .json(value):
                    body = try converter.setRequiredRequestBodyAsJSON(
                        value,
                        headerFields: &request.headerFields,
                        contentType: "application/json; charset=utf-8"
                    )
                }
                return (request, body)
            },
            deserializer: { response, responseBody in
                switch response.status.code {
                case 202:
                    return .accepted(.init())
                default:
                    return .undocumented(
                        statusCode: response.status.code,
                        .init(
                            headerFields: response.headerFields,
                            body: responseBody
                        )
                    )
                }
            }
        )
    }
}
