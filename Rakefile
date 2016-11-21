desc 'Build'
task :build do
  system('mkdir build')
  system('clang -m64 -dynamiclib  mach_override/*.c mach_override/libudis86/*.c iohid_capture.mm -current_version 1.0 -compatibility_version 1.0 -lobjc -framework Foundation -framework IOKit -framework CoreFoundation -framework CoreServices -o build/iohid_capture.dylib')
end


desc 'Clean up'
task :clean do
  system('rm -rf build')
end

task :default => [:build]