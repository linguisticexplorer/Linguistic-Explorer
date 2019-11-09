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
    photos = ["clouds", "words", "birds", "birds-bn", "ancient", "sign", "books", "shakespeare", "words2", "languages"]
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
      {:url => "tuinkabouter/497701876", :title => "Words"},
      {:url => "jurek_durczak/16235946053", :title => "Language"}
    ]
    id = id < photos.size ? id : 0
    return "<p><a href=\"https://www.flickr.com/photos/#{photos[id][:url]}\" >#{photos[id][:title]}, on Flickr</a> under CC License</p>".html_safe
  end

  def each_developer_row(columns = 1)
    devs = [
      {:name => "Dennis Shasha", :img => "hat_dev", :role => "System Architect", :link => "#"},
      {:name => "Ross Kaffenberger", :img => "cool_dev", :role => "", :link => "#"},
      {:name => "Alex Lobascio (Bosh)", :img => "cool_dev", :role => "", :link => "#"},
      {:name => "Marco Liberati", :img => "cool_dev", :role => "", :link => "#"},
      {:name => "Oleg Grishin", :img => "dev", :role => "", :link => "#"},
      {:name => "Lingliang Zhang", :img => "dev", :role => "", :link => "#"},
      {:name => "Hannan Butt", :img => "dev", :role => "", :link => "#"},
      {:name => "Andrea Olivieri", :img => "coolest_dev", :role => "", :link => "http://www.andrea-olivieri.com"}
    ]
    devs.each_slice(columns) do |row|
      yield row if block_given?
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
        if key != "description" and !example.stored_value(key).empty?
	  result += "<br />" + key.humanize + ": " if key.downcase.eql?("comment")
          result += example.stored_value(key) + "<br />" if !example.stored_value(key).empty?
        end
      # when in default table mode
      else
        unless example.stored_value(key).empty?
	  result += "<br />" + key.humanize + ": " if key.downcase.eql?("comment")
          result +=  example.stored_value(key) + "<br />"
        end
      end
    end
    return result.html_safe
  end

  def can_see?(action, item)
    if user_signed_in?
      # control if the user can see the item
      # In rare cases, the user could see the item but it could not be able to use it.
      current_user.is_expert_to_see?(action, item, can?(action, item))
    else
      can?(action, item)
    end
  end

  #different actions for an item
  def can_see_any?(actions, item)
    actions.any? do |action|
      can_see?(action, item)
    end
  end

  #different actions for different items
  def can_see_header?(actions, items)
    items.any? do |item|
      can_see_any?(actions, item)
    end
  end

  def can_see_some?
    get_user_role(current_group) === 'Expert'
  end

  def user_has_any_role?
    @group && current_user && (current_user.admin? || (current_user.member_of?(@group)))
  end

  def get_user_role(group)
    role = ''
    if current_user && group.present?
      if current_user.group_admin_of? group
        role = 'Group Admin'
      elsif current_user.member_of? group
        role = current_user.is_expert?(group) ? 'Expert' : 'Member'
      end
    end
    return role
  end

  def get_user_role_with_icon(group)
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

  def group_membership_path_if_any
    membership = @group.membership_for(current_user)
    membership.present? ? group_membership_path(@group, membership) : group_memberships_path(@group)
  end

  # This method creates an id that is useful for some capybara tests
  def table_actions_id(name, specific_action="")
    name = name.downcase.tr(" ", "_")
    specific_action = "_#{specific_action.downcase.tr(" ", "_")}" if specific_action.present?
    "#{name}#{specific_action}_actions"
  end

end
