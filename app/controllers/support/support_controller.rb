module Support
  class SupportController < Support::ApplicationController
    helper :common
    
    before_filter :load_support_categories
    def index

      respond_to do |format|
        format.html {
          render :layout => "support"
        }
      end
    end

    def show
    end

    def permalink
      @topic = visible_topics.where("meta_data @> ?", "permalink => #{request.path}").first
      if @topic
        @post = Post.where(topic_id: @topic.id)
                    .where(hidden: false)
                     .by_post_number.first
        render :action => "show"
      else
        raise Discourse::NotFound.new
      end
    end

    protected

    def visible_topics
      Topic.secured.visible.listable_topics
        .where("meta_data ? 'permalink' AND topics.title not like 'Category definition%'")
    end

    def load_support_categories
      @categories = Category.where(slug:  SiteSetting.support_parent_category_slug ).first.try(:subcategories).try(:secured)
    end
    

  end
end
