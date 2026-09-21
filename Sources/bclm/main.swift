import ArgumentParser
import Foundation


enum BCLMKey {
    static let high   = SMCKit.getKey("bfD0", type: DataTypes.UInt32)
    static let low    = SMCKit.getKey("bfE0", type: DataTypes.UInt32)
    static let status = SMCKit.getKey("bfF0", type: DataTypes.UInt8)
}


extension SMCKit {
    static func readUInt8(_ key: SMCKey) throws -> UInt8 {
        let bytes = try readData(key)
        return bytes.0
    }

    static func writeUInt8(_ key: SMCKey, value: UInt8) throws {
        var bytes: SMCBytes = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        bytes.0 = value
        try writeData(key, data: bytes)
    }

    static func readUInt32(_ key: SMCKey) throws -> UInt32 {
        let bytes = try readData(key)
        let raw = withUnsafeBytes(of: (bytes.0, bytes.1, bytes.2, bytes.3)) {
            $0.load(as: UInt32.self)
        }
        return UInt32(littleEndian: raw)
    }

    static func writeUInt32(_ key: SMCKey, value: UInt32) throws {
        var bytes: SMCBytes = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        withUnsafeMutableBytes(of: &bytes) { ptr in
            ptr.storeBytes(of: value.littleEndian, as: UInt32.self)
        }
        try writeData(key, data: bytes)
    }
}


struct BCLM: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Battery Charge Level Max Utility",
        subcommands: [Read.self, Write.self]
    )

    struct Read: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Reads status and limit values directly"
        )

        func run() throws {
            try SMCKit.open()

            let highVal   = try SMCKit.readUInt32(BCLMKey.high)
            let lowVal    = try SMCKit.readUInt32(BCLMKey.low)
            let statusVal = try SMCKit.readUInt8(BCLMKey.status)

            print("bfD0 (High): \(highVal)")
            print("bfE0 (Low): \(lowVal)")
            print("bfF0 (Status): \(statusVal)")
        }
    }

    struct Write: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Writes high and low limit values, and optional status value"
        )

        @Argument(help: "High limit (\"bfD0\", UInt32)")
        var high: UInt32

        @Argument(help: "Low limit (\"bfE0\", UInt32)")
        var low: UInt32

        @Argument(help: "Status (\"bfF0\", UInt8)")
        var status: UInt8 = 2

        func run() throws {
            try SMCKit.open()
            defer { SMCKit.close() }

            try SMCKit.writeUInt32(BCLMKey.high, value: high)
            try SMCKit.writeUInt32(BCLMKey.low, value: low)

            if try SMCKit.readUInt8(BCLMKey.status) != status {
                try SMCKit.writeUInt8(BCLMKey.status, value: status)
            }
        }
    }
}

BCLM.main()
