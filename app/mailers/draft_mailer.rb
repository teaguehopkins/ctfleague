class DraftMailer < ActionMailer::Base
  default from: "no-reply@heavymetalalpha.herokuapp.com"

  def draft_beginning_email(draft)
    @snake_positions = draft.snake_positions
    @league = draft.league
    @draft = draft
    @snake_positions.each do |sp|
      @snake_position = sp
      @member = sp.user
      mail(to: @member.email, subject: 'The draft has begun!', host: 'example.com').deliver
    end
  end

  def draft_turn_email(draft)
    @league = draft.league
    @current_position = draft.current_position
    @current_snake_position = draft.snake_positions.find_by position: draft.current_position
    @draft = draft
    @member = @current_snake_position.user
    mail(to: @member.email, subject: 'It is your turn in the draft!', host: 'example.com').deliver
  end
end
