#
# Be sure to run `pod lib lint Terra.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Terra'
  s.version          = '1.0.0'
  s.summary          = '网络层框架'
  s.description      = '可灵活定制，高扩展性，基于Moya的网络组件'

  s.homepage         = 'http://47.244.69.238/iOS/core-components/Terra'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'DATree' => 'aobaoaini@gmail.com' }
  s.source           = { :git => 'http://47.244.69.238/iOS/core-components/Terra.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.source_files = 'Terra/Classes/**/*'
  s.dependency 'Moya', '~> 13.0'
  s.dependency 'Moya/RxSwift', '~> 13.0'
  s.dependency 'Moya/ReactiveSwift', '~> 13.0'
  s.dependency 'SwiftyJSON'
  s.dependency 'ObjectMapper'
end
