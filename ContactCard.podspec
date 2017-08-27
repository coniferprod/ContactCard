Pod::Spec.new do |s|
  s.name             = 'ContactCard'
  s.version          = '0.3.3'
  s.summary          = 'Contacts framework helper for jCard processing.'

  s.description      = <<-DESC
Helper library for applications depending on the iOS Contacts framework.
Converts from CNContact to jCard, or from jCard to CNMutableContact.
                       DESC

  s.homepage         = 'https://github.com/coniferprod/ContactCard'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jere Käpyaho' => 'jere@coniferproductions.com' }
  s.source           = { :git => 'https://github.com/coniferprod/ContactCard.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/coniferprod'

  s.ios.deployment_target = '9.0'
  s.ios.frameworks = 'Foundation', 'Contacts'

  s.source_files = 'ContactCard/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ContactCard' => ['ContactCard/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  s.dependency 'SwiftyJSON'
end
