Pod::Spec.new do |s|
  s.name         = 'JRMutableArray'
  s.version      = '0.0.1'
  s.summary      = 'Thread-safe mutable array with support for quick-look'
  s.homepage     = 'https://github.com/JonathanRitchey03/JRMutableArray'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Jonathan Ritchey' => 'jonathan_ritchey@yahoo.com' }
  s.source       = { :git => 'https://github.com/JonathanRitchey03/JRMutableArray.git', :tag => s.version.to_s }

  s.source_files = 'JRMutableArray/Source/*.swift'
  s.requires_arc = true
end
