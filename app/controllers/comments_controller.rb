class CommentsController < ApplicationController
  # задаем "родительский" event для коммента
  before_action :set_event, only: %i[create destroy]

  # задаем сам коммент
  before_action :set_comment, only: [:destroy]

  def create
    @new_comment = @event.comments.build(comment_params)
    @new_comment.user = current_user

    if @new_comment.save
      SendMailJob.perform_later(@new_comment)

      redirect_to @event, notice: I18n.t('controllers.comments.created')
    else
      render 'events/show'
    end
  end

  def destroy
    if current_user_can_edit?(@comment)
      @comment.destroy!
    else
      message = { alert: I18n.t('controllers.comments.error') }
    end

    redirect_to @event, notice: I18n.t('controllers.comments.destroyed'), status: 303
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_comment
    @comment = @event.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :user_name)
  end
end
