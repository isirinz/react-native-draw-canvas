require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = 'RNDrawCanvas'
  s.version      = package['version']
  s.summary      = package['description']
  s.homepage     = 'https://github.com/isirinz/react-native-draw-canvas'
  s.license      = package['license']
  s.authors      = package['author']
  s.source       = { :git => package['repository']['url'] }
  s.platform     = :ios, '9.0'
  s.source_files = 'ios/**/*.{h,m}'
  s.dependency   'React'
end
