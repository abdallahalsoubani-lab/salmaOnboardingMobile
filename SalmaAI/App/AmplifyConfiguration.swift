import Foundation
import Amplify
import AWSCognitoAuthPlugin

struct AmplifyConfigurator {
    static let cognitoIdentityPoolId = "us-east-1:1cc0fc03-92dd-471e-a5f6-718ac90ed1e3"
    static let awsRegion = "us-east-1"

    static func configure() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())

            let identityPoolConfig = JSONValue.object([
                "PoolId": .string(cognitoIdentityPoolId),
                "Region": .string(awsRegion)
            ])

            let authConfig = AuthCategoryConfiguration(
                plugins: [
                    "awsCognitoAuthPlugin": .object([
                        "CredentialsProvider": .object([
                            "CognitoIdentity": .object([
                                "Default": identityPoolConfig
                            ])
                        ])
                    ])
                ]
            )

            let config = AmplifyConfiguration(auth: authConfig)
            try Amplify.configure(config)
            print("[SalmaAI] Amplify configured for Face Liveness")
        } catch {
            print("[SalmaAI] Amplify configuration failed: \(error)")
        }
    }
}
