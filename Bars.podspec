Pod::Spec.new do |s|
  s.name             =  "Bars"
  s.version          =  "1.0.1"
  s.summary          =  "iOS view to display bar graphs"
  s.homepage         =  "https://github.com/yourkarma/bars"
  s.license          =  { :type => "MIT", :file => "LICENSE" }
  s.authors          =  { "Klaas Pieter Annema" => "klaaspieter@annema.me" }
  s.social_media_url =  "https://twitter.com/klaaspieter"
  s.platform         =  :ios, "7.0"
  s.source           =  { :git => "https://github.com/yourkarma/bars.git", :tag => s.version.to_s }
  s.source_files     =  "Classes", "Classes/**/*.{h,m}"
  s.requires_arc     =  true
end
