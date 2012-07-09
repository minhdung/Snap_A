class BoxesController < ApplicationController

  def index
    @user=current_user
    @boxes=@user.boxes.all
  end

  def create


    name = params[:box][:name]
    @box = current_user.boxes.build(name: name, category_id: params[:box][:category_id])

    if @box.save
      follower_follow_this_box(@box)
      # redirect_to root_path
      redirect_back_or(root_path)
    else
      # @micropost = current_user.microposts.build(params[:micropost])
      # if @micropost.save
      #   flash[:success] = "Micropost created!"
      #   redirect_to root_path
      # else
      render 'static_pages/home'
      # end
    end
  end

  def show
    @user=current_user
    @box=@user.boxes.find(params[:id])
    @photos=@box.photos.all
  end

  def destroy
     # User.find(params[:id]).destroy
     box = Box.find(params[:box_id]).destroy
     delete_rel_to_box(box)
     flash[:success] = "Box #{params[:box_id]} destroyed."
     redirect_to boxes_path
   end

   def delete
   end
   
   def edit
    @box = Box.find(params[:id])
  end

  def update
    @box = Box.find(params[:id])
    if @box.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      redirect_back_or @box
    else
      render 'edit'
    end
  end


  private
  def follower_follow_this_box(box)
    followers = current_user.followers
    if followers != nil
      followers.each do |follower|
        follower.follow_box!(box)
      end
    end
  end

  def delete_rel_to_box(box)
    rel = UserBoxFollow.find_by_box_id(box.id)
    if rel != nil
      rel.destroy
    end
  end
end
