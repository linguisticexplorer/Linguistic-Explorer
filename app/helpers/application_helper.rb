module ApplicationHelper

  def support_email
    "support@terraling.com".html_safe
  end

  def link_to_google_web_font(font)
    "<link href='http://fonts.googleapis.com/css?family=#{u(font)}' rel='stylesheet' type='text/css'>".html_safe
  end

  def page_title
    ((content_for(:title) + " - " if content_for?(:title)).to_s + 'TerraLing').html_safe
  end

  def page_heading(text)
    content_tag(:h1, content_for(:title){ text })
  end

  def add_body_classes(*classes)
    @body_classes ||= []
    @body_classes += Array(classes).flatten
  end

  def body_classes(*additional_classes)
    classes = []
    classes << "current_user" if user_signed_in?
    classes << @body_classes if @body_classes
    classes << additional_classes
    classes.flatten.uniq.join(" - ")
  end

  def daily_image(id)
    photos = ["clouds", "words", "birds", "birds-bn", "ancient", "sign", "books", "shakespeare", "words2"]
    id = id < photos.size ? id : 0
    photos[id]
  end

  def daily_attribution(id)
    photos = [
      {:url => "nofrills/10895361", :title => "language variety on cadbury&#x27;s choc by nofrills"},
      {:url => "silveraquarius/9972360303", :title => "Language of the Ancients by JimmyMac210"},
      {:url => "davidyuweb/4344917629", :title => "Language of The birds with Transamerica of San Francisco by David Yu"},
      {:url => "multimaniaco/11409492903", :title => "The Language of Birds by Cesar Viteri Ramirez"},
      {:url => "curiousexpeditions/1568278214", :title => "Closeup on the Linen Book/Mummy Wrappings of the Lost Etruscan Language by Curious Expeditions"},
      {:url => "valeriebb/3008977110", :title => "Learn sign language at the playground by Valerie Everett"},
      {:url => "hindrik/6486016175", :title => "focus on language by Hindrik Sijens"},
      {:url => "disowned/1158260369", :title => "Shakespeare's words"},
      {:url => "tuinkabouter/497701876", :title => "Words"}
    ]
    id = id < photos.size ? id : 0
    return "<p><a href=\"https://www.flickr.com/photos/#{photos[id][:url]}\" >#{photos[id][:title]}, on Flickr</a> under CC License</p>".html_safe
  end

  def each_developer()
    names = ["Ross Kaffenberger", "Alex Lobascio (Bosh)", "Marco Liberati", "Oleg Grishin", "Lingliang Zhang", "Dennis Shasha"]
    # imgs = ["https://pbs.twimg.com/profile_images/3411671204/562c5a9408e4e740b9172f69539f5667_400x400.jpeg"]
    imgs = ["developer.png","developer.png","developer.png","developer.png","developer.png","developer.png"]
    roles = ["", "", "", "", "", "System Architect"]
    names.each_with_index do |name, index|
      yield name, imgs[index], roles[index], '#' if block_given?
    end
  end
  
  def display_style_example(style_id)
    result = "<table class='show-table table table-bordered table-striped table-hover'>"
    case style_id
    when 0
      result += "<tr>
        <th>Ling</th>
        <th>Description</th>
        <th>Gloss</th>
        <th>Words</th>
        <th>Translation</th>
        <th class='small-comment'>Comment</th>
        </tr>
        <tr>
        <td>Afrikaans</td>
        <td>Test example of Afrikaans language</td>
        <td>Die studente lees</td>
        <td>the student.PL read </td>
        <td>The students are reading </td>
        <td class='small-comment'>This is the required order in main clauses, which are necessarily V2. It is also the order found in unmodified embedded clauses (i.e. dat die studente lees). Where modifiers are present, main and embedded clauses differ, though (Die studente lees gretig v</td>
        </tr>"
    when 1
      result += "<tr>
        <th>Ling</th>
        <th class='small-col'>Description</th>
        <th>Values</th>
        <th class='medium-col'>Comment</th>
        </tr>
        <tr>
        <td>Afrikaans</td>
        <td class='small-col'>Test example of Afrikaans language</td>
        <td class='align-left'>
        Die studente lees
        <br />the student.PL read
        <br />The students are reading </td>
        <td class='medium-col'>This is the required order in main clauses, which are necessarily V2. It is also the order found in unmodified embedded clauses (i.e. dat die studente lees). Where modifiers are present, main and embedded clauses differ, though (Die studente lees gretig v</td>
        </tr>"
    end
    return (result + "</table>").html_safe
  end

  # second param should return 
  def display_example(example_id, display_mode)
    example = Example.find(example_id)
    result = ""
    example.group.example_storable_keys.each do |key|
      case display_mode
      when "linguistic"
        if key != "description" and key != "comment"
          result += example.stored_value(key) + "<br />" if !example.stored_value(key).empty?
        end
      # when in default table mode
      else
        result += key.humanize + ": " + example.stored_value(key) + "<br />"
      end
    end
    return result.html_safe
  end

  def can_see?(action, item)
    if current_user && (current_user.admin? || current_user.group_admin_of?(current_group))
      can? action, item
    elsif user_signed_in?
      can?(action, item) && current_user.is_expert_of?(item.is_a?(Array) ? item.first : item)
    else
      can?(action, item)
    end
  end

  def user_has_any_role?
    @group && (current_user.admin? || (current_user.member_of?(@group)))
  end

  def get_user_role(group)
    role = ''
    if group.present?
      if current_user.group_admin_of? group
        role = 'Group Admin'
      elsif current_user.member_of? group
        role = current_user.is_expert?(group) ? 'Expert' : 'Member'
      end
    end
    return role
  end

  def get_user_role_wth_icon(group)
    role = ''
    if group.present?
      if current_user.group_admin_of? group
        role = icon 'group', 'Group Admin'
      elsif current_user.member_of? group
        role = current_user.is_expert?(group) ? icon('certificate', 'Expert') : icon('user', 'Member')
      end
    end
    return role
  end

  def number_to_text_class(number)
    number < 5 ? "red" : number < 50 ? "yellow" : "green"
  end

  def number_to_icon_name(number)
    number < 30 ? 'exclamation-triangle' : 'check-circle'
  end

end
