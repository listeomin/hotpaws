import Foundation

class ConfigManager {
    static let shared = ConfigManager()
    
    let configDirectory: URL
    let bundleResourcesURL: URL?
    
    private init() {
        // ~/.hotpaws/ directory
        let homeURL = FileManager.default.homeDirectoryForCurrentUser
        self.configDirectory = homeURL.appendingPathComponent(".hotpaws")
        
        // Bundle resources directory
        self.bundleResourcesURL = Bundle.main.resourceURL
    }
    
    // MARK: - Setup
    
    func setupConfigDirectory() {
        do {
            // Create ~/.hotpaws/ if it doesn't exist
            if !FileManager.default.fileExists(atPath: configDirectory.path) {
                try FileManager.default.createDirectory(
                    at: configDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                print("Created config directory: \(configDirectory.path)")
            }
            
            // Copy default files from bundle if they don't exist
            copyDefaultFileIfNeeded("commands.json")
            copyDefaultFileIfNeeded("main.css")
            
        } catch {
            print("Error setting up config directory: \(error)")
        }
    }
    
    private func copyDefaultFileIfNeeded(_ filename: String) {
        let userFile = configDirectory.appendingPathComponent(filename)
        
        // Don't overwrite existing files
        guard !FileManager.default.fileExists(atPath: userFile.path) else {
            print("User file already exists: \(filename)")
            return
        }
        
        // Find source file in bundle
        guard let bundleURL = bundleResourcesURL?.appendingPathComponent(filename),
              FileManager.default.fileExists(atPath: bundleURL.path) else {
            print("Default file not found in bundle: \(filename)")
            return
        }
        
        do {
            try FileManager.default.copyItem(at: bundleURL, to: userFile)
            print("Copied default file: \(filename)")
        } catch {
            print("Error copying default file \(filename): \(error)")
        }
    }
    
    // MARK: - Load Resources
    
    func loadCommands() -> Data? {
        let userFile = configDirectory.appendingPathComponent("commands.json")
        
        // Try user file first
        if FileManager.default.fileExists(atPath: userFile.path) {
            do {
                let data = try Data(contentsOf: userFile)
                print("Loaded commands from user config")
                return data
            } catch {
                print("Error reading user commands.json: \(error)")
            }
        }
        
        // Fallback to bundle
        guard let bundleURL = bundleResourcesURL?.appendingPathComponent("commands.json") else {
            print("Bundle resources URL not available")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: bundleURL)
            print("Loaded commands from bundle (fallback)")
            return data
        } catch {
            print("Error reading bundle commands.json: \(error)")
            return nil
        }
    }
    
    func loadStyles() -> String? {
        let userFile = configDirectory.appendingPathComponent("main.css")
        
        // Try user file first
        if FileManager.default.fileExists(atPath: userFile.path) {
            do {
                let styles = try String(contentsOf: userFile, encoding: .utf8)
                print("Loaded styles from user config")
                return styles
            } catch {
                print("Error reading user style.css: \(error)")
            }
        }
        
        // Fallback to bundle
        guard let bundleURL = bundleResourcesURL?.appendingPathComponent("main.css") else {
            print("Bundle resources URL not available")
            return nil
        }
        
        do {
            let styles = try String(contentsOf: bundleURL, encoding: .utf8)
            print("Loaded styles from bundle (fallback)")
            return styles
        } catch {
            print("Error reading bundle style.css: \(error)")
            return nil
        }
    }
    
    // MARK: - Resource Paths
    
    func getResourcePath(_ filename: String) -> URL? {
        let userFile = configDirectory.appendingPathComponent(filename)
        
        // Return user file if it exists
        if FileManager.default.fileExists(atPath: userFile.path) {
            return userFile
        }
        
        // Return bundle file if it exists
        if let bundleFile = bundleResourcesURL?.appendingPathComponent(filename),
           FileManager.default.fileExists(atPath: bundleFile.path) {
            return bundleFile
        }
        
        print("Resource file not found: \(filename)")
        return nil
    }
    
    // MARK: - Utility
    
    func configDirectoryExists() -> Bool {
        return FileManager.default.fileExists(atPath: configDirectory.path)
    }
    
    func userFileExists(_ filename: String) -> Bool {
        let userFile = configDirectory.appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: userFile.path)
    }
}
