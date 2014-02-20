require_dependency 'discourse'
require_dependency 'archetype'

module Support
  class ApplicationController < ActionController::Base
    include CurrentUser
    layout "support"
    before_filter :cache_anon

    def cache_anon
      Middleware::AnonymousCache.anon_cache(request.env, 30.seconds)
    end

  end
end
