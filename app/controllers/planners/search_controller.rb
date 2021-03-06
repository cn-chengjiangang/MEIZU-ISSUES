class Planners::SearchController < ApplicationController
  layout 'planner'
  def index
    @result = []
    unless params[:q].empty?  
      @question = params[:q].downcase.split(" ") 
      search_for_projects
      search_for_users
      search_for_tags
    else
      @result_projects=[]
      @result_users=[]
      @result_tags=[]
    end
  end
 
  private
  
    def search_for_projects
      keyword=""
      @question.each do |k|
        keyword += "%"+k+"%"
      end
      @result_projects = User.current.projects.where("name like '#{keyword}'")
      @result << @result_projects
    end
    
    def search_for_users
      keyword="%"+params[:q]+"%"
      @result_users = User.where("concat(lastname,firstname) like '#{keyword}'")
      @result << @result_users
    end
    
    def search_for_tags
      @result_tags=[]
    end
        
end
