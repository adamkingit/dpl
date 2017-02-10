  require 'yaml'

  module DPL
  class Provider
    class CloudFoundry < Provider

      def initial_go_tools_install
        context.shell 'wget \'https://cli.run.pivotal.io/stable?release=linux64-binary&source=github\' -qO cf-linux-amd64.tgz && tar -zxvf cf-linux-amd64.tgz && rm cf-linux-amd64.tgz'
      end

      def check_auth
        initial_go_tools_install
        puts "options =="
        puts options
        context.shell "./cf api #{option(:api)} #{'--skip-ssl-validation' if options[:skip_ssl_validation]}"
        context.shell "./cf login -u #{option(:username)} -p #{option(:password)} -o #{option(:organization)} -s #{option(:space)}"
      end

      def check_app
        @applications = nil
        error "Application must have a manifest.yml for unattended deployment. #{manifest} does not exist" unless File.exists? manifest
        @applications = get_applications
        error "#{manifest} must contain applications" if @applications.nil?
      end

      def needs_key?
        false
      end

      def push_app
        settings = get_cf_variable_settings
        if settings.nil? || settings.length==0
          context.shell get_cfpush_cmd
        else
          app_names_list = get_application_names
          context.shell get_cfpush_cmd << " --no-start"
          settings.each{ |set_env| context.shell "./cf set-env #{set_env[app]} #{set_env[key]} #{set_env[value]}" }
          app_names_list.each{ |appname| context.shell "./cf start #{appname}" }
        end
        context.shell "./cf logout"
      end

      def cleanup
      end

      def uncleanup
      end

      def manifest
        options[:manifest].nil? ? "manifest.yml" : "#{options[:manifest]}"
      end

      def get_cfpush_cmd
        cmd = "./cf push"
        if options[:manifest]
          cmd << " -f #{manifest}"
        end
        return(cmd)
      end

      def get_manifest
        puts "read #{manifest}. Found"
        result = YAML.load_file(manifest)
        puts result
        return result
      end

      def get_applications
        if ! defined?(@applications) || @applications.nil?
          puts "@applications not defined"
          cf_manifest = get_manifest
          @applications = cf_manifest['applications']
        end
        puts "Returning @applications"
        puts @applications
        return @applications
      end

      def get_application_names
        if ! defined?(@application_names) || @application_names.nil?
          @application_names = []
          applications = get_applications
          applications.each { |app| @application_names.push(app['name']) }
        end
        return @application_names
      end

      def get_cf_variable_settings
        env_settings = []
        puts "get_cf_variable_settings - !options[:cfenv].nil? == #{!options[:cfenv].nil?}"
        puts options
        if !options[:cfenv].nil?
          puts "options[:env] not nill"
          app_names_list = get_application_names
          options[:env].each do |key, value|
            if value.kind_of?(Hash)
              puts "env value is a Hash"
              if app_names_list.include?(key.to_s)
                value.each do |k,v|
                  env_settings.push({'app' => key, 'key' => k, 'value' => v})
                end
              else
                print "warning #{key} application not defined in manifest"
              end
            else
              puts "env value is a value " << value
              app_names_list.each{ |appname| env_settings.push({'app' => appname, 'key' => key, 'value' => value})}
            end
          end
        end
        puts "returning env_settings"
        puts env_settings
        return(env_settings)
      end

    end
  end
end
