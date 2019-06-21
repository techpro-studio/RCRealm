Pod::Spec.new do |s|
  s.name             = 'RCRealm'
  s.version          = '0.0.1'
  s.summary          = 'RCKit Realm'
  s.description      = "Helpers for adopt Realm Reactive Clean approach"

  s.homepage         = 'https://github.com/wolvesstudio/RCRealm'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Oleksii Moiseenko' => 'oleksiimoiseenko@gmail.com' }
  s.source           = { :git => 'https://github.com/wolvesstudio/RCRealm.git', :tag => s.version }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Sources/**/*.swift'
  s.swift_version = '5.0'
  
  s.frameworks = 'UIKit', 'UserNotifications'
  s.dependency 'RCKit'
  s.dependency 'RealmSwift'
end
