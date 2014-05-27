require "rubygems"

task :test do
  sh "xctool -workspace Bars.xcworkspace -scheme Bars -sdk iphonesimulator test"
end

task :default => :test
