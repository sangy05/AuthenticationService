import PackageDescription

let package = Package(
    name: "Authentication",
    targets: [
        Target(
            name: "CyberSynapseRoot",
            dependencies: ["ESCustomMiddleware"]
        ),
        Target(
            name: "ESCustomMiddleware",
            dependencies: []
        )
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 6),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 6),
        .Package(url: "https://github.com/sangy05/Swift-cfenv.git", majorVersion: 4, minor: 0),
        .Package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git", majorVersion: 1, minor: 6)
    ])

