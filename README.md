# TCPSSL

[![Swift][swift-badge]][swift-url]
[![Zewo][zewo-badge]][zewo-url]
[![Platform][platform-badge]][platform-url]
[![License][mit-badge]][mit-url]
[![Slack][slack-badge]][slack-url]
[![Travis][travis-badge]][travis-url]

## Installation

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/VeniceX/TCPSSL.git", majorVersion: 0, minor: 8)
    ]
)
```

## Example
In this example we'll build a simple "reverse-echo" client and server that utilizes a secure SSL socket for sending and receiving messages.

### Client
The client connects to a server available at *serverFQDN*:8443 and sends a string.  It then waits for a response from the server and then exits.

```swift
import TCPSSL

guard Process.arguments.count == 3 else {
    print("Usage:  client serverFQDN string")
    exit(0)
}

let serverFQDN = Process.arguments[1]
let sendData   = Data(Process.arguments[2])

do {
    let connection = try TCPSSLConnection(host:serverFQDN, port:8443)
    try connection.open()
    try connection.send(sendData)
    let data = try connection.receive(upTo:256, timingOut:.never)
} catch {
    print("Client error:  \(error)")
}
```
_serverFQDN_ is the fully qualified domain name of the server to which the client is connecting.  For example, `server.yourdomain.org`.

### Server
The server listens for client SSL connections on port 8443.  Once a secure connection is established with the client the server reads a string sent from the server, reverses it, and then replies back to the client.

```swift
import TCPSSL
import Foundation

guard Process.arguments.count == 4 else {
    print("Usage:  server certificatePath keyPath certificateChainPath")
    exit(0)
}

let certificatePath      = Process.arguments[1]
let keyPath              = Process.arguments[2]
let certificateChainPath = Process.arguments[3]

do {
    let sslServer = try TCPSSLServer(port:8443,
                                     certificate:certificatePath,
                                     privateKey:keyPath,
                                     certificateChain:certificateChainPath)

    while true {
        do {
            let connection = try sslServer.accept(timingOut:.never)
            co {
                do {
                    let data = try connection.receive(upTo:256)
                    let reversed = String(String(data).characters.reversed())
                    try connection.send(Data(reversed), timingOut:.never)
                } catch let dataError {
                    print("Client connection error:  \(dataError)")
                }
            }
       } catch {
            print("Server accept error:  \(error)")
       }
    }
} catch let serverError {
    print("Error:  \(serverError)")
}
```

The SSL-based TCP server requires at a minimum a certificate and key, and will likely require a certificate chain (also referred to as a bundle).

It is important to note that the TCPSSL implementation does not allow self-signed certificates, and that the client will match the server certificate's `CommonName` against the FQDN it connected to.

### Running

**Server**

```
# .build/debug/server ssl/bundle.crt ssl/server.yourdomain.key ssl/bundle.crt
Listening for connections
Client connected
Client data received:  Hello world!
Sending data:          !dlrow olleH
```

**Client**

```
.build/debug/client server.yourdomain.org "Hello world\!"
Sending:    Hello world!
Received:  !dlrow olleH
```

## Dependencies
### macOS

TCPSSL utilizes [Zewo/OpenSSL](https://github.com/Zewo/OpenSSL) and as such requires the [Homebrew version](http://brew.sh) of OpenSSL installed:

```
brew install homebrew/versions/openssl101
brew link openssl --force
```

### Linux

Linux requires both `libgnutls-dev` and `libssl-dev` packages to be installed.  On Debian variants this can be accomplished with:

```
apt-get install libgnutls-dev
apt-get install libssl-dev
```

## Support

If you need any help you can join our [Slack](http://slack.zewo.io) and go to the **#help** channel. Or you can create a Github [issue](https://github.com/Zewo/Zewo/issues/new) in our main repository. When stating your issue be sure to add enough details, specify what module is causing the problem and reproduction steps.

## Community

[![Slack][slack-image]][slack-url]

The entire Zewo code base is licensed under MIT. By contributing to Zewo you are contributing to an open and engaged community of brilliant Swift programmers. Join us on [Slack](http://slack.zewo.io) to get to know us!

## License

This project is released under the MIT license. See [LICENSE](LICENSE) for details.

[swift-badge]: https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat
[swift-url]: https://swift.org
[zewo-badge]: https://img.shields.io/badge/Zewo-0.5-FF7565.svg?style=flat
[zewo-url]: http://zewo.io
[platform-badge]: https://img.shields.io/badge/Platforms-OS%20X%20--%20Linux-lightgray.svg?style=flat
[platform-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[slack-image]: http://s13.postimg.org/ybwy92ktf/Slack.png
[slack-badge]: https://zewo-slackin.herokuapp.com/badge.svg
[slack-url]: http://slack.zewo.io
[travis-badge]: https://travis-ci.org/VeniceX/TCPSSL.svg?branch=master
[travis-url]: https://travis-ci.org/VeniceX/TCPSSL
