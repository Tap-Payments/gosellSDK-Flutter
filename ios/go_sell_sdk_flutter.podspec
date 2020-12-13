#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint go_sell_sdk_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'go_sell_sdk_flutter'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://tap.company'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'h.sheshtawy@tap.company' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'goSellSDK', '2.2.41'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
