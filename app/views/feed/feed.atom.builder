atom_feed :root_url => root_url do |feed|
  feed.title("#{Sudu::Application.config.action_mailer.default_url_options[:host]} - item changes")
  feed.updated(@changes[0].created_at) if @changes.length > 0

  @changes.each do |change|
    item = change.item
    feed.entry change, :url => todo_item_url(item) + "##{change.id}" do |entry|
      entry.title("changed ##{item.id}: " + (change.status.blank? ? 'comment' : change.status.split(/\n+/).join(', ')))
      content = ''
      if change.comment
        content += '<div><b>Comment: </b><br />' + markdown(change.comment) + '</div>'
      end
      d = change.current_description
      if d
        content += '<hr />' unless content.blank?
        content += '<div><b>Description: </b><br />' + markdown(d) + '</div>'
      end
      content = "<div><b>List:</b> #{h(item.project.name)}: #{h(item.list.name)}</div>" + content 
      entry.content(content, :type => 'html')

      entry.author do |author|
        author.name(change.user.username)
      end
    end
  end
end
