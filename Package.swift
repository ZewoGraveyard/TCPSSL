import PackageDescription

let package = Package(
    name: "TCPSSL",
    dependencies: [
        .Package(url: "https://github.com/Zewo/TCP.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/OpenSSL.git", majorVersion: 0, minor: 4),
    ]
)
