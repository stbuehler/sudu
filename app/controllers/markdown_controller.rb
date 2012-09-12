class MarkdownController < BaseController

  include BaseHelper::Markdown

  def index
    respond_to do |format|
      format.json { render json: { result: markdown(params[:text]) } }
    end
  end
end
