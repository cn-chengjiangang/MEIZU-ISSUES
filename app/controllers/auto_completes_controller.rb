# Redmine - project management software
# Copyright (C) 2006-2012  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class AutoCompletesController < ApplicationController
  before_filter :find_project

  def issues
    @issues = []
    q = (params[:q] || params[:term]).to_s.strip
    if q.present?
      scope = (params[:scope] == "all" || @project.nil? ? Issue : @project.issues).visible
      if q.match(/^\d+$/)
        @issues << scope.find_by_id(q.to_i)
      end
      @issues += scope.where("LOWER(#{Issue.table_name}.subject) LIKE ?", "%#{q.downcase}%").order("#{Issue.table_name}.id DESC").limit(10).all
      @issues.compact!
    end
    render :layout => false
  end

  def assigned_to
    @users = @project ? @project.users : User.where("id > 2")

    has_me = @users.include?(User.current)
    @users = @users.map{|u| [u.name, PinYin.of_string(u.name).join, u.id] }

    q = (params[:q] || params[:term]).to_s.strip.gsub(/\s/, '')
    if q.present?
      @users = @users.select {|u| u[1].include?(q) or u[0].include?(q)}
    end
    @users = @users.sort{|a, b| a[1] <=> b[1]}.map{|u| {id: u[2], text: u[0]}}
    @users.unshift({id: User.current.id, text: "<< #{l(:label_me)} >>"}) if has_me
    @users.unshift({id: "", text: ""}) unless q.present?

    respond_to do |format|
      format.json { render :json => @users.to_json }
      format.html { render :nothing }
    end
  end

  private

  def find_project
    if params[:project_id].present?
      @project = Project.find(params[:project_id])
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
