# install / uninstall wrapper
require 'fileutils'
require 'rubygems'
require 'executable-hooks/specification'

module ExecutableHooks
  module Wrapper
    def self.wrapper_name
      'ruby_executable_hooks'
    end
    def self.bindir
      Gem.respond_to?(:bindir,true) ? Gem.send(:bindir) : File.join(Gem.dir, 'bin')
    end
    def self.destination
      File.expand_path( wrapper_name, bindir )
    end
    def self.ensure_custom_shebang
      Gem.configuration[:custom_shebang] ||= "$env #{self.wrapper_name}"

      if Gem.configuration[:custom_shebang] != "$env #{self.wrapper_name}"
        warn("
Warning: found rubygems custom_shebang: '#{Gem.configuration[:custom_shebang]}',
this can potentially break 'executable-hooks' and gem executables overall!
")
      end
    end
    def self.install
      ensure_custom_shebang

      executable_hooks_spec = ExecutableHooks::Specification.find

      if executable_hooks_spec
        wrapper_path = File.expand_path( "bin/#{wrapper_name}", executable_hooks_spec.full_gem_path )

        if File.exist?(wrapper_path) && !File.exist?(destination)
          FileUtils.mkdir_p(bindir)
          FileUtils.cp(wrapper_path, destination)
          File.chmod(0775, destination)
        end
      end
    end
    def self.uninstall
      FileUtils.rm_f(destination) if File.exist?(destination)
    end
  end
end
