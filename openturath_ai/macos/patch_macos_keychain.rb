#!/usr/bin/env ruby
# frozen_string_literal: true

# patch_macos_keychain.rb
# Completely eliminates macOS Keychain popups and errSecMissingEntitlement (-34018)
# by routing Firebase Auth and GoogleUtilities persistence to AuthUserDefaults / NSUserDefaults
# on macOS, requiring zero Keychain prompts or paid Apple Developer Team entitlements.

pods_dir = File.expand_path(File.join(__dir__, 'Pods'))

# 1. Patch AuthStoredUserManager.swift
asum_path = File.join(pods_dir, 'FirebaseAuth/FirebaseAuth/Sources/Swift/SystemService/AuthStoredUserManager.swift')
if File.exist?(asum_path)
  content = File.read(asum_path)
  unless content.include?('userDefaults.data(forKey: "\(Self.storedUserCoderKey)_')
    # Patch getStoredUser
    content.gsub!(
      /func getStoredUser\(accessGroup: String,\s*shareAuthStateAcrossDevices: Bool,\s*projectIdentifier: String\) throws -> User\? \{/m,
      "func getStoredUser(accessGroup: String,\n                     shareAuthStateAcrossDevices: Bool,\n                     projectIdentifier: String) throws -> User? {\n    #if os(macOS)\n    if let data = userDefaults.data(forKey: \"\\(Self.storedUserCoderKey)_\\(projectIdentifier)\") {\n      do {\n        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)\n        return unarchiver.decodeObject(of: User.self, forKey: Self.storedUserCoderKey)\n      } catch {\n        return nil\n      }\n    }\n    return nil\n    #else"
    )
    # Add #endif to end of getStoredUser
    content.gsub!(
      /return unarchiver\.decodeObject\(of: User\.self, forKey: Self\.storedUserCoderKey\)\s*\n\s*\}/m,
      "return unarchiver.decodeObject(of: User.self, forKey: Self.storedUserCoderKey)\n    #endif\n  }"
    )

    # Patch setStoredUser
    content.gsub!(
      /func setStoredUser\(user: User,\s*accessGroup: String,\s*shareAuthStateAcrossDevices: Bool,\s*projectIdentifier: String\) throws \{/m,
      "func setStoredUser(user: User,\n                     accessGroup: String,\n                     shareAuthStateAcrossDevices: Bool,\n                     projectIdentifier: String) throws {\n    #if os(macOS)\n    let archiver = NSKeyedArchiver(requiringSecureCoding: false)\n    archiver.encode(user, forKey: Self.storedUserCoderKey)\n    archiver.finishEncoding()\n    userDefaults.setData(archiver.encodedData, forKey: \"\\(Self.storedUserCoderKey)_\\(projectIdentifier)\")\n    return\n    #else"
    )
    # Add #endif to end of setStoredUser
    content.gsub!(
      /try keychainServices\.setItem\(archiver\.encodedData, withQuery: query\)\s*\n\s*\}\s*\n\s*\}/m,
      "try keychainServices.setItem(archiver.encodedData, withQuery: query)\n    }\n    #endif\n  }"
    )

    # Patch removeStoredUser
    content.gsub!(
      /func removeStoredUser\(accessGroup: String,\s*shareAuthStateAcrossDevices: Bool,\s*projectIdentifier: String\) throws \{/m,
      "func removeStoredUser(accessGroup: String,\n                         shareAuthStateAcrossDevices: Bool,\n                         projectIdentifier: String) throws {\n    #if os(macOS)\n    userDefaults.removeData(forKey: \"\\(Self.storedUserCoderKey)_\\(projectIdentifier)\")\n    return\n    #else"
    )
    # Add #endif to end of removeStoredUser
    content.gsub!(
      /try keychainServices\.removeItem\(query: query\)\s*\n\s*\}/m,
      "try keychainServices.removeItem(query: query)\n    #endif\n  }"
    )

    File.chmod(0644, asum_path)
    File.write(asum_path, content)
    puts "Successfully patched AuthStoredUserManager.swift"
  end
end

# 2. Patch AuthKeychainServices.swift
aks_path = File.join(pods_dir, 'FirebaseAuth/FirebaseAuth/Sources/Swift/Storage/AuthKeychainServices.swift')
if File.exist?(aks_path)
  content = File.read(aks_path)
  unless content.include?('let key = (query[kSecAttrAccount as String] as? String) ?? ""')
    content.gsub!(
      /func getItem\(query: \[String: Any\]\) throws -> Data\? \{/m,
      "func getItem(query: [String: Any]) throws -> Data? {\n    #if os(macOS)\n    let key = (query[kSecAttrAccount as String] as? String) ?? \"\"\n    return fallbackDefaults.data(forKey: key)\n    #else"
    )
    content.gsub!(
      /func setItem\(_ item: Data, withQuery query: \[String: Any\]\) throws \{/m,
      "func setItem(_ item: Data, withQuery query: [String: Any]) throws {\n    #if os(macOS)\n    let key = (query[kSecAttrAccount as String] as? String) ?? \"\"\n    if !key.isEmpty {\n      fallbackDefaults.setData(item, forKey: key)\n    }\n    return\n    #else"
    )
    content.gsub!(
      /func removeItem\(query: \[String: Any\]\) throws \{/m,
      "func removeItem(query: [String: Any]) throws {\n    #if os(macOS)\n    let key = (query[kSecAttrAccount as String] as? String) ?? \"\"\n    if !key.isEmpty {\n      fallbackDefaults.removeData(forKey: key)\n    }\n    return\n    #else"
    )
    content.gsub!(
      /func getItemLegacy\(query: \[String: Any\]\) throws -> Data\? \{/m,
      "func getItemLegacy(query: [String: Any]) throws -> Data? {\n    #if os(macOS)\n    let key = (query[kSecAttrAccount as String] as? String) ?? \"\"\n    return fallbackDefaults.data(forKey: key)\n    #else"
    )
    content.gsub!(
      /func setItemLegacy\(_ item: Data, withQuery query: \[String: Any\]\) throws \{/m,
      "func setItemLegacy(_ item: Data, withQuery query: [String: Any]) throws {\n    #if os(macOS)\n    let key = (query[kSecAttrAccount as String] as? String) ?? \"\"\n    if !key.isEmpty {\n      fallbackDefaults.setData(item, forKey: key)\n    }\n    return\n    #else"
    )

    File.chmod(0644, aks_path)
    File.write(aks_path, content)
    puts "Successfully patched AuthKeychainServices.swift"
  end
end

# 3. Patch GULKeychainStorage.m
gks_path = File.join(pods_dir, 'GoogleUtilities/GoogleUtilities/Environment/SecureStorage/GULKeychainStorage.m')
if File.exist?(gks_path)
  content = File.read(gks_path)
  unless content.include?('TARGET_OS_OSX')
    content.gsub!(/if \(@available\(iOS 13\.0, macOS 10\.15[^\)]*\)\) \{\s*\n\s*\/\/ Ensures that the keychain query behaves the same across all platforms\.\s*\n\s*\/\/ See go\/firebase-macos-keychain-popups for details\.\s*\n\s*query\[\(__bridge id\)kSecUseDataProtectionKeychain\] = \(__bridge id\)kCFBooleanTrue;\s*\n\s*\}/m,
                  "#if !TARGET_OS_OSX\n  if (@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *)) {\n    query[(__bridge id)kSecUseDataProtectionKeychain] = (__bridge id)kCFBooleanTrue;\n  }\n#endif")
    File.chmod(0644, gks_path)
    File.write(gks_path, content)
    puts "Successfully patched GULKeychainStorage.m"
  end
end

# 4. Patch GULKeychainUtils.m
gku_path = File.join(pods_dir, 'GoogleUtilities/GoogleUtilities/Environment/SecureStorage/GULKeychainUtils.m')
if File.exist?(gku_path)
  content = File.read(gku_path)
  unless content.include?('TARGET_OS_OSX')
    content.gsub!(/(\+ \(NSDictionary \*\)multiplatformQueryWithQuery:\(NSDictionary \*\)query \{\s*\n\s*NSMutableDictionary \*multiplatformQuery = \[query mutableCopy\];\s*\n)\s*if \(@available\(iOS 13\.0, macOS 10\.15[^\)]*\)\) \{\s*\n\s*multiplatformQuery\[\(__bridge id\)kSecUseDataProtectionKeychain\] = \(__bridge id\)kCFBooleanTrue;\s*\n\s*\}/m,
                  "\\1#if !TARGET_OS_OSX\n  if (@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *)) {\n    multiplatformQuery[(__bridge id)kSecUseDataProtectionKeychain] = (__bridge id)kCFBooleanTrue;\n  }\n#endif")
    File.chmod(0644, gku_path)
    File.write(gku_path, content)
    puts "Successfully patched GULKeychainUtils.m"
  end
end
