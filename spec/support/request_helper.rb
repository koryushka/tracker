# frozen_string_literal: true

module Support
  module RequestHelper
    # include Warden::Test::Helpers
    #
    # def sign_in(resource_or_scope, resource = nil)
    #   resource ||= resource_or_scope
    #   scope = Devise::Mapping.find_scope!(resource_or_scope)
    #   login_as(resource, scope: scope)
    # end
    #
    # def sign_out(resource_or_scope)
    #   scope = Devise::Mapping.find_scope!(resource_or_scope)
    #   logout(scope)
    # end

    include Warden::Test::Helpers

    def self.included(base)
      base.before(:each) { Warden.test_mode! }
      base.after(:each) { Warden.test_reset! }
    end

    def sign_in(resource)
      login_as(resource, scope: warden_scope(resource))
    end

    def sign_out(resource)
      logout(warden_scope(resource))
    end

    private

    def warden_scope(resource)
      resource.role.to_sym
    end
  end
end
