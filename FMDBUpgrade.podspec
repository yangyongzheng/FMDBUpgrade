Pod::Spec.new do |s|
	s.name = 'FMDBUpgrade'
	s.version = '1.0.3'
	s.summary = 'Upgrade database extension class based on FMDB.'
	s.homepage = 'https://github.com/yangyongzheng/FMDBUpgrade'
	s.license = { :type => 'MIT', :file => 'LICENSE' }
	s.authors = {
		'yangyongzheng' => 'youngyongzheng@qq.com'
	}
	s.source = {
		:git => 'https://github.com/yangyongzheng/FMDBUpgrade.git',
		:tag => s.version.to_s
	}

	s.platform = :ios, '9.0'
	s.ios.deployment_target = '9.0'
	s.requires_arc = true

	s.source_files = 'Source/FMDBUpgradeHeader.h'
	s.public_header_files = 'Source/FMDBUpgradeHeader.h'

	subspec 'Upgrade' do |ss|
		ss.source_files = 'Source/*+Upgrade.?'
		ss.public_header_files = 'Source/*+Upgrade.h'
	end

	s.dependency 'FMDB'
end
