platform :ios, '14.0'
inhibit_all_warnings!

use_frameworks!

target 'WunderLINQ' do
  pod 'InAppSettingsKit', '~> 3.3.6'
  pod 'ChromaColorPicker', '~> 2.0.2'
  pod 'CoreGPX', '~> 0.9.0'
  pod 'UIMultiPicker', '~> 0.6.2'
  pod 'Popovers', '~> 1.3.0'
end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
            end
        end
    end
end
