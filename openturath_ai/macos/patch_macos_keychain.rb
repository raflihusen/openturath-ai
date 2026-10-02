#!/usr/bin/env ruby
# frozen_string_literal: true

# patch_macos_keychain.rb
# Provides fallback to AuthUserDefaults for FirebaseAuth on macOS when Keychain access
# requires entitlements that are unavailable in local/ad-hoc signed builds.

pods_dir = File.expand_path(File.join(__dir__, 'Pods'))

# 1. Patch AuthKeychainServices.swift
aks_path = File.join(pods_dir, 'FirebaseAuth/FirebaseAuth/Sources/Swift/Storage/AuthKeychainServices.swift')
if File.exist?(aks_path)
  content = File.read(aks_path)
  unless content.include?('AuthUserDefaults(service: service)')
    # In setItemLegacy, before throwing keychainError, fallback to AuthUserDefaults on macOS
    content.gsub!(
      /if status == noErr \{\s*return\s*\}\s*let function = hasItem \? "SecItemUpdate" : "SecItemAdd"\s*throw AuthErrorUtils\.keychainError\(function: function, status: status\)/m,
      "if status == noErr {\n      return\n    }\n    #if os(macOS)\n    let key = (query[kSecAttrAccount as String] as? String) ?? \"\"\n    if !key.isEmpty {\n      let defaults = AuthUserDefaults(service: service)\n      defaults.setData(item, forKey: key)\n      return\n    }\n    #endif\n    let function = hasItem ? \"SecItemUpdate\" : \"SecItemAdd\"\n    throw AuthErrorUtils.keychainError(function: function, status: status)"
    )

    # In getItemLegacy, if status is not noErr/itemNotFound, fallback to AuthUserDefaults on macOS
    content.gsub!(
      /if status == errSecItemNotFound \{\s*return nil\s*\} else \{\s*throw AuthErrorUtils\.keychainError\(function: "SecItemCopyMatching", status: status\)\s*\}/m,
      "if status == errSecItemNotFound {\n      return nil\n    } else {\n      #if os(macOS)\n      let key = (query[kSecAttrAccount as String] as? String) ?? \"\"\n      if !key.isEmpty {\n        let defaults = AuthUserDefaults(service: service)\n        if let data = defaults.data(forKey: key) {\n          return data\n        }\n      }\n      #endif\n      throw AuthErrorUtils.keychainError(function: \"SecItemCopyMatching\", status: status)\n    }"
    )

    # In getItem, fallback to AuthUserDefaults on macOS
    content.gsub!(
      /if status == errSecItemNotFound \{\s*return nil\s*\} else \{\s*throw AuthErrorUtils\.keychainError\(function: "SecItemCopyMatching", status: status\)\s*\}/m,
      "if status == errSecItemNotFound {\n      return nil\n    } else {\n      #if os(macOS)\n      let key = (query[kSecAttrAccount as String] as? String) ?? \"\"\n      if !key.isEmpty {\n        let defaults = AuthUserDefaults(service: service)\n        if let data = defaults.data(forKey: key) {\n          return data\n        }\n      }\n      #endif\n      throw AuthErrorUtils.keychainError(function: \"SecItemCopyMatching\", status: status)\n    }"
    )

    # In removeItem, fallback to AuthUserDefaults on macOS
    content.gsub!(
      /if status == noErr \|\| status == errSecItemNotFound \{\s*return\s*\}\s*throw AuthErrorUtils\.keychainError\(function: "SecItemDelete", status: status\)/m,
      "if status == noErr || status == errSecItemNotFound {\n      return\n    }\n    #if os(macOS)\n    let key = (query[kSecAttrAccount as String] as? String) ?? \"\"\n    if !key.isEmpty {\n      let defaults = AuthUserDefaults(service: service)\n      defaults.removeData(forKey: key)\n      return\n    }\n    #endif\n    throw AuthErrorUtils.keychainError(function: \"SecItemDelete\", status: status)"
    )

    File.chmod(0644, aks_path)
    File.write(aks_path, content)
    puts "Successfully patched AuthKeychainServices.swift with macOS AuthUserDefaults fallback."
  end
end

# 2. Patch AuthStoredUserManager.swift
asum_path = File.join(pods_dir, 'FirebaseAuth/FirebaseAuth/Sources/Swift/SystemService/AuthStoredUserManager.swift')
if File.exist?(asum_path)
  content = File.read(asum_path)
  unless content.include?('userDefaults.setData(archiver.encodedData, forKey: "\(Self.storedUserCoderKey)_\(projectIdentifier)")')
    # Patch setStoredUser
    content.gsub!(
      /do \{\s*try keychainServices\.setItem\(archiver\.encodedData, withQuery: query\)\s*\} catch let error as NSError \{/m,
      "do {\n      #if os(macOS)\n      userDefaults.setData(archiver.encodedData, forKey: \"\\(Self.storedUserCoderKey)_\\(projectIdentifier)\")\n      #endif\n      try keychainServices.setItem(archiver.encodedData, withQuery: query)\n    } catch let error as NSError {"
    )

    # Patch getStoredUser
    content.gsub!(
      /guard let data = try keychainServices\.getItem\(query: query\) else \{\s*return nil\s*\}/m,
      "#if os(macOS)\n    if let data = userDefaults.data(forKey: \"\\(Self.storedUserCoderKey)_\\(projectIdentifier)\") {\n      do {\n        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)\n        return unarchiver.decodeObject(of: User.self, forKey: Self.storedUserCoderKey)\n      } catch {\n        return nil\n      }\n    }\n    #endif\n    guard let data = try? keychainServices.getItem(query: query) else {\n      return nil\n    }"
    )

    # Patch removeStoredUser
    content.gsub!(
      /try keychainServices\.removeItem\(query: query\)/m,
      "#if os(macOS)\n    userDefaults.removeData(forKey: \"\\(Self.storedUserCoderKey)_\\(projectIdentifier)\")\n    #endif\n    try? keychainServices.removeItem(query: query)"
    )

    File.chmod(0644, asum_path)
    File.write(asum_path, content)
    puts "Successfully patched AuthStoredUserManager.swift with macOS AuthUserDefaults fallback."
  end
end
