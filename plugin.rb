# name: discourse-support
# about: support site frontend for Discourse
# version: 0.1
# authors: Larry Salibra


module ::Support
  class Engine < ::Rails::Engine
    engine_name "support"
    isolate_namespace Support
  end
  
  
  # CORS requires us to set Access-Control-Allow-Origin on search path
  class SearchFromAnywhereMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @status, @headers, @response = @app.call(env)
      @headers.merge!({ "Access-Control-Allow-Origin" => "*"}) if env['ORIGINAL_FULLPATH'].try(:starts_with?,"/search")
      [@status, @headers, @response]
    end
  end
end

Rails.configuration.assets.precompile += ['support.js', 'support.css']
Rails.configuration.middleware.insert_after Rack::Runtime, "Support::SearchFromAnywhereMiddleware"
after_initialize do
  
  ::SUPPORT_HOST = SiteSetting.support_host
  
  class SupportConstraint
    def matches?(request)
      request.host == SUPPORT_HOST
    end
  end


  SiteContent.add_content_type :support_footer, allow_blank: true, format: :html
  
  class ::Topic
    before_save :update_or_remove_permalink
    
    
    scope :has_metadata, -> { where("meta_data is not null") } 
    
    # workaround -> https://github.com/rails/rails/issues/12497
    def add_meta_data(key,value)
      self.meta_data = (self.meta_data || {}).merge(key => value)
    end
    
    def update_or_remove_permalink
      # add permalink if topic is in sub category of 
      # the support parent topic
      if self.visible? && self.archetype == "regular" && self.category \
       && self.category.parent_category \
       && self.category.parent_category.slug == SiteSetting.support_parent_category_slug
      
        # TODO: updating slug requires changing topic's post #1 causing
        # a recook because Discourse does not offer a filter hook 
        # when topic title is changed
        self.add_meta_data("permalink", (Time.now.strftime "/questions/") + self.slug) unless self.title.include?"Category definition"
      
      else # otherwise remove permalink if it exists
        
        if self.meta_data && self.meta_data["permalink"]
        
          # workaround -> https://github.com/rails/rails/issues/12497
          meta_data = (self.meta_data).merge("permalink" => nil)
        
          meta_data.delete("permalink")
          self.meta_data = meta_data
        end
        
      end
      
    end

    

  end

  Discourse::Application.routes.prepend do
    mount ::Support::Engine, at: "/", constraints: SupportConstraint.new
  end
end
