#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint orra_desktop_shell.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'orra_desktop_shell'
  s.version          = '0.1.0'
  s.summary          = 'orra_desktop_shell macOS: traffic light positioning.'
  s.description      = <<-DESC
Positions the macOS traffic lights on the custom titlebar centerline.
                       DESC
  s.homepage         = 'https://github.com/orra-bot/orra_ui'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'orra-bot' => 'https://github.com/orra-bot' }

  s.source           = { :path => '.' }
  s.source_files = 'orra_desktop_shell/Sources/orra_desktop_shell/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'orra_desktop_shell_privacy' => ['orra_desktop_shell/Sources/orra_desktop_shell/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
