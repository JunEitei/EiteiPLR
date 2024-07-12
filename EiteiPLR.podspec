
Pod::Spec.new do |spec|

  spec.name         = "EiteiPLR"
  spec.version      = "3.6.0"
  spec.summary      = "A music player developed by Eitei."

  spec.description  = <<-DESC
                      A music player developed by Eitei.
                   DESC
  spec.homepage     = "https://github.com/JunEitei/EiteiPLR"
  spec.author             = { "Damao" => "jun.huang@eitei.co.jp" }

  spec.platform     = :ios, '13.0'
  spec.swift_version = "5.7"
  
  spec.source       = { :git => "https://github.com/JunEitei/EiteiPLR.git", :tag => "#{spec.version}" }
  
  spec.source_files = "Sources/EiteiPLR/**/*.swift"
  spec.resource =  ["Sources/EiteiPLR/Resource/*.png"]
  
  spec.dependency 'SnapKit', '~> 5.7.0'
  spec.dependency 'Alamofire', '~> 5.9.1'
  spec.dependency 'ReachabilitySwift', '~> 5.2.1'


end
