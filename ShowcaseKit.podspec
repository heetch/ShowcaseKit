Pod::Spec.new do |s|
  s.name         = "ShowcaseKit"
  s.version      = "1.1.2"
  s.summary      = "Embrace Showcase Driven Development with ease :)"
  s.description  = <<-DESC
   ShowcaseKit is a way to embed easily some view controllers in your application in order to showcase what you've done.

   You can showcase simple views with dummy data as well as you can showcase complete flows. It's all up to you.

   The general idea is to be able to showcase something your working on before you finish the whole feature, that way you can still merge it in your mainline branch - that's what we call real Continuous Integration.
  DESC
  s.homepage     = "https://github.com/heetch/ShowcaseKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Jérôme Alves" => "j.alves@me.com" }
  s.social_media_url   = ""
  s.ios.deployment_target = "11.0"
  s.source       = { :git => "https://github.com/heetch/ShowcaseKit.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.swift_version = '5.0'
  s.frameworks  = "Foundation"
end
