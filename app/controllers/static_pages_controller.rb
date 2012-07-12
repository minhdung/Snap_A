class StaticPagesController < ApplicationController
  def home
    @set = []
    if signed_in?
      Notification.all.each do |noti|
        if noti.source_id == current_user.id && noti.relation_type == "user_user_relationships"
         t_user = User.find(noti.target_id)
         t_user.boxes.each do |box|
          @set.concat box.photos.order("created_at")
         end
        end
      end
      @photos = @set.paginate(page: params[:page])

      if facebook?(current_user)
        authentication = current_user.authentications.find_by_provider('facebook')
        token = authentication.access_token
        me = FbGraph::User.me(token)
        friends_id = me.friends.map(&:raw_attributes).map{|f| f['id']}
        friends_auth = Authentication.where('provider = "facebook" AND uid in (?)', friends_id)
        @friends_profile = friends_auth.map{|f| f.user if f.user.active?}
      end
      store_location
    end
  end

  def about
  end

end
