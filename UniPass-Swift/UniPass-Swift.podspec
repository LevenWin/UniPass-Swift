
Pod::Spec.new do |s|
  s.name             = 'UniPass-Swift'
  s.version          = '0.0.1'
  s.summary          = 'UniPass swift lib'
  s.description      = <<-DESC
 UniPass swift 
                       DESC
  s.homepage         = "https://github.com/UniPassID"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'leven' => 'isrealleven@gmail.com' }
  s.platform         = :ios, "13.0"
  s.source           = { :git => 'git@github.com:UniPassID/unipass-flutter-web-sdk.git', :tag => "#{s.version}" }
  s.source_files     = 'Sources/**/*.{h,m,swift}'
  s.dependency 'WalletConnectWeb3'
end
