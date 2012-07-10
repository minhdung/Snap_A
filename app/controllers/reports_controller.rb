class ReportsController < ApplicationController
 def index
    @reports = Report.order("created_at DESC").paginate(page: params[:page])
 end

 def destroy
    Report.find(params[:id]).destroy
    flash[:success] = "Report deleted"
    redirect_to admin_reports_path
 end

  def execute
    @report = Report.find(params[:id])
    if @report.title == "user_report_photo"
      Photo.find(@report.target_id).destroy
    end
    if @report.title == "user_report_user"
      User.find(@report.target_id).destroy
    end
    @report.destroy
    redirect_to admin_reports_path
  end
end

