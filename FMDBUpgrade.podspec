Pod::Spec.new do |s|
  s.name         = "FMDBUpgrade"
  s.version      = "1.0.2"
  s.author       = { "yangyongzheng" => "youngyongzheng@qq.com" }
  s.license      = "MIT"  
  s.homepage     = "https://github.com/yangyongzheng/FMDBUpgrade"
  s.source       = { :git => "https://github.com/yangyongzheng/FMDBUpgrade.git", :tag => "#{s.version}" }
  s.summary      = "Upgrade database extension class based on FMDB."
  
  s.requires_arc = true
  s.platform     = :ios, "8.0"
  s.source_files  = "UpgradeManager/FMDBUpgradeHeader.h"
  s.public_header_files = "UpgradeManager/FMDBUpgradeHeader.h"

  s.subspec "UpgradeManager" do |ss|
    ss.source_files = "UpgradeManager/*.{h,m}"
    ss.public_header_files = "UpgradeManager/*+Upgrade.h"
  end

  s.dependency "FMDB"

end
