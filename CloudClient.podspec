Pod::Spec.new do |spec|
  spec.name = "CloudClient"
  spec.version = "1.0.0"
  spec.summary = "API Client for cloud.mail.ru"
  spec.homepage = "https://github.com/BigDanceMouse/CloudClient"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Vladimir Elizarov" => 'digitaljamdevelopment@gmail.com' }

  spec.platform = :osx, "10.11"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/BigDanceMouse/CloudClient.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "CloudClient/**/*.{h,swift}"

  spec.dependency "Alamofire", "~> 4.4.0"
  spec.dependency "SantasLittleHelpers", :path => '/Users/VladimirElizarov/dev/Pods/SantasLittleHelpers'
end