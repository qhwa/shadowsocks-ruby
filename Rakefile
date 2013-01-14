require 'rake'

task :default => 'compile'

task :compile do
  `rm ./ext/*.o ./ext/*.so`
  `cd ./ext && gcc -fPIC -c ext.c && gcc -shared -o ext.so ext.o`
end
