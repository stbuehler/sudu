class FeedController < BaseController
  before_filter :skip_trackable
  before_filter :authenticate_user_with_feed!

  def index
    @changes = @current_user.all_changes.includes(:item, :project, :user).order("created_at DESC")
    respond
  end

protected
  def authenticate_user_with_feed!
    @current_user = User.find_first_by_feed_token(params[:token])
    return true if @current_user && @current_user.active_for_authentication?
    raise CanCan::AccessDenied.new("Not authorized!")
  end

private
  def limit!
    # include at least the last week and at least 20 items (if possible)
    weekchanges = @changes.since(Time.current - 7)
    if weekchanges.count < 20
      @changes = @changes.limit(20)
    else
      @changes = weekchanges
    end
  end

  def respond
    limit!
    respond_to do |format|
      format.atom { render 'feed', :layout => false }
    end
  end

  def skip_trackable
    request.env['devise.skip_trackable'] = true
  end
end
