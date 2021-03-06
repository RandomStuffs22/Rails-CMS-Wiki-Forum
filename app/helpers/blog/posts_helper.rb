module Blog::PostsHelper
  def truncated_post_body(post)
    return "Click edit to add content." if post.body.blank?
    last_p_index = (post.body.index('</p>', 700) || 700)
    post.body.truncate(last_p_index+5, :separator => "\n", :omission => '').html_safe
  end
  def post_tools(post)
    out = ''
    if current_user and current_user.logged_in?
      if has_authorization? :update, post
        out += fake_button(link_to_edit_post(post)) + " "
      end
      if has_authorization? :create, Blog::Post.new
        out += link_to_new_post + " "
      end
      if current_user.is_admin?
        out += " " + fake_button(link_to_publish_post(post)) + " "
        out += fake_button(link_to "Revision History", revisions_blog_post_path(post)) + " "
      end
      if has_authorization? :delete, post
        out += fake_button(link_to_delete_post(post)) + " "
      end
    end
    out += link_to_rss blog_post_url(post, :atom)
    out.html_safe
  end
  def link_to_blog_category_post(post)
    return unless has_authorization?(:read, post)
    blog_link = "#{link_to('Blog', blog_posts_path)}: "
    category_link = post.category.present? ? "#{link_to(post.category.name, category_path(post.category))}: " : ' '
    "#{blog_link}#{category_link}#{h(post.title)}".html_safe
  end
  def link_to_new_post
    return unless has_authorization?(:create, Blog::Post.new)
    fake_button(link_to('New Post', new_blog_post_path))
  end
  
  def link_to_blog_admin
    return unless current_user and current_user.logged_in? and current_user.is_admin?
    fake_button(link_to('Blog Admin', blog_dashboard_path))
  end
  
  def link_to_delete_post(post)
    return unless has_authorization?(:delete, post)
    link_to 'Delete', blog_post_path(post), :method => :delete, :confirm => "Delete post: #{h(post.title)}?"
  end
  
  def link_to_edit_post(post)
    return unless has_authorization?(:update, post)
    link_to 'Edit', edit_blog_post_path(post)
  end
  
  def link_to_publish_post(post)
    return unless has_authorization?(:publish, post)
    if post.published
      link_to 'Unpublish', publish_blog_post_path(post), :method => :post, :confirm => "Unpublish post: #{h(post.title)}?"
    else
      link_to 'Publish', publish_blog_post_path(post), :method => :post, :confirm => "Publish post: #{h(post.title)}?"
    end
  end
  
  def link_to_read_more(post)
    return unless has_authorization?(:read, post)
    link_to "Read more...", blog_post_path(post)
  end
end
