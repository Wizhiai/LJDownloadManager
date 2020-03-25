Pod::Spec.new do |s|

  s.name         = "LJDownloadManager"
  s.version      = "0.0.2"
  s.summary      = "LJDownloadManager."
  s.description  = <<-DESC
  断点下载
                   DESC

  s.homepage     = "https://github.com/Wizhiai/LJDownloadManager"
  s.license      = "MIT"
  s.author             = { "lijiehu" => "630806244@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Wizhiai/LJDownloadManager.git", :tag => "#{s.version}" }
  s.source_files  = "LJDownloadManager", "LJDownloadManager/**/*.{h,m}"

  s.framework = "Foundation"
 # s.dependency "AFNetworking", "~> 3.2.1"

end
