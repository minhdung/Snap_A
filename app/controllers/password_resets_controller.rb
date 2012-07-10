class PasswordResetsController < ApplicationController 
  before_filter :not_signed_in_user
  before_filter :load_user_using_persistence_token, :only => [:edit, :update] 

  def new  
  end  
  
  def edit   
  end 

  def create  
    user = User.find_by_email(params[:email])  
    if user  
      deliver_password_reset_instructions(user)  
      flash[:notice] = "Instructions to reset your password have been emailed to you. " +  
      "Please check your email."  
      redirect_to root_path  
    else  
      flash[:notice] = "No user was found with that email address"  
      render :action => :new  
    end  
  end  

  def update  
    @user.password = params[:user][:password]  
    @user.password_confirmation = params[:user][:password_confirmation]  
    if @user.save  
      flash[:notice] = "Password successfully updated"  
      sign_in @user
      redirect_to user_path(@user)
    else  
      render :action => :edit  
    end  
  end  

  def deliver_password_reset_instructions(user)
    user.reset_persistence_token!
    mail = UserMailer.reset(user)
    mail.deliver
  end
  
  private  
  def load_user_using_persistence_token  
    @user = User.find_by_persistence_token(params[:id])
    unless @user  
      flash[:notice] = "We're sorry, but we could not locate your account. " +  
      "If you are having issues try copying and pasting the URL " +  
      "from your email into your browser or restarting the " +  
      "reset password process."  
      redirect_to root_path  
    end  
  end  

end  