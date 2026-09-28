#!/usr/bin/env ruby
# frozen_string_literal: true

# patch_macos_keychain.rb
# Automatically eliminates macOS Keychain errSecMissingEntitlement (-34018)
# by ensuring Firebase Auth and GoogleUtilities use the standard login keychain
# and AuthUserDefaults fallback on macOS instead of requiring paid Apple Developer Team entitlements.

pods_dir = File.expand_path(File.join(__dir__, 'Pods'))

# 1. Patch AuthStoredUserManager.swift
asum_path = File.join(pods_dir, 'FirebaseAuth/FirebaseAuth/Sources/Swift/SystemService/AuthStoredUserManager.swift')
if File.exist?(asum_path)
  content = File.read(asum_path)
  unless content.include?('#if !os(macOS)')
    content.gsub!(/^\s*query\[kSecUseDataProtectionKeychain as String\] = true/, "    #if !os(macOS)\n    query[kSecUseDataProtectionKeychain as String] = true\n    #endif")
    File.chmod(0644, asum_path)
    File.write(asum_path, content)
  end
end

# 2. Patch GULKeychainStorage.m
gks_path = File.join(pods_dir, 'GoogleUtilities/GoogleUtilities/Environment/SecureStorage/GULKeychainStorage.m')
if File.exist?(gks_path)
  content = File.read(gks_path)
  unless content.include?('#if !TARGET_OS_OSX')
    content.gsub!(/if \(@available\(iOS 13\.0, macOS 10\.15[^\)]*\)\) \{\s*\n\s*\/\/ Ensures that the keychain query behaves the same across all platforms\.\s*\n\s*\/\/ See go\/firebase-macos-keychain-popups for details\.\s*\n\s*query\[\(__bridge id\)kSecUseDataProtectionKeychain\] = \(__bridge id\)kCFBooleanTrue;\s*\n\s*\}/m,
                  "#if !TARGET_OS_OSX\n  if (@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *)) {\n    query[(__bridge id)kSecUseDataProtectionKeychain] = (__bridge id)kCFBooleanTrue;\n  }\n#endif")
    File.chmod(0644, gks_path)
    File.write(gks_path, content)
  end
end

# 3. Patch GULKeychainUtils.m
gku_path = File.join(pods_dir, 'GoogleUtilities/GoogleUtilities/Environment/SecureStorage/GULKeychainUtils.m')
if File.exist?(gku_path)
  content = File.read(gku_path)
  unless content.include?('#if !TARGET_OS_OSX')
    content.gsub!(/(\+ \(NSDictionary \*\)multiplatformQueryWithQuery:\(NSDictionary \*\)query \{\s*\n\s*NSMutableDictionary \*multiplatformQuery = \[query mutableCopy\];\s*\n)\s*if \(@available\(iOS 13\.0, macOS 10\.15[^\)]*\)\) \{\s*\n\s*multiplatformQuery\[\(__bridge id\)kSecUseDataProtectionKeychain\] = \(__bridge id\)kCFBooleanTrue;\s*\n\s*\}/m,
                  "\\1#if !TARGET_OS_OSX\n  if (@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *)) {\n    multiplatformQuery[(__bridge id)kSecUseDataProtectionKeychain] = (__bridge id)kCFBooleanTrue;\n  }\n#endif")
    File.chmod(0644, gku_path)
    File.write(gku_path, content)
  end
end
