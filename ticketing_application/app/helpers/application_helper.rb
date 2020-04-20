module ApplicationHelper
  def is_current_status?(option)
    @ticket.status == option
  end

  def project_names
    Project.all.map {|p| p.name}
  end

  def ticket_tag_names(ticket)
    ticket.tags.map{|tag| tag.name}.join(", ")
  end

  def days_since(comment_date)
    distance_of_time_in_words(DateTime.now, comment_date)
  end
end
