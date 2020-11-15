require "rails/generators/active_record"

module Devise
  module Webauthn
    module Generators
      class InstallGenerator < Rails::Generators::Base
        include ActiveRecord::Generators::Migration
        source_root File.join(__dir__, "templates")

        def copy_migration
          migration_template "migration.rb", "db/migrate/install_webauthn.rb", migration_version: migration_version
        end

        def migration_version
          "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
        end

        def table_name
          "users"
        end
      end
    end
  end
end
