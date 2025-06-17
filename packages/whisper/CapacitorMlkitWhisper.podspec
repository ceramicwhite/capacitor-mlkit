require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name = 'CapacitorMlkitWhisper'
  s.version = package['version']
  s.summary = package['description']
  s.license = package['license']
  s.homepage = package['repository']['url']
  s.author = package['author']
  s.source = { :git => package['repository']['url'], :tag => s.version.to_s }
  s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
  s.ios.deployment_target  = '13.0'
  s.dependency 'Capacitor'
  s.swift_version = '5.1'

  # Add whisper.cpp dependency via Swift Package Manager
  s.dependency 'whisper-spm', '~> 1.5.4'
  
  # Enable Core ML support
  s.frameworks = 'CoreML', 'Accelerate'
  s.weak_frameworks = 'CoreML'
  
  # Compiler flags for whisper.cpp Core ML support
  s.pod_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS' => 'WHISPER_USE_COREML=1',
    'OTHER_SWIFT_FLAGS' => '-DWHISPER_USE_COREML'
  }
end