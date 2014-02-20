
module Support
  module ApplicationHelper
    
    def company_link(subdomain, path)
      if subdomain.nil?
        return request.protocol + SiteSetting.company_domain + path
      else
        return request.protocol + subdomain + SiteSetting.company_domain + path
      end  
    end
    
    def permalink(topic)
      topic.meta_data["permalink"]
    end

    def customization_disabled?
      controller.class.name.split("::").first == "Admin" || session[:disable_customization]
    end
  end
end
