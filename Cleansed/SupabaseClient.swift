//
//  SupabaseClient.swift
//  Cleansed
//

import Foundation
import Supabase

enum AppConfig {
    static let supabaseURL: URL = {
        guard let value = value(for: "SUPABASE_URL"), let url = URL(string: value) else {
            fatalError("Missing or invalid SUPABASE_URL. Set it in environment variables or .env.")
        }
        return url
    }()

    static let supabaseKey: String = {
        guard let value = value(for: "SUPABASE_KEY"), !value.isEmpty else {
            fatalError("Missing SUPABASE_KEY. Set it in environment variables or .env.")
        }
        return value
    }()

    private static func value(for key: String) -> String? {
        if let value = ProcessInfo.processInfo.environment[key], !value.isEmpty {
            return value
        }

        guard let fileValue = DotEnvLoader.shared.values[key], !fileValue.isEmpty else {
            return nil
        }
        return fileValue
    }
}

private final class DotEnvLoader {
    static let shared = DotEnvLoader()
    let values: [String: String]

    private init() {
        self.values = Self.load()
    }

    private static func load() -> [String: String] {
        guard let envFileURL = envFileLocation(),
              let content = try? String(contentsOf: envFileURL, encoding: .utf8) else {
            return [:]
        }

        var result: [String: String] = [:]
        content.split(whereSeparator: \.isNewline).forEach { rawLine in
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty, !line.hasPrefix("#") else { return }
            guard let separator = line.firstIndex(of: "=") else { return }

            let key = String(line[..<separator]).trimmingCharacters(in: .whitespaces)
            var value = String(line[line.index(after: separator)...]).trimmingCharacters(in: .whitespaces)
            if value.hasPrefix("\""), value.hasSuffix("\""), value.count >= 2 {
                value = String(value.dropFirst().dropLast())
            }
            result[key] = value
        }
        return result
    }

    private static func envFileLocation() -> URL? {
        let currentPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let candidatePaths = [
            currentPath.appendingPathComponent(".env"),
            currentPath.appendingPathComponent("../.env"),
            Bundle.main.bundleURL.appendingPathComponent(".env"),
            Bundle.main.bundleURL.appendingPathComponent("../.env")
        ]

        for path in candidatePaths {
            if FileManager.default.fileExists(atPath: path.path) {
                return path
            }
        }
        return nil
    }
}

let supabase = SupabaseClient(
    supabaseURL: AppConfig.supabaseURL,
    supabaseKey: AppConfig.supabaseKey
)
