#
# Be sure to run `pod lib lint JRImagePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JRImagePicker'
  s.version          = '0.1.0'
  s.summary          = 'JRImagePicker is a photo picker and taker set'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  JRImagePicker can use as a picker or a camera
                       DESC
                       
  s.homepage         = 'https://github.com/CheATSlark/JRImagePicker.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jerry' => 'jruijqx@163.com' }
  s.source           = { :git => 'https://github.com/CheATSlark/JRImagePicker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'JRImagePicker/Classes/**/*'
  
   s.resource_bundles = {
     'JRImagePicker' => ['JRImagePicker/Assets/Assets.xcassets']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
